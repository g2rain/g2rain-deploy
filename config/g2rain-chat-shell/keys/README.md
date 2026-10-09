# g2rain-chat-shell OpenResty keys

Runtime mount: `./config/g2rain-chat-shell/keys` → `/usr/local/openresty/nginx/lua/keys`.

Required by shell Lua (DER):
- `private-key.der` / `public-key.der` — Application-DPoP signing
- `iam-key-id.txt` — kid
- `iam-public-key.pem` — IAM public key for Shell JWT verify (not the Application-DPoP key)

`public-key.pem` is kept for Basis `application.public_key` registration.
Rotate production keys outside Git when possible.
