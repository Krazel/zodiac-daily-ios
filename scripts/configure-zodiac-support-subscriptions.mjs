import crypto from "node:crypto";
import fs from "node:fs";

const bundleIdentifier = "com.krazel.zodiacdaily";
const groupReferenceName = "Zodiac Daily Supporters";
const anchorTerritory = "ESP";
const applyChanges = process.env.APPLY_CHANGES === "true";
const outputPath = process.env.OUTPUT_PATH;

const catalog = [
  {
    productId: "com.krazel.zodiacdaily.support.monthly.099",
    referenceName: "Zodiac Daily Support Monthly 0.99",
    price: "0.99",
  },
  {
    productId: "com.krazel.zodiacdaily.support.monthly.299",
    referenceName: "Zodiac Daily Support Monthly 3",
    price: "3.0",
  },
  {
    productId: "com.krazel.zodiacdaily.support.monthly.499",
    referenceName: "Zodiac Daily Support Monthly 5",
    price: "5.0",
  },
  {
    productId: "com.krazel.zodiacdaily.support.monthly.999",
    referenceName: "Zodiac Daily Support Monthly 10",
    price: "10.0",
  },
  {
    productId: "com.krazel.zodiacdaily.support.monthly.1499",
    referenceName: "Zodiac Daily Support Monthly 15",
    price: "15.0",
  },
  {
    productId: "com.krazel.zodiacdaily.support.monthly.2999",
    referenceName: "Zodiac Daily Support Monthly 30",
    price: "30.0",
  },
  {
    productId: "com.krazel.zodiacdaily.support.monthly.50",
    referenceName: "Zodiac Daily Support Monthly 50",
    price: "49.99",
  },
].map((item) => ({
  ...item,
  localizations: {
    "en-US": ["Monthly Supporter", "Voluntary monthly support. Supporter status while active."],
    "es-ES": ["Apoyo mensual", "Apoyo mensual voluntario. Estado de colaborador mientras esté activo."],
  },
}));

const auth = {
  keyId: requiredEnvironment("ASC_KEY_ID").trim(),
  issuerId: requiredEnvironment("ASC_ISSUER_ID").trim(),
  privateKey: fs.readFileSync(requiredEnvironment("ASC_PRIVATE_KEY_PATH"), "utf8"),
};

const report = {
  mode: applyChanges ? "apply" : "dry-run",
  app: null,
  group: null,
  products: [],
  submittedForReview: false,
};

const apps = await listAll("/v1/apps", {
  "filter[bundleId]": bundleIdentifier,
  limit: "10",
});
const app = apps.find((item) => item.attributes?.bundleId === bundleIdentifier);
if (!app) fail(`No App Store Connect app exists for ${bundleIdentifier}.`);
report.app = { id: app.id, bundleId: bundleIdentifier };

let groups = await listAll(`/v1/apps/${app.id}/subscriptionGroups`, { limit: "200" });
let group = groups.find((item) => item.attributes?.referenceName === groupReferenceName);
if (!group) {
  requireApply(`create subscription group ${groupReferenceName}`);
  group = (await apiRequest("POST", "/v1/subscriptionGroups", {
    body: {
      data: {
        type: "subscriptionGroups",
        attributes: { referenceName: groupReferenceName },
        relationships: { app: { data: { type: "apps", id: app.id } } },
      },
    },
  })).data;
}
report.group = { id: group.id, referenceName: groupReferenceName };

await ensureGroupLocalizations(group.id);

let subscriptions = await listAll(`/v1/subscriptionGroups/${group.id}/subscriptions`, { limit: "200" });
for (const item of catalog) {
  let subscription = subscriptions.find((candidate) => candidate.attributes?.productId === item.productId);
  if (!subscription) {
    requireApply(`create subscription ${item.productId}`);
    subscription = (await apiRequest("POST", "/v1/subscriptions", {
      body: {
        data: {
          type: "subscriptions",
          attributes: {
            name: item.referenceName,
            productId: item.productId,
            subscriptionPeriod: "ONE_MONTH",
            familySharable: false,
            groupLevel: 1,
            availableInAllTerritories: true,
            reviewNote: "Optional monthly support. The complete app remains free; all levels provide the same supporter status.",
          },
          relationships: {
            group: { data: { type: "subscriptionGroups", id: group.id } },
          },
        },
      },
    })).data;
    subscriptions.push(subscription);
  }

  assertSubscription(subscription, item);
  await ensureSubscriptionLocalizations(subscription.id, item);
  const pricing = await ensurePrices(subscription.id, item.price);
  report.products.push({
    id: subscription.id,
    productId: item.productId,
    duration: subscription.attributes?.subscriptionPeriod,
    groupLevel: subscription.attributes?.groupLevel,
    anchorTerritory,
    anchorPrice: item.price,
    configuredTerritories: pricing.configuredTerritories,
    missingTerritories: pricing.missingTerritories,
  });
}

