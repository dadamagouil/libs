// Run with Deno (`deno test typescript/edge-functions/`) or Node 22+ (`node --experimental-strip-types --test typescript/edge-functions/`).
import assert from "node:assert/strict";
import { test } from "node:test";
import { buildFcmMessage, b64url, parseServiceAccount } from "./fcm.ts";
import { json, jsonError, UUID } from "./http.ts";
import { makeEnvKey } from "./env.ts";

const envOf = (vars: Record<string, string>) => makeEnvKey((name) => vars[name]);

test("envKey reads a plain key", () => {
  assert.equal(envOf({ A: "sb_plain" })("A"), "sb_plain");
});

test("envKey reads the default key of a JSON value", () => {
  assert.equal(envOf({ A: '{"default":"sb_json"}' })("A"), "sb_json");
});

test("envKey falls back to the legacy name", () => {
  assert.equal(envOf({ SUPABASE_ANON_KEY: "legacy" })("SUPABASE_PUBLISHABLE_KEYS", "SUPABASE_ANON_KEY"), "legacy");
});

test("envKey keeps a broken JSON as a plain key", () => {
  assert.equal(envOf({ A: "{not json" })("A"), "{not json");
});

test("envKey fails clearly when nothing is set", () => {
  assert.throws(() => envOf({})("A", "B"), /Missing env: A \/ B/);
});

test("json sets the status and content type", async () => {
  const res = json({ ok: true }, 201);
  assert.equal(res.status, 201);
  assert.equal(res.headers.get("Content-Type"), "application/json");
  assert.deepEqual(await res.json(), { ok: true });
});

test("jsonError wraps the message", async () => {
  const res = jsonError("nope", 400);
  assert.equal(res.status, 400);
  assert.deepEqual(await res.json(), { error: "nope" });
});

test("UUID accepts a v4 and rejects other text", () => {
  assert.ok(UUID.test("3f2b8c1e-5a4d-4c8e-9b7a-1d2e3f4a5b6c"));
  assert.ok(!UUID.test("not-a-uuid"));
});

test("b64url has no padding and no +/ characters", () => {
  assert.equal(b64url("??>>"), "Pz8-Pg");
});

test("parseServiceAccount rejects a missing or incomplete secret", () => {
  assert.equal(parseServiceAccount(undefined), null);
  assert.equal(parseServiceAccount("{"), null);
  assert.equal(parseServiceAccount('{"project_id":"p"}'), null);
  assert.equal(parseServiceAccount('{"project_id":"p","client_email":"e","private_key":"k"}')?.project_id, "p");
});

test("an actionable reminder is data-only on Android and web", () => {
  for (const platform of ["android", "web"]) {
    const message = buildFcmMessage({ token: "t", platform }, "Title", "Body", { id: "1" }, true);
    assert.deepEqual(message.data, { id: "1", title: "Title", body: "Body" });
    assert.ok(!("notification" in message));
  }
});

test("iPhone always gets a classic notification", () => {
  const message = buildFcmMessage({ token: "t", platform: "ios" }, "Title", "Body", {}, true);
  assert.ok("notification" in message);
});
