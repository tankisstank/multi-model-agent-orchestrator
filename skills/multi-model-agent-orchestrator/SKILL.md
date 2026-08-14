---
name: multi-model-agent-orchestrator
description: Coordinate evidence-driven work across one or more software projects using Herdr-managed agents, native Codex subagents, or external CLI agents such as Claude, Grok, and Gemini. Use for parallel implementation, audit, migrations, security review, release preparation, or cross-project changes that require bounded work packages, isolation, independent verification, durable run state, lifecycle cleanup, and human approval gates.
---

# Multi-Model Agent Orchestrator

Turn a natural-language objective into a bounded, evidence-driven run. Keep the
invoking agent as leader; workers may report `ready-for-review`, but only the
leader accepts a package or declares a run complete.

## Principles

- Treat each repository as sovereign: read its instructions, validation contract,
  source of truth, and release rules before planning.
- Prefer raw evidence over model narrative. Re-run important checks independently.
- Use deterministic tools for process state, paths, checksums, test outcomes, and
  budgets; use models for reasoning rather than polling.
- Select the least costly workspace that still prevents writer conflicts; do not
  create a worktree merely because a work package exists.
- Prefer Herdr for agent and terminal lifecycle management when running inside it.
- Register and clean every run-owned pane, process, browser, temporary path, and
  worktree; preserve anything whose ownership or recoverability is uncertain.
- Never infer authority for push, merge, deploy, production write, credential use,
  or external communications.

## Select mode and scale

| Mode | Use when | Result |
| --- | --- | --- |
| `plan` | Scope, authority, or project impact needs proof | DAG and gates; no writing worker |
| `execute` | The user authorized work in named project(s) | Bounded workers and verification |
| `audit` | Inspecting code, evidence, release, or security | Read-only findings with proof |
| `resume` | A prior run has durable state | Reconcile state before continuation |

- S0: small cohesive low-risk task — handle directly.
- S1: one bounded deliverable — one worker plus leader verification.
- S2: independent deliverables — parallel isolated workers.
- S3: security, data, release, production, or cross-project work — governed DAG,
  independent review, and approval gates.

Read [work-package schema](references/work-package-schema.md) before dispatch.
Read [workspace selection](references/workspace-selection.md) before assigning an
editing package or starting concurrent workers.
For S3 work or external side effects, read
[safety gates](references/safety-and-approval-gates.md). For more than one
repository, read [project federation](references/project-federation.md).

## Workflow

### 1. Intake and baseline

1. Restate objective, deliverables, authority, and definition of done.
2. Discover every project root; read all scoped instructions before planning.
3. Record branch, base SHA, dirty state, runtime, validation commands, and source
   of truth.
4. Run `scripts/select-agent-backend.ps1`, passing whether the host exposes native
   subagents. Prefer an active Herdr session. If Herdr or its skill is unavailable,
   recommend installing/enabling both, then fall back to native Codex subagents.
5. Run `scripts/probe-providers.ps1` only when Herdr is not selected and a direct
   external CLI must be dispatched. Do not assume support for JSON, resume, hooks,
   or a remembered permission flag.
6. Classify risk and choose mode/scale. Default to `plan` for migrations,
   production, unclear ownership, and cross-project contracts.

### 2. Build the DAG

- Make each work package own exactly one project and one mutable-path scope.
- Split by independently verifiable deliverable, not by arbitrary personas.
- Specify dependencies, raw evidence, stop conditions, budget, and approvals.
- Run packages in parallel only when paths, data, and environments do not overlap.
- For multiple projects, establish a contract owner and release order.
- Initialize durable state with `scripts/new-run-state.ps1` outside the repository
  unless that project defines an operational store.

### 3. Dispatch

Select and dispatch through [agent backends](references/agent-backends.md). When
`HERDR_ENV=1`, `herdr`, and its skill are available, use Herdr panes for native or
external CLI agents and capture fresh pane/session identifiers. Otherwise use the host's real
native Codex subagent capability. Only when Herdr is not selected and native
subagents cannot satisfy the package, probe and dispatch an external CLI directly
in non-interactive mode. Give every worker the complete contract from [worker
contract](references/worker-contract.md).

Choose the workspace from [workspace selection](references/workspace-selection.md)
and record the reason. Read-only packages and direct S0 leader edits normally need
no new worktree. Require a worktree or equivalent isolation for concurrent writers,
unsafe shared state, long-lived independent diffs, or higher-risk work. Set allowed
and forbidden paths and enforce a bounded attempt/time budget. Default maximum:
three concurrent workers.

### 4. Verify and correct

1. Validate reports with `scripts/validate-worker-report.ps1`.
2. Inspect diff and ownership independently; run deterministic checks.
3. For S3 packages, use an independent reviewer, preferably another provider.
4. Send only unresolved findings, failing checks, and expected post-conditions back
   to the worker. Keep the correction loop bounded.
5. Re-plan or escalate on repeated failure, stale base SHA, missing evidence, a
   blocked dependency, or exhausted budget.

### 5. Reconcile and clean resources

Read [resource lifecycle](references/resource-lifecycle.md). After evidence is
captured, and also before resuming a stale run, reconcile every registered resource:

1. stop or release completed, failed, timed-out, and orphaned workers;
2. close run-owned Playwright pages, contexts, browsers, servers, and child processes;
3. remove run-owned temporary paths after their evidence is retained;
4. remove clean, registered worktrees only after their HEAD/evidence is preserved;
5. close run-owned Herdr panes, then empty run-owned tabs/workspaces;
6. record `cleaned`, `preserved`, `blocked`, or `not-found` for every resource.

Register resources and persist reconciliation results with
`scripts/manage-run-resource.ps1`; do not rely on conversational memory for cleanup.
Run `scripts/test-run-cleanup.ps1` before closing the run; a nonzero result keeps the
run open until unresolved resources are cleaned or explicitly preserved.

Never close a focused/leader/pre-existing Herdr pane, kill by process name, delete an
unregistered path, force-remove a dirty worktree, or discard the only evidence copy.
Use a preview before applying cleanup. Treat ambiguous ownership as `blocked` and
report the exact manual action needed.

### 6. Integrate and close

- Integrate accepted work from immutable SHAs, never from a dirty worker workspace.
- In federated work, run combined validation and honor the documented compatibility
  and release order. Git has no atomic cross-repository commit.
- Request approval with the exact target, action, evidence, impact, and rollback.
- Publish only accepted outcomes to project trackers; keep operational state
  separate and idempotent.
- Do not call the run closed until required resource cleanup is complete or every
  preserved/blocked resource is explicitly reported.

## Provider rules

- `auto` selects a capable installed provider; it never silently replaces a
  provider the user explicitly named.
- Herdr is the preferred orchestration backend, not a provider substitution. A
  user-named Claude/Grok/Gemini worker remains that provider inside its Herdr pane.
- Prefer local deterministic commands for tests and probes.
- For direct CLI fallback only, do not invent flags. Use the probe and
  [provider adapters](references/provider-adapters.md).
- Record provider, backend type, session ID, command, and captured evidence.

## Final report

Return mode, scale, run status, accepted/blocked packages, affected projects and
base SHAs, changed paths, exact check outcomes, evidence, residual risks, pending
approvals, resource cleanup results, preserved resources with recovery instructions,
and cross-project compatibility/rollback state. Never call a run complete while a
required gate is red.
