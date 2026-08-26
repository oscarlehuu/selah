# Lectio Divina — Pray flow (locked)

> Structured worship time. Distinct from open Talk conversation.

## Four steps

| Step | Name | Timer default | UI |
|------|------|---------------|-----|
| 1 | **Read** | 2 min | Passage from plan or deep-linked verse; slow scroll, serif |
| 2 | **Reflect** | 2 min | Prompt: *“What word or phrase stays with you?”* |
| 3 | **Pray** | 2 min | FM-generated prayer if available; else user silent/text (no template fallback) |
| 4 | **Rest** | 1 min | Breathe animation, soft glow, no CTA pressure |

**Quick mode:** 5 min total — Rest shortened to 30s.

## Entry points

- Today → *“5 minutes with God”*
- Read → verse selected → Pray with context
- Tab Pray

## Close

- **Amen** button → gentle fade animation.
- Optional **Save to journal** (encrypt path).
- Analytics: `amen_tap`, `lectio_complete`.

## FM unavailable

Steps 1–2 and 4 work. Step 3: silent prayer prompt + timer only.

## Analytics

`pray_open`, `lectio_step_read`, `lectio_step_reflect`, `lectio_step_pray`, `lectio_step_rest`, `lectio_complete`, `amen_tap`.
