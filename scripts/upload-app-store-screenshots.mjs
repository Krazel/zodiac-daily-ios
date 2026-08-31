import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

const bundleIdentifier = "com.krazel.zodiacdaily";
const marketingVersion = "1.0";
const screenshotDisplayType = "APP_IPHONE_65";
const screenshotRoot = path.resolve("AppStore", "StoreReady");
const locales = ["en-US", "es-ES"];

const keyId = requiredEnvironment("ASC_KEY_ID").trim();
const issuerId = requiredEnvironment("ASC_ISSUER_ID").trim();
const privateKey = fs.readFileSync(requiredEnvironment("ASC_PRIVATE_KEY_PATH"), "utf8");
const token = createToken({ keyId, issuerId, privateKey });

const apps = await apiRequest(token, "GET", "/v1/apps", {
  query: { "filter[bundleId]": bundleIdentifier, limit: "10" }
});
const app = apps.data?.find((candidate) => candidate.attributes?.bundleId === bundleIdentifier);
if (!app) fail(`No App Store Connect app exists for ${bundleIdentifier}.`);

const versions = await apiRequest(token, "GET", "/v1/appStoreVersions", {
  query: {
    "filter[app]": app.id,
    "filter[platform]": "IOS",
    "filter[versionString]": marketingVersion,
    limit: "20"
  }
});
const version = versions.data?.find((candidate) =>
  candidate.attributes?.versionString === marketingVersion
);
if (!version) fail(`No editable App Store version ${marketingVersion} exists.`);
if (version.attributes?.appStoreState !== "PREPARE_FOR_SUBMISSION") {
  fail(`Version ${marketingVersion} is not editable: ${version.attributes?.appStoreState}.`);
}

const localizationResponse = await apiRequest(
  token,
  "GET",
  `/v1/appStoreVersions/${version.id}/appStoreVersionLocalizations`,
  { query: { limit: "200" } }
);
const localizationByLocale = new Map(
  (localizationResponse.data ?? []).map((item) => [item.attributes?.locale, item])
);

const result = {
  app: { id: app.id, bundleId: bundleIdentifier },
  version: {
    id: version.id,
    versionString: version.attributes?.versionString,
    state: version.attributes?.appStoreState
  },
  screenshotDisplayType,
  localizations: []
};

for (const locale of locales) {
  const localization = localizationByLocale.get(locale);
  if (!localization) fail(`Missing App Store version localization ${locale}.`);

  const directory = path.join(screenshotRoot, locale);
  const filePaths = fs.readdirSync(directory)
    .filter((name) => name.toLowerCase().endsWith(".png"))
    .sort()
    .map((name) => path.join(directory, name));
  if (filePaths.length !== 6) {
    fail(`Expected exactly 6 PNG screenshots for ${locale}; found ${filePaths.length}.`);
  }

  const sets = await apiRequest(
    token,
    "GET",
    `/v1/appStoreVersionLocalizations/${localization.id}/appScreenshotSets`,
    {
      query: {
        "filter[screenshotDisplayType]": screenshotDisplayType,
        limit: "50"
      }
    }
  );
  let screenshotSet = (sets.data ?? []).find(
    (item) => item.attributes?.screenshotDisplayType === screenshotDisplayType
  );
  if (!screenshotSet) {
    const created = await apiRequest(token, "POST", "/v1/appScreenshotSets", {
      body: {
        data: {
          type: "appScreenshotSets",
          attributes: { screenshotDisplayType },
          relationships: {
            appStoreVersionLocalization: {
              data: { type: "appStoreVersionLocalizations", id: localization.id }
            }
          }
        }
      }
    });
    screenshotSet = created.data;
  }

  const existingResponse = await apiRequest(
    token,
    "GET",
    `/v1/appScreenshotSets/${screenshotSet.id}/appScreenshots`,
    { query: { limit: "50" } }
  );
  const existing = existingResponse.data ?? [];
  const desiredNames = filePaths.map((filePath) => path.basename(filePath));
  const unexpected = existing.filter(
    (item) => !desiredNames.includes(item.attributes?.fileName)
  );
  if (unexpected.length > 0) {
    fail(
      `${locale} contains screenshots outside the canonical set: ` +
      unexpected.map((item) => item.attributes?.fileName).join(", ")
    );
  }

  const screenshotIds = [];
  for (const filePath of filePaths) {
    const fileName = path.basename(filePath);
    const duplicate = existing.filter((item) => item.attributes?.fileName === fileName);
    if (duplicate.length > 1) fail(`${locale} has duplicate screenshot ${fileName}.`);

    let screenshot = duplicate[0];
    if (screenshot) {
      screenshot = await waitForComplete(token, screenshot.id, locale, fileName);
    } else {
      screenshot = await uploadScreenshot(token, screenshotSet.id, filePath);
      screenshot = await waitForComplete(token, screenshot.id, locale, fileName);
    }
    screenshotIds.push(screenshot.id);
  }

  await apiRequest(
    token,
    "PATCH",
    `/v1/appScreenshotSets/${screenshotSet.id}/relationships/appScreenshots`,
    {
      body: {
        data: screenshotIds.map((id) => ({ type: "appScreenshots", id }))
      }
    }
  );

  result.localizations.push({
    locale,
    localizationId: localization.id,
    screenshotSetId: screenshotSet.id,
    screenshots: desiredNames.map((fileName, index) => ({
      fileName,
      id: screenshotIds[index],
      state: "COMPLETE"
    }))
  });
}

