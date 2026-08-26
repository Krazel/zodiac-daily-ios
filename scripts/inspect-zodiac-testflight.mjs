import crypto from "node:crypto";
import fs from "node:fs";

const bundleIdentifier = "com.krazel.zodiacdaily";
const expectedMarketingVersion = "0.2.3";
const expectedBuildNumber = "1";

const keyId = requiredEnvironment("ASC_KEY_ID").trim();
const issuerId = requiredEnvironment("ASC_ISSUER_ID").trim();
const privateKey = fs.readFileSync(requiredEnvironment("ASC_PRIVATE_KEY_PATH"), "utf8");
const token = createToken({ keyId, issuerId, privateKey });

const apps = await request(token, "/v1/apps", {
  "filter[bundleId]": bundleIdentifier,
  limit: "10"
});
const app = apps.data?.find((candidate) => candidate.attributes?.bundleId === bundleIdentifier);
if (!app) fail(`No App Store Connect app exists for ${bundleIdentifier}.`);

const builds = await request(token, "/v1/builds", {
  "filter[app]": app.id,
  "filter[version]": expectedBuildNumber,
  include: "preReleaseVersion",
  limit: "10"
});
const versionsById = new Map(
  (builds.included ?? [])
    .filter((item) => item.type === "preReleaseVersions")
    .map((item) => [item.id, item.attributes?.version])
);
const matchingBuilds = (builds.data ?? []).filter((build) => {
  const versionId = build.relationships?.preReleaseVersion?.data?.id;
  return versionsById.get(versionId) === expectedMarketingVersion;
});

const groups = await request(token, "/v1/betaGroups", {
  "filter[app]": app.id,
  limit: "200"
});
const groupSummaries = await Promise.all((groups.data ?? []).map(async (group) => {
  const testers = await request(token, `/v1/betaGroups/${group.id}/betaTesters`, {
    limit: "200"
  });
  return {
    id: group.id,
    name: group.attributes?.name,
    isInternalGroup: group.attributes?.isInternalGroup,
    hasAccessToAllBuilds: group.attributes?.hasAccessToAllBuilds,
    testerCount: testers.meta?.paging?.total ?? testers.data?.length ?? 0
  };
}));

console.log(JSON.stringify({
  app: {
    id: app.id,
    name: app.attributes?.name,
    bundleId: app.attributes?.bundleId
  },
  expected: {
    marketingVersion: expectedMarketingVersion,
    buildNumber: expectedBuildNumber
  },
  builds: matchingBuilds.map((build) => ({
    id: build.id,
    uploadedDate: build.attributes?.uploadedDate,
    processingState: build.attributes?.processingState,
    expired: build.attributes?.expired,
    minOsVersion: build.attributes?.minOsVersion,
    usesNonExemptEncryption: build.attributes?.usesNonExemptEncryption,
    buildAudienceType: build.attributes?.buildAudienceType
  })),
  betaGroups: groupSummaries
}, null, 2));

async function request(tokenValue, endpoint, query) {
  const url = new URL(`https://api.appstoreconnect.apple.com${endpoint}`);
  for (const [name, value] of Object.entries(query ?? {})) {
    url.searchParams.set(name, value);
  }
  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${tokenValue}` }
  });
  const responseText = await response.text();
  const json = responseText ? JSON.parse(responseText) : {};
  if (!response.ok) {
    fail(`App Store Connect API failed GET ${endpoint}: ${response.status} ${responseText}`);
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
