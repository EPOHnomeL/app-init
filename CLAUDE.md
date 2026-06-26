# CLAUDE.md

Guidance for Claude Code working in this repo. This is the **app-init kit** — a reusable bootstrap
for new T3 / Next.js / Tailwind / pnpm apps. See [`app-init.md`](app-init.md) for the full spec and
the step-by-step bootstrap order.

## Agent skills

### Issue tracker

Issues & PRDs live as local markdown under `.scratch/<feature-slug>/` (no remote yet). See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical five-role vocabulary, unchanged (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Skill invocation protocol

Some Matt Pocock skills are locked with `disable-model-invocation: true` — Claude **cannot** trigger
them; the **user** must type the slash command. Handle them like this:

| Skill | AI-invocable? | How to run |
| --- | --- | --- |
| `setup-matt-pocock-skills` | no (locked) | prompt-driven — Claude executes its process manually, or user types `/setup-matt-pocock-skills` |
| `grill-with-docs`, `grill-me` | no (locked) | **user types the slash command**; or Claude runs an equivalent relentless interview and writes the ADRs/CONTEXT.md itself |
| `to-prd`, `to-issues`, `triage`, `prototype`, `handoff`, `improve-codebase-architecture` | no (locked) | user types the slash command |
| `scaffold-knowledge-bank`, `populate-knowledge-bank`, `tdd`, `learn`, ponytail (`ponytail`, `ponytail-review`, …) | **yes** | Claude can invoke directly |

Rule: if a needed skill is locked, either prompt the user to invoke it step by step, or — when it's
prompt-driven and safe — execute its documented process directly. Never strip the lock from the
user's global skills.
