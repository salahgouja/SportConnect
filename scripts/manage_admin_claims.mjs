#!/usr/bin/env node

import { createRequire } from 'node:module';
import process from 'node:process';

const require = createRequire(import.meta.url);
const admin = require('../functions/node_modules/firebase-admin');

const usage = `
Usage:
  node scripts/manage_admin_claims.mjs <uid> <admin|support|refunds|clear|show>

Examples:
  node scripts/manage_admin_claims.mjs abc123 admin
  node scripts/manage_admin_claims.mjs abc123 support
  node scripts/manage_admin_claims.mjs abc123 refunds
  node scripts/manage_admin_claims.mjs abc123 clear
`.trim();

const [uid, mode] = process.argv.slice(2);

if (!uid || !mode) {
  console.error(usage);
  process.exit(1);
}

const supportedModes = new Set(['admin', 'support', 'refunds', 'clear', 'show']);
if (!supportedModes.has(mode)) {
  console.error(`Unsupported mode: ${mode}\n\n${usage}`);
  process.exit(1);
}

admin.initializeApp();

const user = await admin.auth().getUser(uid);
const claims = { ...(user.customClaims ?? {}) };

if (mode === 'show') {
  console.log(JSON.stringify({ uid, claims }, null, 2));
  process.exit(0);
}

if (mode === 'clear') {
  delete claims.admin;
  delete claims.support;
  delete claims.refunds;
  if (claims.role === 'admin' || claims.role === 'support') {
    delete claims.role;
  }
} else if (mode === 'admin') {
  claims.admin = true;
  claims.role = 'admin';
} else if (mode === 'support') {
  claims.support = true;
  claims.role = 'support';
} else if (mode === 'refunds') {
  claims.refunds = true;
}

await admin.auth().setCustomUserClaims(uid, claims);

console.log(
  JSON.stringify(
    {
      uid,
      mode,
      claims,
      nextStep: 'Have the user sign out and sign back in.',
    },
    null,
    2,
  ),
);
