import { verifyFirebaseToken } from './src/index.js';
import assert from 'node:assert';
const b64 = (o) => Buffer.from(typeof o === 'string' ? o : JSON.stringify(o)).toString('base64url');
const { publicKey, privateKey } = await crypto.subtle.generateKey({ name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048, publicExponent: new Uint8Array([1,0,1]), hash: 'SHA-256' }, true, ['sign','verify']);
const jwk = { ...(await crypto.subtle.exportKey('jwk', publicKey)), kid: 'k1' };
const jwks = async () => ({ keys: [jwk] });
async function mk(claims, alg = 'RS256', kid = 'k1') {
  const h = b64({ alg, kid }), p = b64(claims);
  const s = Buffer.from(await crypto.subtle.sign('RSASSA-PKCS1-v1_5', privateKey, Buffer.from(`${h}.${p}`))).toString('base64url');
  return `${h}.${p}.${s}`;
}
const now = 1000000;
const good = { aud: 'arewecookin', iss: 'https://securetoken.google.com/arewecookin', sub: 'u1', exp: now + 100, iat: now - 10 };
assert.equal(await verifyFirebaseToken(await mk(good), 'arewecookin', now, jwks), 'u1');
assert.equal(await verifyFirebaseToken(await mk({ ...good, aud: 'other' }), 'arewecookin', now, jwks), null, 'wrong project');
assert.equal(await verifyFirebaseToken(await mk({ ...good, exp: now - 1 }), 'arewecookin', now, jwks), null, 'expired');
assert.equal(await verifyFirebaseToken(await mk(good, 'RS256', 'zzz'), 'arewecookin', now, jwks), null, 'unknown kid');
const t = await mk(good); const bad = t.slice(0, -4) + 'AAAA';
assert.equal(await verifyFirebaseToken(bad, 'arewecookin', now, jwks), null, 'bad signature');
assert.equal(await verifyFirebaseToken('garbage', 'arewecookin', now, jwks), null);
console.log('worker auth tests passed');
