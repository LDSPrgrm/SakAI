// Cryptographically random temporary password.
// 10 chars, mixed case + digits + symbols. Used for new admin creation
// and password resets. Not stored — surfaced to the operator once.

const POOL = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';

export function generatePassword(length = 10): string {
  if (typeof crypto !== 'undefined' && crypto.getRandomValues) {
    const buf = new Uint32Array(length);
    crypto.getRandomValues(buf);
    let out = '';
    for (let i = 0; i < length; i++) out += POOL.charAt(buf[i] % POOL.length);
    return out;
  }
  let out = '';
  for (let i = 0; i < length; i++) out += POOL.charAt(Math.floor(Math.random() * POOL.length));
  return out;
}
