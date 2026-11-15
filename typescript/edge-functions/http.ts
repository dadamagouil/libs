// Small HTTP helpers for Edge Functions.

/** A JSON response. */
export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

/** The error answer used everywhere: `{ "error": "<message>" }`. */
export function jsonError(message: string, status: number): Response {
  return json({ error: message }, status);
}

/**
 * The caller's `Authorization` header, or null when absent.
 *
 * Why forward it: a Supabase client built with this header acts AS the user, so row level security and
 * `auth.uid()` apply. Never swap it for the service role key to "make it work".
 */
export function authorizationOf(req: Request): string | null {
  return req.headers.get("Authorization");
}

/** UUID shape check (any version). */
export const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