if (outputPath) fs.writeFileSync(outputPath, `${JSON.stringify(report, null, 2)}\n`);
console.log(JSON.stringify(report, null, 2));

async function ensureGroupLocalizations(groupId) {
  let versions = await listAll(`/v1/subscriptionGroups/${groupId}/versions`, { limit: "200" });
  let version = versions.find((item) => item.attributes?.state === "PREPARE_FOR_SUBMISSION");
  if (!version) {
    requireApply("create subscription group draft version");
    version = (await apiRequest("POST", "/v1/subscriptionGroupVersions", {
      body: {
        data: {
          type: "subscriptionGroupVersions",
          relationships: {
            subscriptionGroup: { data: { type: "subscriptionGroups", id: groupId } },
          },
        },
      },
    })).data;
  }

  const existing = await listAll(`/v1/subscriptionGroupVersions/${version.id}/localizations`, { limit: "200" });
  const names = {
    "en-US": "Support The Daily Zodiac",
    "es-ES": "Apoya The Daily Zodiac",
  };
  for (const [locale, name] of Object.entries(names)) {
    const localization = existing.find((item) => item.attributes?.locale === locale);
    if (localization) {
      if (localization.attributes?.name !== name) {
        fail(`Existing group localization ${locale} does not match the approved name.`);
      }
      continue;
    }
    requireApply(`create group localization ${locale}`);
    await apiRequest("POST", "/v2/subscriptionGroupLocalizations", {
      body: {
        data: {
          type: "subscriptionGroupLocalizations",
          attributes: { locale, name },
          relationships: {
            version: { data: { type: "subscriptionGroupVersions", id: version.id } },
          },
        },
      },
    });
  }
}

async function ensureSubscriptionLocalizations(subscriptionId, item) {
  let versions = await listAll(`/v1/subscriptions/${subscriptionId}/versions`, { limit: "200" });
  let version = versions.find((candidate) => candidate.attributes?.state === "PREPARE_FOR_SUBMISSION");
  if (!version) {
    requireApply(`create draft version for ${item.productId}`);
    version = (await apiRequest("POST", "/v1/subscriptionVersions", {
      body: {
        data: {
          type: "subscriptionVersions",
          relationships: {
            subscription: { data: { type: "subscriptions", id: subscriptionId } },
          },
        },
      },
    })).data;
  }

  const existing = await listAll(`/v1/subscriptionVersions/${version.id}/localizations`, { limit: "200" });
  for (const [locale, [name, description]] of Object.entries(item.localizations)) {
    const localization = existing.find((candidate) => candidate.attributes?.locale === locale);
    if (localization) {
      if (localization.attributes?.name !== name || localization.attributes?.description !== description) {
        fail(`Existing localization ${item.productId}/${locale} does not match the approved catalog.`);
      }
      continue;
    }
    requireApply(`create subscription localization ${item.productId}/${locale}`);
    await apiRequest("POST", "/v2/subscriptionLocalizations", {
      body: {
        data: {
          type: "subscriptionLocalizations",
          attributes: { locale, name, description },
          relationships: {
            version: { data: { type: "subscriptionVersions", id: version.id } },
          },
        },
      },
    });
  }
}

