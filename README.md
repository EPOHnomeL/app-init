# app-init

A reusable kit for starting a new app the way I like to start one:
**T3 + Next.js (App Router) + Tailwind + TypeScript**, **pnpm**, **git** (+ a private **GitHub**
remote), deployed on **Vercel**, with a **Vitest** runner and a pinned Node version, my Claude Code
skills preinstalled, and an *understand-before-you-code* workflow that ends in a grill that writes
`CONTEXT.md` + ADRs.

- **Read [`app-init.md`](app-init.md)** — the full reproducible spec and step-by-step.
- **Run [`scripts/init.ps1`](scripts/init.ps1)** (Windows) or [`scripts/init.sh`](scripts/init.sh) — mechanical setup (local git, Node pin, prereq checks).
- Then, in Claude Code: `/setup-matt-pocock-skills` → `/grill-with-docs` → scaffold + Vitest + `.env.example` → `vercel link` + env sync → `/scaffold-knowledge-bank` → `/populate-knowledge-bank` → commit + `gh repo create`.

**Database (Convex vs Supabase) and auth are decided in the grill**, recorded as ADRs — not guessed.
**Vercel** (host) and a private **GitHub** remote are baked in; on the Convex branch, deployment
splits (Vercel = frontend, Convex Cloud = backend).

## What's preconfigured
- [`.claude/settings.json`](.claude/settings.json) — enables the **ponytail** plugin for the repo.
- [`.claude/skills/`](.claude/skills/) — bundles **knowledge-bank** (`scaffold-` + `populate-`).
- Matt Pocock's engineering skills are expected at user scope (`~/.claude/skills`); see [`app-init.md`](app-init.md#installing-the-skills).
