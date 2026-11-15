// Firebase Cloud Messaging (HTTP v1) from an Edge Function.
// Needed secret: FIREBASE_SERVICE_ACCOUNT (the whole service account JSON). Without it, push is skipped and the
// rest of the function keeps working.

export type ServiceAccount = { project_id: string; client_email: string; private_key: string };

/** base64url (RFC 7515) of a string or bytes. */
export function b64url(data: ArrayBuffer | string): string {
  const bytes = typeof data === "string" ? new TextEncoder().encode(data) : new Uint8Array(data);
  return btoa(String.fromCharCode(...bytes)).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

/** Parses the secret; null when it is absent or unreadable (push is then skipped). */
export function parseServiceAccount(raw: string | undefined): ServiceAccount | null {
  if (!raw) return null;
  try {
    const sa = JSON.parse(raw) as ServiceAccount;
    return sa.project_id && sa.client_email && sa.private_key ? sa : null;
  } catch (_) {
    return null;
  }
}

/** OAuth access token for FCM, obtained with a signed JWT (valid one hour; reuse it within one run). */
export async function fcmAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const unsigned = `${b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }))}.${
    b64url(JSON.stringify({
      iss: sa.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    }))
  }`;

  const der = Uint8Array.from(
    atob(sa.private_key.replace(/-----[A-Z ]+-----/g, "").replace(/\s/g, "")),
    (c) => c.charCodeAt(0),
  );
  const key = await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned));

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${b64url(signature)}`,
    }),
  });
  if (!res.ok) throw new Error(`FCM auth failed: ${res.status} ${await res.text()}`);
  return (await res.json()).access_token;
}

export type PushTarget = { token: string; platform: string };

/**
 * The FCM message for one device.
 *
 * With `actionable` (a reminder with a "Done" button) Android and the web get a DATA-ONLY message: the app or the
 * service worker draws the notification itself, with its button. iPhone always gets a classic notification.
 */
export function buildFcmMessage(
  target: PushTarget,
  title: string,
  body: string,
  data: Record<string, string>,
  actionable = false,
  androidChannelId = "reminders",
) {
  const dataOnly = actionable && (target.platform === "android" || target.platform === "web");
  return dataOnly
    ? { token: target.token, data: { ...data, title, body }, android: { priority: "HIGH" } }
    : {
      token: target.token,
      notification: { title, body },
      data,
      android: { priority: "HIGH", notification: { channel_id: androidChannelId } },
      apns: { payload: { aps: { sound: "default" } } },
    };
}

export type SendResult = "sent" | "unregistered" | "failed";

/**
 * Sends one message. "unregistered" means the device token is stale: the caller deletes it from its
 * `device_token` table.
 */
export async function sendFcm(
  sa: ServiceAccount,
  accessToken: string,
  message: ReturnType<typeof buildFcmMessage>,
): Promise<SendResult> {
  const res = await fetch(`https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Authorization: `Bearer ${accessToken}` },
    body: JSON.stringify({ message }),
  });
  if (res.ok) return "sent";
  const err = await res.text();
  if (res.status === 404 || err.includes("UNREGISTERED")) return "unregistered";
  console.error("FCM error", res.status, err);
  return "failed";
}
