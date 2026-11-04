const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { test } = require('node:test');

const root = path.resolve(__dirname, '..');
const claude = JSON.parse(fs.readFileSync(path.join(root, '.mcp.json'), 'utf8'))
  .mcpServers['google-developer-knowledge'];
const pi = JSON.parse(fs.readFileSync(path.join(root, '.pi/mcp.json'), 'utf8'))
  .mcpServers['google-developer-knowledge'];
assert.ok(pi.headers['X-Goog-Api-Key'].startsWith('!'));

const cases = [
  { name: 'quoted key', content: 'DEVELOPER_KNOWLEDGE_API_KEY="test-key-$&"\n', expected: 'test-key-$&' },
  { name: 'missing variable', content: 'UNRELATED=test\n' },
  { name: 'empty key', content: 'DEVELOPER_KNOWLEDGE_API_KEY=\n' },
  { name: 'whitespace key', content: 'DEVELOPER_KNOWLEDGE_API_KEY="   "\n' },
  { name: 'missing file' },
  { name: 'environment precedence', content: 'DEVELOPER_KNOWLEDGE_API_KEY=file-key\n', envKey: 'environment-key', expected: 'environment-key' },
];

for (const [client, command] of [
  ['Claude Code', claude.headersHelper],
  ['Pi', pi.headers['X-Goog-Api-Key'].slice(1)],
]) {
  for (const scenario of cases) {
    test(`${client}: ${scenario.name}`, () => {
      const fixture = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp-headers-test-'));
      try {
        fs.cpSync(__dirname, path.join(fixture, 'scripts'), { recursive: true });
        if (scenario.content !== undefined) {
          fs.writeFileSync(path.join(fixture, '.env'), scenario.content);
        }
        const env = { ...process.env };
        delete env.DEVELOPER_KNOWLEDGE_API_KEY;
        if (scenario.envKey) env.DEVELOPER_KNOWLEDGE_API_KEY = scenario.envKey;
        const result = spawnSync(command, {
          cwd: fixture,
          env,
          shell: true,
          encoding: 'utf8',
          timeout: 10000,
        });
        if (scenario.expected !== undefined) {
          assert.equal(result.status, 0, result.stderr);
          const value = client === 'Claude Code'
            ? JSON.parse(result.stdout)['X-Goog-Api-Key']
            : result.stdout;
          assert.equal(value, scenario.expected);
          assert.equal(result.stderr, '');
        } else {
          assert.notEqual(result.status, 0);
          assert.equal(result.stdout, '');
          assert.match(result.stderr, /DEVELOPER_KNOWLEDGE_API_KEY|\.env/);
        }
      } finally {
        fs.rmSync(fixture, { recursive: true, force: true });
      }
    });
  }
}