console.log(JSON.stringify(result, null, 2));

async function uploadScreenshot(tokenValue, screenshotSetId, filePath) {
  const bytes = fs.readFileSync(filePath);
  const fileName = path.basename(filePath);
  const reservation = await apiRequest(tokenValue, "POST", "/v1/appScreenshots", {
    body: {
      data: {
        type: "appScreenshots",
        attributes: { fileName, fileSize: bytes.length },
        relationships: {
          appScreenshotSet: {
            data: { type: "appScreenshotSets", id: screenshotSetId }
          }
        }
      }
    }
  });
  const screenshot = reservation.data;
  const operations = screenshot.attributes?.uploadOperations ?? [];
  if (operations.length === 0) fail(`Apple returned no upload operations for ${fileName}.`);

  for (const operation of operations) {
    const headers = Object.fromEntries(
      (operation.requestHeaders ?? []).map(({ name, value }) => [name, value])
    );
    const start = operation.offset;
    const end = start + operation.length;
    const response = await fetch(operation.url, {
      method: operation.method,
      headers,
      body: bytes.subarray(start, end)
    });
    if (!response.ok) {
      fail(`Asset upload failed for ${fileName}: ${response.status} ${await response.text()}`);
    }
  }

  const checksum = crypto.createHash("md5").update(bytes).digest("hex");
  return (await apiRequest(tokenValue, "PATCH", `/v1/appScreenshots/${screenshot.id}`, {
    body: {
      data: {
        type: "appScreenshots",
        id: screenshot.id,
        attributes: { uploaded: true, sourceFileChecksum: checksum }
      }
    }
  })).data;
}

async function waitForComplete(tokenValue, screenshotId, locale, fileName) {
  for (let attempt = 1; attempt <= 60; attempt += 1) {
    const response = await apiRequest(tokenValue, "GET", `/v1/appScreenshots/${screenshotId}`);
    const screenshot = response.data;
    const delivery = screenshot.attributes?.assetDeliveryState;
    const state = delivery?.state;
    if (state === "COMPLETE") return screenshot;
    if (state === "FAILED") {
      fail(`${locale}/${fileName} failed processing: ${JSON.stringify(delivery)}`);
    }
    await new Promise((resolve) => setTimeout(resolve, 3000));
  }
  fail(`${locale}/${fileName} did not finish processing in time.`);
}

async function apiRequest(tokenValue, method, endpoint, options = {}) {
  const url = new URL(`https://api.appstoreconnect.apple.com${endpoint}`);
  for (const [name, value] of Object.entries(options.query ?? {})) {
    url.searchParams.set(name, value);
  }
  const response = await fetch(url, {
    method,
    headers: {
      Authorization: `Bearer ${tokenValue}`,
      ...(options.body ? { "Content-Type": "application/json" } : {})
    },
    body: options.body ? JSON.stringify(options.body) : undefined
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

function requiredEnvironment(name) {
  const value = process.env[name];
  if (!value) fail(`Missing ${name}.`);
  return value;
}

function fail(message) {
  console.error(message);
  process.exit(1);
}
