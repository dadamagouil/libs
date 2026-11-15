# Edge Function helpers (Deno)

| File | Purpose |
|---|---|
| `env.ts` | `envKey(...names)`: reads a Supabase key given either as JSON (`{"default":"sb_..."}`) or as plain text, with the legacy name as fallback. `makeEnvKey(get)` is the testable form. |
| `http.ts` | `json`, `jsonError`, `authorizationOf` (forward the caller's header so RLS applies), `UUID` |
| `fcm.ts` | Firebase Cloud Messaging HTTP v1: `parseServiceAccount`, `fcmAccessToken`, `buildFcmMessage` (data-only for actionable reminders on Android and web), `sendFcm` (reports stale tokens so the caller deletes them) |

Copy the folder into `supabase/functions/_shared/` of an app (Supabase bundles `_shared`) and import with a
relative path: `import { envKey } from "../_shared/env.ts";`.

Tests: `node --experimental-strip-types --test typescript/edge-functions/edge_functions_test.ts` (or `deno test`).
