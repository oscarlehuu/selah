# Journal encryption & CloudKit sync (locked v1)

> Encrypted journal on device + **CloudKit ciphertext sync** from day one. Keychain + Face ID.

## Threat model (v1)

| Protect against | Approach |
|-----------------|----------|
| Casual device access | Face ID / passcode before decrypt |
| Cloud backup sniffing | Only **ciphertext** in CloudKit + SwiftData |
| Selah servers | No journal on our servers |

## Crypto

| Piece | Detail |
|-------|--------|
| Algorithm | AES-256-GCM per entry |
| Master key | 256-bit random, **Keychain** `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` |
| Per-entry | Random IV, store `ciphertext + iv + tag` |
| Plaintext | Never written to disk or CloudKit |

## Face ID

- `LAContext` before: open journal list, read entry, save new entry.
- Settings: “Require Face ID for journal” default **on**.
- Fallback: device passcode via LocalAuthentication.

## CloudKit (v1 — locked)

| Field | Rule |
|-------|------|
| Sync payload | **Ciphertext blob + metadata** (date, theme tag, entry UUID) |
| Master key | **Does not sync** — each device has own key OR derive from secure enclave pattern |
| Default | `journalCloudSyncEnabled = true` after first save (user can disable in Settings) |

**Multi-device note:** With per-device keys, CloudKit syncs ciphertext that only **that device** can decrypt unless we add key agreement v2. **v1 lock:** sync is **backup-oriented** (same Apple ID, restore/new device may need re-auth + optional key export v2). Document in Settings: *“Journal is encrypted. Sync keeps encrypted copies in your iCloud account.”*

If same-device restore: Keychain + CloudKit restore together.

## SwiftData model `JournalEntry`

- `id`, `createdAt`, `encryptedPayload`, `iv`, `tag`, `previewHint` (optional 0–20 char non-sensitive label)
- Talk/Pray saves flow through encrypt → store.

## Talk auto-delete

Journal saves are **independent** — never deleted by Talk session wipe.

## Crisis

Never persist crisis-flagged message content to journal.

## Legal

Align with `docs/site/privacy.html` — spiritual content local + encrypted iCloud optional.
