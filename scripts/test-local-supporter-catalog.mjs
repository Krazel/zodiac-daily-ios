import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const read = (relativePath) => fs.readFileSync(path.join(projectRoot, relativePath), "utf8");

const expectedProductIDs = [
  "com.krazel.zodiacdaily.support.monthly.099",
  "com.krazel.zodiacdaily.support.monthly.299",
  "com.krazel.zodiacdaily.support.monthly.499",
  "com.krazel.zodiacdaily.support.monthly.999",
  "com.krazel.zodiacdaily.support.monthly.1499",
  "com.krazel.zodiacdaily.support.monthly.2999",
  "com.krazel.zodiacdaily.support.monthly.50",
];

const appConfiguration = read("ZodiacDaily/App/AppConfiguration.swift");
const configuredProductIDs = [
  ...appConfiguration.matchAll(/"(com\.krazel\.zodiacdaily\.support\.monthly\.[^"]+)"/g),
].map((match) => match[1]);
assert.deepEqual(configuredProductIDs, expectedProductIDs, "The local StoreKit catalog must keep the canonical order.");

const supportView = read("ZodiacDaily/Features/Settings/SupportSectionView.swift");
for (const price of ["0,99 €", "3,00 €", "5,00 €", "10,00 €", "15,00 €", "30,00 €", "49,99 €"]) {
  assert.ok(supportView.includes(`"${price}"`), `Missing Spanish QA price: ${price}`);
}
for (const price of ["$0.99", "$3.00", "$5.00", "$10.00", "$15.00", "$30.00", "$49.99"]) {
  assert.ok(supportView.includes(`"${price}"`), `Missing English QA price: ${price}`);
}
assert.ok(supportView.includes('localized("support.tier.monthly")'), "The common supporter title is missing.");
assert.ok(!supportView.includes("support.tier.kind"), "Legacy three-tier title remains in the support view.");
assert.ok(!supportView.includes("support.tier.generous"), "Legacy three-tier title remains in the support view.");

const strings = JSON.parse(read("ZodiacDaily/Resources/Localizable.xcstrings"));
const tier = strings.strings["support.tier.monthly"];
assert.equal(tier.localizations.en.stringUnit.value, "Monthly Supporter");
assert.equal(tier.localizations.es.stringUnit.value, "Apoyo mensual");
assert.ok(!strings.strings["support.tier.kind"], "Legacy Kind Supporter localization remains.");
assert.ok(!strings.strings["support.tier.generous"], "Legacy Generous Supporter localization remains.");

console.log("Local supporter catalog: 7 canonical monthly levels verified.");
