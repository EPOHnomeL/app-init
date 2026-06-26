# app-init

A reusable kit for starting a new app the way I like to start one:
**T3 + Next.js (App Router) + Tailwind + TypeScript**, **pnpm**, **git** (+ a private **GitHub**
remote), deployed on **Vercel**, with a **Vitest** runner and a pinned Node version, my Claude Code
skills preinstalled, and an *understand-before-you-code* workflow that ends in a grill that writes
`CONTEXT.md` + ADRs.

- **Read [`app-init.md`](app-init.md)** — the full reproducible spec and step-by-step.
- **Run [`scripts/init.ps1`](scripts/init.ps1)** (Windows) or [`scripts/init.sh`](scripts/init.sh) — mechanical setup (local git, Node pin, prereq checks).
- Then, in Claude Code: `/setup-matt-pocock-skills` → `/grill-with-docs` → scaffold + Vitest + `.env.example` → `vercel link` + env sync → `/scaffold-knowledge-bank` → `/populate-knowledge-bank` → commit + `gh repo create`.

## Bootstrap a new project (copy-paste prompt)

In an **empty directory** for your new app, run `claude` and paste this prompt:

```text
Bootstrap this directory as a new app using the app-init kit at
https://github.com/EPOHnomeL/app-init

Do this:
1. Clone the kit into a temp dir and copy its .claude/ and scripts/ into the
   current directory (do NOT copy app-init.md, README.md, CLAUDE.md, or .git).
2. Read the kit's spec at
   https://raw.githubusercontent.com/EPOHnomeL/app-init/main/app-init.md
   and follow "The bootstrap, step by step" in order for THIS directory.
3. Run the mechanical setup (scripts/init.sh or scripts/init.ps1), then walk me
   through the interactive steps: /setup-matt-pocock-skills, then /grill-with-docs
   to decide DB (Convex vs Supabase) + auth, then scaffold per that ADR, wire up
   Vercel (+ Convex if chosen), stand up the knowledge bank, and finally commit
   and create the private GitHub remote.
Stop and ask me before any step that makes external changes (gh repo create,
vercel link/deploy, convex provisioning).
```

Locked skills (`/grill-with-docs`, etc.) can't be triggered by Claude — it'll prompt you to type
them, or run the equivalent interview itself. See [`app-init.md`](app-init.md#invocation-matrix--who-can-trigger-what).

**Database (Convex vs Supabase) and auth are decided in the grill**, recorded as ADRs — not guessed.
**Vercel** (host) and a private **GitHub** remote are baked in; on the Convex branch, deployment
splits (Vercel = frontend, Convex Cloud = backend).

## What's preconfigured
- [`.claude/settings.json`](.claude/settings.json) — enables the **ponytail** plugin for the repo.
- [`.claude/skills/`](.claude/skills/) — bundles **knowledge-bank** (`scaffold-` + `populate-`).
- Matt Pocock's engineering skills are expected at user scope (`~/.claude/skills`); see [`app-init.md`](app-init.md#installing-the-skills).
