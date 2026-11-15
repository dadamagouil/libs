// Reading Supabase keys from an Edge Function's environment.

/** Returns a reader of environment variables; injectable so the logic can be tested without Deno. */
export function makeEnvKey(get: (name: string) => string | undefined) {
  /**
   * First non-empty variable among `names`.
   *
   * Why: Supabase injects the keys either as JSON (`{"default":"sb_..."}`) or as plain text, and older projects
   * still use the legacy names (SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY). Both forms are accepted, and
   * the caller lists the new name first, then the legacy one.
   */
  return function envKey(...names: string[]): string {
    for (const name of names) {
      const raw = get(name);
      if (!raw) continue;
      if (raw.trim().startsWith("{")) {
        try {
          const parsed = JSON.parse(raw) as Record<string, string>;
          const key = parsed.default ?? Object.values(parsed)[0];
          if (key) return key;
        } catch (_) { /* not JSON after all: a plain key */ }
      }
      return raw;
    }
    throw new Error(`Missing env: ${names.join(" / ")}`);
  };
}

/** `envKey` bound to the Deno environment (what Edge Functions use). */
// deno-lint-ignore no-explicit-any
export const envKey = makeEnvKey((name) => (globalThis as any).Deno?.env.get(name));
