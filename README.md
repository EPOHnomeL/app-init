# app-init

A reusable kit for starting a new app the way I like to start one:
**T3 + Next.js (App Router) + Tailwind + TypeScript**, **pnpm**, **git**, with my Claude Code
skills preinstalled and an *understand-before-you-code* workflow that ends in a grill that writes
`CONTEXT.md` + ADRs.

- **Read [`app-init.md`](app-init.md)** — the full reproducible spec and step-by-step.
- **Run [`scripts/init.ps1`](scripts/init.ps1)** (Windows) or [`scripts/init.sh`](scripts/init.sh) — mechanical setup.
- Then, in Claude Code: `/setup-matt-pocock-skills` → `/grill-with-docs` → scaffold → `/scaffold-knowledge-bank` → `/populate-knowledge-bank`.

**Database (Convex vs Supabase) and auth are decided in the grill**, recorded as ADRs — not guessed.

## What's preconfigured
- [`.claude/settings.json`](.claude/settings.json) — enables the **ponytail** plugin for the repo.
- [`.claude/skills/`](.claude/skills/) — bundles **knowledge-bank** (`scaffold-` + `populate-`).
- Matt Pocock's engineering skills are expected at user scope (`~/.claude/skills`); see [`app-init.md`](app-init.md#installing-the-skills).
