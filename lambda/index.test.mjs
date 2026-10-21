import assert from 'node:assert/strict';
import test from 'node:test';
import { handler } from './index.mjs';

test('returns the payload when failure is not requested', async () => {
  const payload = { hello: 'github', shouldFail: false };
  assert.deepEqual(await handler(payload), { ok: true, payload });
});

test('throws when the payload requests failure', async () => {
  await assert.rejects(
    handler({ shouldFail: true }),
    /Failure requested by payload/,
  );
});
