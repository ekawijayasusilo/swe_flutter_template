const assert = require('node:assert/strict');

const key = process.env.DEVELOPER_KNOWLEDGE_API_KEY;
assert.ok(key?.trim(), 'Set DEVELOPER_KNOWLEDGE_API_KEY in .env');

// Claude Code expects a JSON header map; Pi expects the header value alone.
process.stdout.write(
  process.argv[2] === '--value'
    ? key
    : JSON.stringify({ 'X-Goog-Api-Key': key }),
);
