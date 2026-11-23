// Photo upload/serve for the community feed.
// POST /upload  (Authorization: Bearer <Firebase ID token>, body = image/jpeg|png|webp) -> {"key": "..."}
// GET  /p/<key> -> the image (public, cached)
const JWKS_URL = 'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';
const TYPES = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp' };

function b64urlToBytes(s) {
  s = s.replace(/-/g, '+').replace(/_/g, '/');
  while (s.length % 4) s += '=';
  return Uint8Array.from(atob(s), (c) => c.charCodeAt(0));
}

// Returns the Firebase uid, or null when the token is not valid for this project.
export async function verifyFirebaseToken(token, project, now = Date.now() / 1000, fetchJwks = defaultJwks) {
  try {
    const [h, p, sig] = token.split('.');
    if (!h || !p || !sig) return null;
    const header = JSON.parse(new TextDecoder().decode(b64urlToBytes(h)));
    const claims = JSON.parse(new TextDecoder().decode(b64urlToBytes(p)));
    if (header.alg !== 'RS256') return null;
    if (claims.aud !== project || claims.iss !== `https://securetoken.google.com/${project}`) return null;
    if (!claims.sub || claims.exp < now || claims.iat > now + 300) return null;
    const jwks = await fetchJwks();
    const jwk = jwks.keys.find((k) => k.kid === header.kid);
    if (!jwk) return null;
    const key = await crypto.subtle.importKey('jwk', jwk, { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['verify']);
    const ok = await crypto.subtle.verify('RSASSA-PKCS1-v1_5', key, b64urlToBytes(sig), new TextEncoder().encode(`${h}.${p}`));
    return ok ? claims.sub : null;
  } catch {
    return null;
  }
}

async function defaultJwks() {
  const r = await fetch(JWKS_URL, { cf: { cacheTtl: 3600, cacheEverything: true } });
  return r.json();
}

function sniff(bytes) {
  if (bytes[0] === 0xff && bytes[1] === 0xd8) return 'image/jpeg';
  if (bytes[0] === 0x89 && bytes[1] === 0x50 && bytes[2] === 0x4e && bytes[3] === 0x47) return 'image/png';
  if (bytes[0] === 0x52 && bytes[1] === 0x49 && bytes[8] === 0x57 && bytes[9] === 0x45) return 'image/webp';
  return null;
}

export default {
  async fetch(req, env) {
    const url = new URL(req.url);
    const cors = { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'Authorization, Content-Type' };
    if (req.method === 'OPTIONS') return new Response(null, { headers: cors });

    if (req.method === 'GET' && url.pathname.startsWith('/p/')) {
      const obj = await env.PHOTOS.get(decodeURIComponent(url.pathname.slice(3)));
      if (!obj) return new Response('Not found', { status: 404, headers: cors });
      return new Response(obj.body, {
        headers: { ...cors, 'Content-Type': obj.httpMetadata?.contentType ?? 'image/jpeg', 'Cache-Control': 'public, max-age=31536000, immutable' },
      });
    }

    if (req.method === 'POST' && url.pathname === '/upload') {
      const auth = req.headers.get('Authorization') ?? '';
      const uid = auth.startsWith('Bearer ') ? await verifyFirebaseToken(auth.slice(7), env.FIREBASE_PROJECT) : null;
      if (!uid) return new Response('Unauthorized', { status: 401, headers: cors });
      const max = Number(env.MAX_BYTES);
      const len = Number(req.headers.get('Content-Length') ?? 0);
      if (!len || len > max) return new Response('Bad size', { status: 413, headers: cors });
      const bytes = new Uint8Array(await req.arrayBuffer());
      if (bytes.length > max) return new Response('Bad size', { status: 413, headers: cors });
      const type = sniff(bytes);
      if (!type) return new Response('Unsupported type', { status: 415, headers: cors });
      const key = `${uid}/${Date.now()}-${crypto.randomUUID().slice(0, 8)}.${TYPES[type]}`;
      await env.PHOTOS.put(key, bytes, { httpMetadata: { contentType: type } });
      return new Response(JSON.stringify({ key }), { headers: { ...cors, 'Content-Type': 'application/json' } });
    }
    return new Response('Not found', { status: 404, headers: cors });
  },
};
