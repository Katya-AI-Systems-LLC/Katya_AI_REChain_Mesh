# Additional Bridges (Notes)

- NEAR: ed25519, Borsh encoding
- Solana: ed25519, Borsh, transaction message v0 with address table lookups
- Tezos: ed25519/secp256k1/p256, Micheline encoding

Approach: offline signing, mesh gossiping, online submission adapters.
