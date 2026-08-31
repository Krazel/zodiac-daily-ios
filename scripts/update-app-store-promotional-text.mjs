import crypto from "node:crypto";
import fs from "node:fs";

const bundleIdentifier = "com.krazel.zodiacdaily";
const applyChanges = process.env.APPLY_CHANGES === "true";
const requestedVersion = process.env.MARKETING_VERSION?.trim();
const outputPath = process.env.OUTPUT_PATH;
const promotionalText = {
  "en-US": "Turn today's zodiac card for daily scores, lucky details and Moon insights. Read in English or Spanish, save favorites, and keep every reading private.",
  "es-ES": "Gira la carta zodiacal de hoy para ver puntuaciones, suerte y claves de la Luna. Lee en castellano o inglés, guarda tus favoritas y mantén tus lecturas privadas.",
};

for (const [locale, value] of Object.entries(promotionalText)) {
  const count = [...value].length;
  if (count > 170) fail(`${locale} promotional text has ${count} characters; maximum is 170.`);
}

const keyId = requiredEnvironment("ASC_KEY_ID").trim();
const issuerId = requiredEnvironment("ASC_ISSUER_ID").trim();
const privateKey = fs.readFileSync(requiredEnvironment("ASC_PRIVATE_KEY_PATH"), "utf8");
const token = createToken({ keyId, issuerId, privateKey });

const apps = await apiRequest(token, "GET", "/v1/apps", {
  query: { "filter[bundleId]": bundleIdentifier, limit: "10" },
});
const app = apps.data?.find((candidate) => candidate.attributes?.bundleId === bundleIdentifier);
if (!app) fail(`No App Store Connect app exists for ${bundleIdentifier}.`);

const versions = await apiRequest(token, "GET", `/v1/apps/${app.id}/appStoreVersions`, {
  query: {
    "filter[platform]": "IOS",
    ...(requestedVersion ? { "filter[versionString]": requestedVersion } : {}),
    limit: "50",
  },
});
const editableVersions = (versions.data ?? []).filter(
  (candidate) => candidate.attributes?.appStoreState === "PREPARE_FOR_SUBMISSION",
);
if (editableVersions.length !== 1) {
  fail(`Expected exactly one editable iOS version; found ${editableVersions.length}.`);
}
const version = editableVersions[0];

const localizationResponse = await apiRequest(
  token,
  "GET",
  `/v1/appStoreVersions/${version.id}/appStoreVersionLocalizations`,
  { query: { limit: "200" } },
);
const localizationByLocale = new Map(
  (localizationResponse.data ?? []).map((item) => [item.attributes?.locale, item]),
);

const evidence = {
  mode: applyChanges ? "apply" : "dry-run",
  bundleIdentifier,
  version: version.attributes?.versionString,
  state: version.attributes?.appStoreState,
  localizations: [],
  fieldsChanged: ["promotionalText"],
  createdVersion: false,
  submittedForReview: false,
};

for (const [locale, value] of Object.entries(promotionalText)) {
  const localization = localizationByLocale.get(locale);
  if (!localization) fail(`Missing App Store version localization ${locale}.`);

  const previousValue = localization.attributes?.promotionalText ?? "";
  if (applyChanges && previousValue !== value) {
    await apiRequest(token, "PATCH", `/v1/appStoreVersionLocalizations/${localization.id}`, {
      body: {
        data: {
          type: "appStoreVersionLocalizations",
          id: localization.id,
          attributes: { promotionalText: value },
        },
      },
    });
  }

  const verified = applyChanges
    ? await apiRequest(token, "GET", `/v1/appStoreVersionLocalizations/${localization.id}`)
    : { data: localization };
  const finalValue = applyChanges ? verified.data?.attributes?.promotionalText : value;
  if (finalValue !== value) fail(`Promotional text verification failed for ${locale}.`);

  evidence.localizations.push({
    locale,
    localizationId: localization.id,
    characterCount: [...value].length,
    promotionalText: value,
    previousPromotionalText: previousValue,
    verified: applyChanges,
  });
}

const rendered = `${JSON.stringify(evidence, null, 2)}\n`;
if (outputPath) fs.writeFileSync(outputPath, rendered);
console.log(rendered);

async function apiRequest(tokenValue, method, endpoint, options = {}) {
  const url = new URL(`https://api.appstoreconnect.apple.com${endpoint}`);
  for (const [name, value] of Object.entries(options.query ?? {})) url.searchParams.set(name, value);
  const response = await fetch(url, {
    method,
    headers: {
      Authorization: `Bearer ${tokenValue}`,
      ...(options.body ? { "Content-Type": "application/json" } : {}),
    },
    body: options.body ? JSON.stringify(options.body) : undefined,
  });
  const responseText = await response.text();
  const json = responseText ? JSON.parse(responseText) : {};
  if (!response.ok) {
    fail(`App Store Connect API failed ${method} ${endpoint}: ${response.status} ${responseText}`);
  }
  return json;
}

function createToken({ keyId: tokenKeyId, issuerId: tokenIssuerId, privateKey: tokenPrivateKey }) {
  const now = Math.floor(Date.now() / 1000);
  const header = base64url(JSON.stringify({ alg: "ES256", kid: tokenKeyId, typ: "JWT" }));
  const payload = base64url(JSON.stringify({
    iss: tokenIssuerId,
    aud: "appstoreconnect-v1",
    exp: now + 19 * 60,
    iat: now,
  }));
  const input = `${header}.${payload}`;
  const signer = crypto.createSign("SHA256");
  signer.update(input);
  signer.end();
  const signature = signer.sign({ key: tokenPrivateKey, dsaEncoding: "ieee-p1363" });
  return `${input}.${base64url(signature)}`;
}

function base64url(value) {
  const buffer = Buffer.isBuffer(value) ? value : Buffer.from(value);
  return buffer.toString("base64").replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

function requiredEnvironment(name) {
  const value = process.env[name];
  if (!value) fail(`Missing ${name}.`);
  return value;
}

function fail(message) {
  console.error(message);
  process.exit(1);
}