async function ensurePrices(subscriptionId, expectedAnchorPrice) {
  const existingPrices = await listAll(`/v1/subscriptions/${subscriptionId}/prices`, {
    include: "subscriptionPricePoint,territory",
    limit: "200",
  });
  const existingPointIds = new Set(existingPrices.map((price) =>
    price.relationships?.subscriptionPricePoint?.data?.id,
  ).filter(Boolean));

  const anchorPoints = await listAll(`/v1/subscriptions/${subscriptionId}/pricePoints`, {
    "filter[territory]": anchorTerritory,
    include: "territory",
    limit: "200",
  });
  const anchorPoint = anchorPoints.find((point) =>
    Number(point.attributes?.customerPrice) === Number(expectedAnchorPrice),
  );
  if (!anchorPoint) fail(`No ${anchorTerritory} price point ${expectedAnchorPrice} exists for ${subscriptionId}.`);

  const equalizedPoints = await listAll(`/v1/subscriptionPricePoints/${encodeURIComponent(anchorPoint.id)}/equalizations`, {
    include: "territory",
    limit: "200",
  });
  const desiredPoints = [anchorPoint, ...equalizedPoints];
  const uniquePoints = [...new Map(desiredPoints.map((point) => [
    point.relationships?.territory?.data?.id,
    point,
  ])).values()].filter((point) => point?.relationships?.territory?.data?.id);

  let created = 0;
  for (const point of uniquePoints) {
    if (existingPointIds.has(point.id)) continue;
    requireApply(`set ${point.relationships.territory.data.id} price for ${subscriptionId}`);
    await apiRequest("POST", "/v1/subscriptionPrices", {
      body: {
        data: {
          type: "subscriptionPrices",
          attributes: { startDate: null, preserveCurrentPrice: false },
          relationships: {
            subscription: { data: { type: "subscriptions", id: subscriptionId } },
            subscriptionPricePoint: { data: { type: "subscriptionPricePoints", id: point.id } },
          },
        },
      },
    });
    created += 1;
  }
  return {
    configuredTerritories: existingPointIds.size + created,
    missingTerritories: Math.max(0, uniquePoints.length - existingPointIds.size - created),
  };
}

function assertSubscription(subscription, item) {
  const attributes = subscription.attributes ?? {};
  if (attributes.productId !== item.productId) fail(`Unexpected product ID for ${item.referenceName}.`);
  if (attributes.subscriptionPeriod !== "ONE_MONTH") fail(`${item.productId} is not monthly.`);
  if (attributes.groupLevel !== 1) fail(`${item.productId} is not at the shared supporter level.`);
}

function requireApply(action) {
  if (!applyChanges) fail(`DRY_RUN_REQUIRES_CHANGE: ${action}`);
}

async function listAll(endpoint, query = {}) {
  const items = [];
  let next = new URL(`https://api.appstoreconnect.apple.com${endpoint}`);
  for (const [name, value] of Object.entries(query)) next.searchParams.set(name, value);
  while (next) {
    const response = await apiRequest("GET", next.pathname + next.search);
    items.push(...(response.data ?? []));
    next = response.links?.next ? new URL(response.links.next) : null;
  }
  return items;
}

async function apiRequest(method, endpoint, options = {}) {
  const url = endpoint.startsWith("http")
    ? new URL(endpoint)
    : new URL(`https://api.appstoreconnect.apple.com${endpoint}`);
  const response = await fetch(url, {
    method,
    headers: {
      Authorization: `Bearer ${createToken(auth)}`,
      ...(options.body ? { "Content-Type": "application/json" } : {}),
    },
    body: options.body ? JSON.stringify(options.body) : undefined,
  });
  const responseText = await response.text();
  const json = responseText ? JSON.parse(responseText) : {};
  if (!response.ok) {
    fail(`App Store Connect API failed ${method} ${url.pathname}: ${response.status} ${responseText}`);
  }
  return json;
}

function createToken({ keyId, issuerId, privateKey }) {
  const now = Math.floor(Date.now() / 1000);
  const header = base64url(JSON.stringify({ alg: "ES256", kid: keyId, typ: "JWT" }));
  const payload = base64url(JSON.stringify({
    iss: issuerId,
    aud: "appstoreconnect-v1",
    exp: now + 19 * 60,
    iat: now,
  }));
  const input = `${header}.${payload}`;
  const signer = crypto.createSign("SHA256");
  signer.update(input);
  signer.end();
  const signature = signer.sign({ key: privateKey, dsaEncoding: "ieee-p1363" });
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
