import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

const bundleIdentifier = "com.krazel.zodiacdaily";
const profileName = process.env.IOS_PROFILE_NAME ?? "Zodiac Daily App Store 2026-08-11";

if (process.argv[2] !== "--confirm-create-zodiac-profile") {
  fail("Creation requires --confirm-create-zodiac-profile.");
}

const outputDirectory = requiredArgument(3, "output directory");
const statePath = path.join(outputDirectory, "signing-resource-state.json");
const profilePath = path.join(outputDirectory, "ZodiacDaily-App-Store.mobileprovision");
const certificateId = requiredEnvironment("APPLE_DISTRIBUTION_CERTIFICATE_ID");
const keyId = requiredEnvironment("ASC_KEY_ID");
const issuerId = requiredEnvironment("ASC_ISSUER_ID");
const privateKeyPath = requiredEnvironment("ASC_PRIVATE_KEY_PATH");
const privateKey = fs.readFileSync(privateKeyPath, "utf8");

fs.mkdirSync(outputDirectory, { recursive: true });
const token = createAppStoreConnectToken({ keyId, issuerId, privateKey });

const bundleIds = await ascRequest(token, "GET", "/v1/bundleIds?limit=200");
const bundleId = bundleIds.data?.find(
  (candidate) => candidate.attributes?.identifier === bundleIdentifier
);
if (!bundleId) fail(`No exact Bundle ID resource exists for ${bundleIdentifier}.`);

const certificate = await ascRequest(token, "GET", `/v1/certificates/${certificateId}`);
if (certificate.data?.attributes?.certificateType !== "DISTRIBUTION") {
  fail(`Certificate ${certificateId} is not an Apple Distribution certificate.`);
}
const certificateExpiration = Date.parse(certificate.data.attributes.expirationDate ?? "");
if (!Number.isFinite(certificateExpiration) || certificateExpiration <= Date.now()) {
  fail(`Certificate ${certificateId} is expired or has no valid expiration date.`);
}

const bundleProfiles = await ascRequest(
  token,
  "GET",
  `/v1/bundleIds/${bundleId.id}/profiles?limit=200`
);
let profile = bundleProfiles.data?.find(
  (candidate) =>
    candidate.attributes?.name === profileName &&
    candidate.attributes?.profileState === "ACTIVE"
);

if (profile) {
  profile = (await ascRequest(token, "GET", `/v1/profiles/${profile.id}`)).data;
  console.log(`Reusing active App Store profile: ${profile.id}`);
} else {
  profile = (
    await ascRequest(token, "POST", "/v1/profiles", {
      data: {
        type: "profiles",
        attributes: {
          name: profileName,
          profileType: "IOS_APP_STORE"
        },
        relationships: {
          bundleId: {
            data: { type: "bundleIds", id: bundleId.id }
          },
          certificates: {
            data: [{ type: "certificates", id: certificateId }]
          }
        }
      }
    })
  ).data;
  console.log(`Created App Store profile: ${profile.id}`);
}

const profileContent = profile.attributes?.profileContent;
if (!profileContent) fail("Apple returned the profile without downloadable content.");
fs.writeFileSync(profilePath, Buffer.from(profileContent, "base64"), { mode: 0o600 });

const state = {
  bundleId: bundleId.id,
  bundleIdentifier,
  certificateId,
  certificateType: certificate.data.attributes.certificateType,
  certificateExpirationDate: certificate.data.attributes.expirationDate,
  profileId: profile.id,
  profileName: profile.attributes?.name,
  profileType: profile.attributes?.profileType,
  profileState: profile.attributes?.profileState,
  profileUuid: profile.attributes?.uuid,
  profileExpirationDate: profile.attributes?.expirationDate
};
fs.writeFileSync(statePath, `${JSON.stringify(state, null, 2)}\n`, {
  encoding: "utf8",
  mode: 0o600
});

console.log(`Signing profile ready for ${bundleIdentifier}.`);

async function ascRequest(tokenValue, method, endpoint, body) {
  const response = await fetch(`https://api.appstoreconnect.apple.com${endpoint}`, {
    method,
    headers: {
      Authorization: `Bearer ${tokenValue}`,
      ...(body ? { "Content-Type": "application/json" } : {})
    },
    body: body ? JSON.stringify(body) : undefined
  });
  const responseText = await response.text();
  const json = responseText ? JSON.parse(responseText) : {};
  if (!response.ok) {
    fail(`App Store Connect API failed ${method} ${endpoint}: ${response.status} ${responseText}`);
  }
  return json;
}

function createAppStoreConnectToken({ keyId: tokenKeyId, issuerId: tokenIssuerId, privateKey: tokenPrivateKey }) {
  const now = Math.floor(Date.now() / 1000);
  const header = base64url(JSON.stringify({ alg: "ES256", kid: tokenKeyId, typ: "JWT" }));
  const payload = base64url(JSON.stringify({
    iss: tokenIssuerId,
    aud: "appstoreconnect-v1",
    exp: now + 19 * 60,
    iat: now
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
  return buffer
    .toString("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

function requiredArgument(index, label) {
  const value = process.argv[index];
  if (!value) fail(`Missing ${label}.`);
  return path.resolve(value);
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
