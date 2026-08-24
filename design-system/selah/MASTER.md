# Design System Master File — Selah

> **LOGIC:** When building a specific page, first check `design-system/selah/pages/[page-name].md`.
> If that file exists, its rules **override** this Master file.

**Project:** Selah  
**Direction:** Sunday Light (locked in AGENTS.md)  
**North star:** Sunday morning church / retreat garden at golden hour. Joy, peace, welcome. Not guilt, shame, or gothic dark.

---

## Global Rules

### Color Palette (Sunday Light)

| Role | Hex | CSS Variable | Notes |
|------|-----|--------------|-------|
| Primary | `#5B8DEF` | `--primary` | Soft sky blue |
| Primary deep | `#3D6FD4` | `--primary-deep` | Buttons, active nav |
| Primary soft | `#EAF1FD` | `--primary-soft` | Selected states |
| Accent | `#C49A3C` | `--accent` | Warm gold — CTAs, streak |
| Accent deep | `#A67C2E` | `--accent-deep` | Gold gradient end |
| Accent soft | `#FBF5E6` | `--accent-soft` | Highlight backgrounds |
| Background | `#FAF7F2` | `--bg` | Warm off-white (not pure #FFF) |
| Background warm | `#F5EDE3` | `--bg-warm` | Secondary surfaces |
| Surface | `#FFFFFF` | `--surface` | Cards |
| Text | `#2C2825` | `--text` | Warm charcoal |
| Text muted | `#6B6560` | `--text-muted` | Body secondary |
| Text soft | `#9A938C` | `--text-soft` | Labels, captions |
| Border | `rgba(44,40,37,0.08)` | `--border` | Subtle dividers |

**Avoid:** Black confession booth, blood red, skulls, harsh OLED black as default, purple "spiritual dark" palette.

### Typography

| Role | Font | Usage |
|------|------|-------|
| Display | **Playfair Display** | Verse quotes, screen titles, brand |
| Body | **Inter** | UI, buttons, labels, chat |

- Base body: 16px, line-height 1.5–1.55
- Verse serif: italic Playfair, 1.125–1.375rem
- Labels: 0.6875rem uppercase, letter-spacing 0.08em

### Spacing (8dp rhythm)

| Token | Value |
|-------|-------|
| `--space-xs` | 4px |
| `--space-sm` | 8px |
| `--space-md` | 16px |
| `--space-lg` | 24px |
| `--space-xl` | 32px |
| `--radius` | 16px |
| `--radius-lg` | 24px |

### Shadows

| Level | Value |
|-------|-------|
| `--shadow-sm` | `0 2px 8px rgba(44,40,37,0.06)` |
| `--shadow-md` | `0 8px 32px rgba(44,40,37,0.08)` |

### Motion

- Micro-interactions: 150–300ms, `cubic-bezier(0.22, 1, 0.36, 1)`
- Breathe animation on hero glow (4–5s, subtle)
- Respect `prefers-reduced-motion`

---

## Style Guidelines

**Style:** Soft UI Evolution + Sunday Light sanctuary

**Keywords:** Warm light, sky blue, soft gold, editorial serif, peaceful, joyful, private room with warm light

**Icons:** Lucide-style SVG stroke icons (1.75px). **No emoji as nav/icons.**

**Effects:** Soft radial gradients, glass tab bar (`backdrop-filter: blur(16px)`), subtle card borders, gold glow ring on welcome

---

## Component Specs

### Primary Button
- Background: `--primary-deep` or gold gradient for hero CTAs
- Padding: 16px 24px, radius 16px
- Shadow on primary: `0 4px 16px rgba(61,111,212,0.3)`
- Press: `scale(0.98)`, no layout shift

### Tab Bar (iOS)
- Max 5 items, icon + label
- Active: `--primary-deep` color
- Height ~82px with safe area
- Blur background, top border

### Cards
- White surface, 1px border, `--shadow-sm`
- Verse cards: Playfair italic

### Touch
- Min target 44×44pt
- Quiz/mood cards: full-width tap, selected = blue border + soft fill

---

## Anti-Patterns (Do NOT Use)

- Emojis as structural icons
- Dark mode as brand identity (Sunday Light is locked)
- Red shame UI for streaks
- Black confession booth aesthetic
- Pure white `#FFFFFF` as page background
- Instant 0ms state changes
- Layout-shifting hover transforms

---

## Pre-Delivery Checklist

- [ ] SVG icons only (consistent stroke)
- [ ] Playfair + Inter loaded
- [ ] Contrast ≥4.5:1 on body text
- [ ] Touch targets ≥44pt
- [ ] Safe areas for tab bar / CTAs
- [ ] `prefers-reduced-motion` respected
- [ ] One primary CTA per screen
- [ ] Grace tone in-app (onboarding may agitate issue)
