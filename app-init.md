# app-init — reproducible project bootstrap kit

A **reusable kit** for spinning up a new app exactly the way I like to start one:
a **T3 + Next.js (App Router) + Tailwind + TypeScript** app, **pnpm**, **git** (+ a private
**GitHub** remote), deployed on **Vercel**, with my **skills** preinstalled (Matt Pocock's
engineering skills, ponytail, knowledge‑bank), a **Vitest** runner for the `tdd` skill, a pinned
Node version, and an **understand‑before‑you‑code** workflow that ends in a *grill with docs* —
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
| Package manager | **pnpm** | fast, disk‑efficient, T3's recommended; pinned via `packageManager` |
| Node version | pinned (`.nvmrc` + `engines`) | reproducible across machines/CI |
| VCS | git, `main` branch + **private GitHub remote** | `git init` + `gh repo create --private` |
| Hosting | **Vercel** | Next.js's first‑party host; env synced via the Vercel CLI |
| Testing | **Vitest** (unit) | a runner so the `tdd` skill has something to run; Playwright added per‑project later |
| Workflow | Matt Pocock skills, ponytail, knowledge‑bank | preinstalled / preconfigured |

**Deferred to the grill (recorded as ADRs, not guessed):**

| Open question | Resolved by |
| --- | --- |
| **Database/backend — Convex vs Supabase** | `/grill-with-docs` → ADR (see [DB branches](#step-5--scaffold-the-app-per-the-adr)) |
| **Auth** | follows the DB: Supabase→Supabase Auth, Convex→Convex Auth |
| Anything else uncertain (tRPC vs server actions, observability, etc.) | the same grill |

The DB choice has a real consequence, which is *why* it's grilled rather than picked — and it also
changes the **deployment topology**:

- **Supabase** is the "T3‑shaped" choice. Keep tRPC + Drizzle, point `DATABASE_URL` at
  Supabase Postgres, optionally swap NextAuth for Supabase Auth. Deploys as a single Vercel
  project (Next.js on Vercel, Postgres at Supabase).
- **Convex** *replaces* the T3 data layer. No tRPC, no ORM, no Postgres — it's a reactive
  backend with its own functions + client hooks. You get Next.js + Tailwind from T3 and
  bolt Convex on. More modern‑reactive, less "T3". **Deployment splits:** Vercel hosts the
  Next.js frontend, **Convex Cloud** hosts the backend functions + DB. The kit wires this with
  `NEXT_PUBLIC_CONVEX_URL` in Vercel's env and a `convex deploy` in the Vercel build step
  (see [Step 6](#step-6--wire-up-deployment-vercel--convex)).

---

## Prerequisites

| Tool | Check | Notes |
| --- | --- | --- |
| Node ≥ 20 | `node -v` | this kit verified on v22.19.0; the version is pinned in `.nvmrc` |
| pnpm | `pnpm -v` | `corepack enable pnpm` if missing |
| git | `git -v` | |
| GitHub CLI | `gh auth status` | **required** — the kit creates the private remote with `gh repo create` |
| Vercel CLI | `vercel whoami` | `pnpm add -g vercel`; used for `vercel link` + env sync ([Step 6](#step-6--wire-up-deployment-vercel--convex)) |
| Vercel account | — | free tier is fine; `vercel login` once |
| Convex account | — | only if the grill picks Convex; `npx convex dev` handles login |
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

> Run from inside the new project directory. The mechanical steps (local git, Node pin, skill
> verification) are done by the scripts; the interactive ones — the grill (Step 4), scaffold
> (Step 5), deploy (Step 6), and the remote/push (Step 8) — you drive. The remote is **not**
> created until the first commit (Step 8), so `gh repo create --source .` has something to push.

### Step 1 — Repo + Node pin + skills
```sh
git init -b main
node -v > .nvmrc                   # pin the Node version the kit was verified on (or your target)
# skills: see "Installing the skills" above; this kit pre-bundles them.
```
The `packageManager` field (pnpm) and an `engines.node` range land in `package.json` when
create‑t3‑app runs in Step 5; `.nvmrc` pins the local/CI version now.

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
`pnpm create t3-app@latest --help` to confirm; interactive is safest.) Each branch ends by adding
**Vitest** (a unit runner so the `tdd` skill has something to drive) and an **`.env.example`** that
documents every key the app needs — the source of truth synced to Vercel/Convex in Step 6.

**Branch A — Supabase** (T3‑shaped: tRPC + Drizzle):
```sh
pnpm create t3-app@latest .        # choose: App Router, Tailwind, tRPC, Drizzle, (NextAuth or none)
pnpm add @supabase/supabase-js
# point DATABASE_URL at your Supabase Postgres (Project Settings → Database → Connection string)
# optional: @supabase/ssr for Supabase Auth in App Router (replaces NextAuth)
pnpm db:push                       # drizzle push to Supabase
pnpm add -D vitest @vitejs/plugin-react jsdom   # unit test runner for the `tdd` skill
# write .env.example with: DATABASE_URL, NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, …
```

**Branch B — Convex** (replaces tRPC/ORM/Postgres — provisioning is scripted, not hand-typed):
```sh
pnpm create t3-app@latest .        # choose: App Router, Tailwind; NO tRPC, NO Prisma/Drizzle
pnpm add convex
npx convex dev --once              # logs in, provisions the dev deployment, generates _generated/
                                   #   (--once exits after codegen instead of watching — script-friendly)
pnpm add @convex-dev/auth @auth/core   # if auth = Convex Auth
# scaffold <ConvexProvider> at the App Router root; data via useQuery/useMutation, not tRPC
pnpm add -D vitest convex-test @edge-runtime/vm   # unit runner (+ Convex's function-test helper)
# write .env.example with: NEXT_PUBLIC_CONVEX_URL, CONVEX_DEPLOYMENT, (auth keys if Convex Auth), …
```

> `npx convex dev --once` still needs an interactive login the first time (device auth) and a
> deployment-name choice — that part can't be fully headless, but everything after (codegen,
> provider wiring, env) is scripted.

> Scaffolding into a non‑empty dir: create‑t3‑app may refuse if files conflict. Scaffold in a
> temp dir and copy in, or run it before adding the knowledge‑bank `docs/` if there's a clash.

### Step 6 — Wire up deployment (Vercel + Convex)
Vercel is a baked decision, not a grill question. Link the project and push env from `.env.example`.

```sh
vercel link                        # create/link the Vercel project (run `vercel login` first)
# Push each secret from .env.example into Vercel (prod + preview). Per key:
vercel env add DATABASE_URL production
vercel env add DATABASE_URL preview
# …repeat for every key in .env.example…
vercel                             # preview deploy;  `vercel --prod` for production
```

Vercel's GitHub integration then gives you **preview deploys per PR** once the remote exists (Step 8).

**Convex branch — the deployment splits.** Vercel hosts the Next.js frontend; **Convex Cloud** hosts
the backend functions + DB. Two extra wires:

```sh
# 1. Point the frontend at the Convex deployment (get the URL from `npx convex dashboard`):
vercel env add NEXT_PUBLIC_CONVEX_URL production
# 2. Deploy Convex functions as part of the Vercel build, so the two stay in lockstep.
#    Set the Vercel "Build Command" to:
npx convex deploy --cmd 'pnpm build'
#    and add CONVEX_DEPLOY_KEY (from the Convex dashboard → Settings) to Vercel's env.
```

### Step 7 — Stand up the knowledge bank
```
/scaffold-knowledge-bank      # infra, glossary, nav, system map  → working-but-empty
/populate-knowledge-bank      # authors domain pages from code, wires weekly drift-sync
```
Serve it with `pnpm documentation`. Reuses the `CONTEXT.md`/ADRs from Step 4.

### Step 8 — First commit + create the remote
```sh
git add -A && git commit -m "chore: bootstrap from app-init kit"
# create the private GitHub remote from the local repo and push in one shot:
gh repo create --source . --private --push --remote origin
```
Make sure `.env*` (other than `.env.example`) is gitignored before this — create‑t3‑app's
`.gitignore` already excludes `.env`. With the remote up, Vercel's GitHub integration wires
per‑PR preview deploys automatically.

---

## Quick start (TL;DR)

```sh
# in an empty new-project dir, with the kit's .claude/ + scripts/ copied in:
pwsh scripts/init.ps1          # Windows  — local git + Node pin + skill check; prints next steps
bash  scripts/init.sh          # macOS/Linux

# then, inside Claude Code, in order:
/setup-matt-pocock-skills      # Step 3
/grill-with-docs               # Step 4  ← decides DB+auth, writes CONTEXT.md + ADRs
#   …scaffold per the ADR + add Vitest + .env.example (Step 5)…
#   …vercel link + env sync (+ convex deploy build step on the Convex branch) (Step 6)…
/scaffold-knowledge-bank       # Step 7
/populate-knowledge-bank
#   …git commit + `gh repo create --source . --private --push` (Step 8)…
```

## Why this order

1. **Skills first** so the agent has the right guardrails.
2. **`setup-matt-pocock-skills` before the grill** because the grill (and knowledge‑bank) read the
   doc layout it writes.
3. **Grill before scaffolding** — *understand before you code*. The DB decision is an ADR, not a
   coin flip, and it changes what `create-t3-app` you even run *and* the deployment topology.
4. **Scaffold, then deploy** so there's an app to point Vercel (and, on the Convex branch, Convex
   Cloud) at, with `.env.example` as the source of truth for env sync.
5. **Then knowledge‑bank** so the docs describe real code.
6. **Remote last** — `gh repo create` pushes a repo that's already scaffolded, committed, and
   deploy‑wired, so Vercel's GitHub integration lights up preview deploys immediately.

---

_Generated by the app-init kit. Edit freely — "hack around with them, make them your own."_
