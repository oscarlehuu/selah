# Vibecode workflow — Selah (locked for agents)

## Loop

1. Discuss / brainstorm with client (Oscar) — lock in `AGENTS.md` + spec docs
2. Follow **`plans/251124-final-product-handoff/plan.md`** — one phase at a time to shippable v1
3. **TDD:** failing test or matrix row per phase (`docs/paywall-tdd-spec.md` + phase tests)
4. Implement minimal code to pass phase gate
5. **XcodeBuildMCP:** build → run sim → `snapshot_ui` / navigate flows — client does not run tests
6. Client simulator pass + feedback at **phase boundary** (not per tiny ticket)

## Models

| Role | Model |
|------|-------|
| Subagents (Cursor Task) | **Auto** or **Grok 4.6 High** only |
| Local review | `grok build`, `codex cli` (gpt5.6-sol) |

## Testing tools

| Tool | Use |
|------|-----|
| XCTest | Unit + gate logic |
| `Selah.storekit` | Local purchase tests |
| XcodeBuildMCP | Simulator navigation, screenshots, UI snapshots |
| RC sandbox | Final purchase verification |

Session defaults (set once per agent session):

```text
projectPath: Selah/Selah.xcodeproj
scheme: Selah
simulatorName: iPhone 17 Pro
```

## Paywall priority

Paywall tests and gate logic **before** main feature screens. Monetization regressions block merge.

## Client role

Oscar = product client. Final human check on simulator UX only. Agents own TDD + MCP navigation.
