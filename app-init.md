# app-init — reproducible project bootstrap kit

A **reusable kit** for spinning up a new app exactly the way I like to start one:
a **T3 + Next.js (App Router) + Tailwind + TypeScript** app, **pnpm**, **git**, my
**skills** preinstalled (Matt Pocock's engineering skills, ponytail, knowledge‑bank),
and an **understand‑before‑you‑code** workflow that ends in a *grill with docs* —
a relentless interview that writes `CONTEXT.md` + ADRs for the specific app you're building.

> This file is the spec. Copy this folder to start a new project, then follow
> [The bootstrap, step by step](#the-bootstrap-step-by-step). The scripts in
> [`scripts/`](scripts/) automate the mechanical parts; the *thinking* parts
> (the grill, the DB decision) are deliberately interactive.

---

## What's decided vs. what the grill decides

**Baked in (no longer up for debate):**

| Decision | Choice | Why |
| --- | --- | --- |
| Framework | Next.js (App Router) | T3 default; RSC + route handlers |
| Styling | Tailwind CSS | T3 default |
| Language | TypeScript (strict) | non‑negotiable |
| Stack flavour | create‑t3‑app | typesafe wiring out of the box |
| Package manager | **pnpm** | fast, disk‑efficient, T3's recommended |
| VCS | git, `main` branch | initialized by this kit |
| Workflow | Matt Pocock skills, ponytail, knowledge‑bank | preinstalled / preconfigured |

**Deferred to the grill (recorded as ADRs, not guessed):**

| Open question | Resolved by |
| --- | --- |
| **Database/backend — Convex vs Supabase** | `/grill-with-docs` → ADR (see [DB branches](#step-5--scaffold-the-app-per-the-adr)) |
| **Auth** | follows the DB: Supabase→Supabase Auth, Convex→Convex Auth |
| Anything else uncertain (hosting, tRPC vs server actions, etc.) | the same grill |

The DB choice has a real consequence, which is *why* it's grilled rather than picked:

- **Supabase** is the "T3‑shaped" choice. Keep tRPC + Drizzle, point `DATABASE_URL` at
  Supabase Postgres, optionally swap NextAuth for Supabase Auth.
- **Convex** *replaces* the T3 data layer. No tRPC, no ORM, no Postgres — it's a reactive
  backend with its own functions + client hooks. You get Next.js + Tailwind from T3 and
  bolt Convex on. More modern‑reactive, less "T3".

---

## Prerequisites

| Tool | Check | Notes |
| --- | --- | --- |
| Node ≥ 20 | `node -v` | this kit verified on v22.19.0 |
| pnpm | `pnpm -v` | `corepack enable pnpm` if missing |
| git | `git -v` | |
| GitHub CLI (optional) | `gh auth status` | needed if the issue tracker = GitHub |
| Claude Code | — | skills + plugins live in `~/.claude/` |

---

## Skills this kit relies on

| Skill / plugin | Source | Scope | What it does |
| --- | --- | --- | --- |
| **Matt Pocock engineering skills** | [mattpocock/skills](https://github.com/mattpocock/skills) | user (`~/.claude/skills`) | `grill-me`, `grill-with-docs`, `setup-matt-pocock-skills`, `tdd`, `to-prd`, `to-issues`, `triage`, `prototype`, `handoff`, `learn` |
| **ponytail** | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | project (this repo) | "lazy senior dev mode" — YAGNI, stdlib‑first. `ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt` |
| **knowledge‑bank** | [EPOHnomeL/knowledge-bank](https://github.com/EPOHnomeL/knowledge-bank) | bundled in `.claude/skills/` | `scaffold-knowledge-bank` + `populate-knowledge-bank` — interactive docs SPA, glossary, ADRs, drift‑sync |

> knowledge‑bank **requires** `setup-matt-pocock-skills` + `grill-with-docs` to be present —
> which is exactly why they run earlier in the sequence below.

### Invocation matrix — who can trigger what

Several Matt Pocock skills are locked with `disable-model-invocation: true`: **Claude cannot trigger
them**, only the user typing the slash command can. Plan the workflow around this:

| Skill | AI can invoke? | How it runs in this kit |
| --- | --- | --- |
| `scaffold-knowledge-bank`, `populate-knowledge-bank`, `tdd`, `learn`, ponytail (`ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt`) | **yes** | Claude invokes directly |
| `setup-matt-pocock-skills` | no (locked) | prompt-driven → Claude executes the process manually, **or** user types it |
| `grill-with-docs`, `grill-me` | no (locked) | **user types the slash command**, or Claude drives an equivalent relentless interview and writes the ADRs/CONTEXT.md itself |
| `to-prd`, `to-issues`, `triage`, `prototype`, `handoff`, `improve-codebase-architecture` | no (locked) | user types the slash command |

Rule baked into [`CLAUDE.md`](CLAUDE.md): if a needed skill is locked, prompt the user to invoke it
step by step, or (when it's prompt-driven and safe) execute its documented process directly — never
strip the lock from the user's global skills.

### Installing the skills

```sh
# 1. Matt Pocock skills (user scope — shared across all projects)
git clone https://github.com/mattpocock/skills /tmp/mp-skills
cp -r /tmp/mp-skills/.claude/skills/* ~/.claude/skills/   # confirm path inside the repo

# 2. ponytail (marketplace) — enabled per-project via .claude/settings.json (already in this kit)
#    In Claude Code:  /plugin marketplace add DietrichGebert/ponytail
#                     /plugin install ponytail@ponytail
#    This kit's .claude/settings.json already declares + enables it for the repo.

# 3. knowledge-bank (bundled in this kit at .claude/skills/, and/or user scope)
git clone https://github.com/EPOHnomeL/knowledge-bank /tmp/kb
cp -r /tmp/kb/scaffold-knowledge-bank /tmp/kb/populate-knowledge-bank ~/.claude/skills/
```

This kit ships with knowledge‑bank already in [`.claude/skills/`](.claude/skills/), so a fresh clone
of the kit is ready to go.

### Optional skills (not baked into the kit — opt in per project)

These are **not** kit defaults. They're installed on this machine and documented here so you can turn
them on per project when you want them — nothing is forced on a fresh copy.

| Skill | What it adds | Turn it on |
| --- | --- | --- |
| **ponytail** ([repo](https://github.com/DietrichGebert/ponytail)) | "Lazy senior dev" guardrails — YAGNI, stdlib‑first, the laziest solution that works | `/plugin marketplace add DietrichGebert/ponytail` then `/plugin install ponytail@ponytail`, or add the `ponytail@ponytail` block to `.claude/settings.json` (this repo already has it; delete the block to opt a copy out) |
| **ui-ux-pro-max** | UI/UX design intelligence — styles, palettes, font pairings, shadcn/Tailwind patterns. Handy for a Tailwind T3 app | Already at user scope (`~/.claude/skills/ui-ux-pro-max`) so it's globally available; to make a project self‑contained, copy it into that project's `.claude/skills/` |

---

## The bootstrap, step by step

> Run from inside the new project directory. Steps 1–3 + 5–6 are mechanical (the scripts do them);
> Step 4 is the interactive grill — the whole point.

### Step 1 — Repo + skills
```sh
git init -b main
# skills: see "Installing the skills" above; this kit pre-bundles them.
```

### Step 2 — Enable ponytail for the repo
Already declared in [`.claude/settings.json`](.claude/settings.json). Verify in Claude Code with
`/plugin` → ponytail should show **enabled**.

### Step 3 — Configure the Matt Pocock skills for this repo
```
/setup-matt-pocock-skills
```
Walks you through three decisions: **issue tracker** (GitHub / GitLab / local‑markdown / other),
**triage label vocabulary**, and **domain‑doc layout** (where `CONTEXT.md` + ADRs live). Writes
`docs/agents/…`. Run **once**, before the other engineering skills. *This must be done before the grill.*

### Step 4 — Grill with docs  ← the end goal
```
/grill-with-docs
```
A relentless interview about *this specific app* that **writes as it goes**: ADRs for every real
decision (starting with **Convex vs Supabase** and **auth**), a glossary, and `CONTEXT.md`. Do not
let it start coding — that's the point of the skill. Output: `CONTEXT.md`, `CONTEXT-MAP.md`,
`docs/adr/*`. The DB ADR is the input to Step 5.

> Use `/grill-me` instead if you only want the interview without the docs (e.g. sharpening a plan
> mid‑project). For *project init*, `grill-with-docs` is the one — it leaves artifacts.

### Step 5 — Scaffold the app per the ADR
Run create‑t3‑app, then branch on the DB the grill chose. (Flags drift between versions — run
`pnpm create t3-app@latest --help` to confirm; interactive is safest.)

**Branch A — Supabase** (T3‑shaped: tRPC + Drizzle):
```sh
pnpm create t3-app@latest .        # choose: App Router, Tailwind, tRPC, Drizzle, (NextAuth or none)
pnpm add @supabase/supabase-js
# point DATABASE_URL at your Supabase Postgres (Project Settings → Database → Connection string)
# optional: @supabase/ssr for Supabase Auth in App Router (replaces NextAuth)
pnpm db:push        # drizzle push to Supabase
```

**Branch B — Convex** (replaces tRPC/ORM/Postgres):
```sh
pnpm create t3-app@latest .        # choose: App Router, Tailwind; NO tRPC, NO Prisma/Drizzle
pnpm add convex
npx convex dev                     # provisions the dev deployment, generates _generated/
pnpm add @convex-dev/auth @auth/core   # if auth = Convex Auth
# wrap the app in <ConvexProvider>; data via useQuery/useMutation, not tRPC
```

> Scaffolding into a non‑empty dir: create‑t3‑app may refuse if files conflict. Scaffold in a
> temp dir and copy in, or run it before adding the knowledge‑bank `docs/` if there's a clash.

### Step 6 — Stand up the knowledge bank
```
/scaffold-knowledge-bank      # infra, glossary, nav, system map  → working-but-empty
/populate-knowledge-bank      # authors domain pages from code, wires weekly drift-sync
```
Serve it with `pnpm documentation`. Reuses the `CONTEXT.md`/ADRs from Step 4.

### Step 7 — First commit
```sh
git add -A && git commit -m "chore: bootstrap from app-init kit"
```

---

## Quick start (TL;DR)

```sh
# in an empty new-project dir, with the kit's .claude/ + scripts/ copied in:
pwsh scripts/init.ps1          # Windows  — does Steps 1–2, prints the interactive next steps
bash  scripts/init.sh          # macOS/Linux

# then, inside Claude Code, in order:
/setup-matt-pocock-skills      # Step 3
/grill-with-docs               # Step 4  ← decides DB+auth, writes CONTEXT.md + ADRs
#   …scaffold per the ADR (Step 5)…
/scaffold-knowledge-bank       # Step 6
/populate-knowledge-bank
```

## Why this order

1. **Skills first** so the agent has the right guardrails.
2. **`setup-matt-pocock-skills` before the grill** because the grill (and knowledge‑bank) read the
   doc layout it writes.
3. **Grill before scaffolding** — *understand before you code*. The DB decision is an ADR, not a
   coin flip, and it changes what `create-t3-app` you even run.
4. **Scaffold, then knowledge‑bank** so the docs describe real code.

---

_Generated by the app-init kit. Edit freely — "hack around with them, make them your own."_
