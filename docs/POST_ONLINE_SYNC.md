# Post-Online Sync Protocol

This document specifies endpoints and data schemas for reconciling offline data (votes/messages) when a node goes online.

## Endpoints (userver)

- POST /api/sync/v1/polls/summary
  - Body: PollSummary
  - Response: { ok: bool }

- GET /api/sync/v1/polls/:pollId
  - Response: AuthoritativePoll

- POST /api/sync/v1/messages/batch
  - Body: MessageBatch
  - Response: { ok: bool, accepted: int }

- GET /api/sync/v1/cursor
  - Response: { cursor: string }

- POST /api/sync/v1/cursor
  - Body: { cursor: string }
  - Response: { ok: bool }

## Schemas

PollSummary:
- pollId: string
- tally: { [option: string]: number }
- quorum: number
- closedAt: string (ISO8601)
- signer: string (base64 public key)
- signature: string (base64 Ed25519)

AuthoritativePoll:
- pollId: string
- options: string[]
- votes: { [option: string]: number }
- proof?: string (merkle root or chain proof)
- updatedAt: string

MessageBatch:
- entries: MessageEntry[]

MessageEntry:
- id: string
- from: string
- to: string
- ts: string
- hash: string (sha256 of payload)

Security:
- All summaries signed by Ed25519.
- Server validates signature and optionally proof.

Idempotency:
- Use cursor to avoid duplicates; server treats repeated batches as no-op.
