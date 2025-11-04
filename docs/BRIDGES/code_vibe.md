# CODE+VIBE Protocol (Draft)

Purpose: transport code artifacts + context + intent over Mesh for AI/agent collaboration.

Sections:
- Header: version, sender, signature
- Content: files (path, bytes), metadata (lang, hashes), vibe (tags, sentiment)
- Security: AES-GCM envelope + X25519 key exchange
- Prioritization: map to Mesh message priority for reliability
