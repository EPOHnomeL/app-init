#!/usr/bin/env bash
# app-init bootstrap (macOS / Linux)
# Mechanical setup only. The grill (Step 4) is interactive — run it yourself in Claude Code.
set -euo pipefail

cyan() { printf '\n\033[36m[%s] %s\033[0m\n' "$1" "$2"; }
ok()   { printf '  \033[32mOK\033[0m  %s\n' "$1"; }
warn() { printf '  \033[33m!!\033[0m  %s\n' "$1"; }

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"

cyan 0 "Checking prerequisites"
for t in node pnpm git; do
  if command -v "$t" >/dev/null 2>&1; then ok "$t -> $($t --version 2>&1 | head -n1)"
  else warn "$t not found. Install it first (pnpm: 'corepack enable pnpm')."; fi
done

cyan 1 "git init (main)"
if [ -d .git ]; then ok "git already initialized"; else git init -b main >/dev/null; ok "initialized on 'main'"; fi

cyan 2 "Verifying skills are present"
for s in scaffold-knowledge-bank populate-knowledge-bank; do
  if [ -f "$REPO/.claude/skills/$s/SKILL.md" ]; then ok "knowledge-bank: $s bundled"
  else warn "knowledge-bank skill '$s' missing — see app-init.md > Installing the skills"; fi
done
if [ -d "$HOME/.claude/skills/grill-with-docs" ]; then ok "Matt Pocock skills present (grill-with-docs found)"
else warn "Matt Pocock skills not found in ~/.claude/skills — see app-init.md"; fi
if [ -f "$REPO/.claude/settings.json" ]; then ok "ponytail enabled via .claude/settings.json"
else warn ".claude/settings.json missing — ponytail will not be enabled"; fi

printf '\n\033[35mMechanical setup done. Now, inside Claude Code, run in order:\033[0m\n'
cat <<'EOF'
  /setup-matt-pocock-skills    (Step 3 — issue tracker + label vocab + doc layout)
  /grill-with-docs             (Step 4 — decides Convex vs Supabase + auth; writes CONTEXT.md + ADRs)
  # ...scaffold per the DB ADR (Step 5: pnpm create t3-app@latest .)...
  /scaffold-knowledge-bank     (Step 6)
  /populate-knowledge-bank
EOF
