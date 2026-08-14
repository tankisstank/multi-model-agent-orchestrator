# Multi-Model Agent Orchestrator

An evidence-driven Codex plugin for coordinating native and CLI-based coding
agents across one repository or a federated set of repositories.

The plugin turns a natural-language objective into bounded work packages with
explicit project ownership, validation, evidence, isolation, and approval gates.
It is designed for Codex first, while retaining provider-neutral contracts for
Claude, Grok, Gemini, and compatible command-line agents.

## What it solves

- Workspace selection that avoids unnecessary worktrees while isolating parallel writers.
- Cross-repository changes with explicit contract ownership and release order.
- Durable run-state, bounded correction loops, and recoverable worker reports.
- Herdr-first agent/CLI orchestration with native Codex and probed CLI fallbacks.
- Reconciliation and cleanup of run-owned panes, processes, browsers, temporary
  paths, and completed worktrees.
- Independent verification before acceptance.
- Clear separation between safe automation and actions requiring human approval.

## Repository layout

```text
.codex-plugin/plugin.json       Plugin metadata
skills/multi-model-agent-orchestrator/
  SKILL.md                      Core workflow loaded by Codex
  references/                   Worker, provider, safety, federation contracts
  scripts/                      Provider probe, run-state, report validator
docs/architecture.md            Product and architecture requirements
tests/smoke.ps1                 Local structural smoke test
```

## Use

Install or expose this plugin in Codex, then invoke:

```text
$multi-model-agent-orchestrator
Plan a risk-gated change across the API and web repositories. Do not merge or deploy.
```

Codex can also activate the skill implicitly when the prompt matches the skill
description. Use explicit invocation for high-risk or release work.

## Safety model

The leader keeps acceptance authority. Workers may only report
`ready-for-review`, `blocked`, or `failed`. Push, merge, deploy, production
write, destructive operations, and external communications require explicit
approval.

Read [architecture.md](docs/architecture.md) for the full operating model.

## Development

Run the smoke test from PowerShell:

```powershell
./tests/smoke.ps1
```

The support scripts require PowerShell 7 or newer (`pwsh`).

Validate the skill with the Codex skill-creator validator when it is available:

```powershell
python <skill-creator>/scripts/quick_validate.py ./skills/multi-model-agent-orchestrator
```

## Status

Version 0.1.0 is a local-first plugin: it provides the orchestration policy and
deterministic support scripts. Provider execution and tracker integrations remain
capability-gated and must respect each target project's instructions.
