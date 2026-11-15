# SQL building blocks

Small Supabase/Postgres pieces that nearly every app needs. They are **copied into an app's own
`supabase/migrations`** (an applied migration is never edited, so nothing references this folder remotely).
The files here follow the same layout as an app (`migrations/`, `tests/`) so the shared test runner works on them:

```bash
SUPABASE_DIR=sql STUB=1 ../devops/.github/actions/supabase-sql-tests/run.sh "postgresql://postgres@localhost:5432/test"
```

| Migration | What it gives | Test |
|---|---|---|
| `20260101000001_touch_updated_at.sql` | `touch_updated_at()` trigger: the server sets `updated_at` (with `clock_timestamp()`, which sync cursors need) | `touch_updated_at.test.sql` |
| `20260101000002_forbid_column_change.sql` | `forbid_column_change('col')` trigger: an ownership column cannot be changed after insert  | `forbid_column_change.test.sql` |
| `20260101000003_invite_codes.sql` | `generate_invite_code(length)` without look-alike characters or pgcrypto, the `invite_attempt` table, `assert_invite_attempts_allowed` and `record_failed_invite_attempt` (rate limit against code guessing) | `invite_codes.test.sql` |

When copying, give the file a timestamp newer than the app's last migration, and add the app's own tests for
how it uses the helpers (which table gets which trigger).

Conventions these files follow: `set search_path = ''` on every function, `security definer` for anything that
writes sensitive tables, `revoke ... from public, anon, authenticated` on helpers clients must not call.
