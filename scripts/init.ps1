#!/usr/bin/env pwsh
# app-init bootstrap (Windows / PowerShell 7+)
# Mechanical setup only. The grill (Step 4) is interactive — run it yourself in Claude Code.
$ErrorActionPreference = 'Stop'

function Step($n, $msg) { Write-Host "`n[$n] $msg" -ForegroundColor Cyan }
function Ok($msg)       { Write-Host "  OK  $msg" -ForegroundColor Green }
function Warn($msg)     { Write-Host "  !!  $msg" -ForegroundColor Yellow }

Step 0 "Checking prerequisites"
foreach ($t in 'node','pnpm','git') {
  $c = Get-Command $t -ErrorAction SilentlyContinue
  if ($c) { Ok "$t -> $((& $t --version) 2>&1 | Select-Object -First 1)" }
  else    { Warn "$t not found. Install it before continuing (pnpm: 'corepack enable pnpm')." }
}

Step 1 "git init (main)"
if (Test-Path .git) { Ok "git already initialized" }
else { git init -b main | Out-Null; Ok "initialized on 'main'" }

Step 2 "Verifying skills are present"
$repoSkills = Join-Path $PSScriptRoot '..' '.claude/skills'
foreach ($s in 'scaffold-knowledge-bank','populate-knowledge-bank') {
  if (Test-Path (Join-Path $repoSkills $s 'SKILL.md')) { Ok "knowledge-bank: $s bundled" }
  else { Warn "knowledge-bank skill '$s' missing in .claude/skills/ — see app-init.md > Installing the skills" }
}
$userSkills = Join-Path $HOME '.claude/skills'
if (Test-Path (Join-Path $userSkills 'grill-with-docs')) { Ok "Matt Pocock skills present (grill-with-docs found)" }
else { Warn "Matt Pocock skills not found in ~/.claude/skills — see app-init.md > Installing the skills" }
if (Test-Path (Join-Path $PSScriptRoot '..' '.claude/settings.json')) { Ok "ponytail enabled via .claude/settings.json" }
else { Warn ".claude/settings.json missing — ponytail will not be enabled for this repo" }

Write-Host "`nMechanical setup done. Now, inside Claude Code, run in order:" -ForegroundColor Magenta
Write-Host @"
  /setup-matt-pocock-skills    (Step 3 — issue tracker + label vocab + doc layout)
  /grill-with-docs             (Step 4 — decides Convex vs Supabase + auth; writes CONTEXT.md + ADRs)
  # ...scaffold per the DB ADR (Step 5: pnpm create t3-app@latest .)...
  /scaffold-knowledge-bank     (Step 6)
  /populate-knowledge-bank
"@ -ForegroundColor Gray
