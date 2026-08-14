# Architecture and requirements

## Objective

Coordinate one or more AI coding agents safely across one project or multiple
related projects. The orchestrator is a governance and evidence layer; it does
not replace a target repository's instructions, architecture, source of truth,
or release authority.

## Operating modes

| Mode | Outcome |
| --- | --- |
| Plan | Project map, risk level, work-package DAG, gates; no writer |
| Execute | Bounded workers, evidence, review, and integration queue |
| Audit | Read-only findings supported by raw evidence |
| Resume | Reconcile durable state and continue safely |

## Scale

| Level | Situation | Control |
| --- | --- | --- |
| S0 | Small cohesive low-risk change | Leader acts directly |
| S1 | One bounded deliverable | Worker plus leader verification |
| S2 | Independent deliverables | Isolated parallel workers |
| S3 | Security, data, production, release, or multi-project work | Independent review and approval gates |

## Core workflow

```text
Intent -> intake -> project baseline -> work-package DAG -> isolated workers
       -> raw evidence -> deterministic validation -> independent review
       -> approval gate -> integration -> resource cleanup -> accepted outcome
```

The orchestrator must use deterministic operations for process state, workspace
ownership, command exit codes, checksums, budgets, and state transitions. Models
are used for planning, implementation, semantic review, and correction prompts.

## Work-package invariants

Every work package has:

- one project owner;
- an immutable base SHA;
- a mode: read-only, edit, data-dry-run, or approval-gated;
- allowed and forbidden paths;
- dependencies and input contracts;
- required commands and expected raw evidence;
- acceptance criteria, stop conditions, budget, and approval requirements.

Workers cannot declare a run complete. Their only terminal statuses are
`ready-for-review`, `blocked`, and `failed`.

## Project federation

Use federation when repositories share an API, schema, package, event, data
flow, deployment, or release train.

1. Register each repository with its root, instructions, base SHA, dirty state,
   source of truth, validation contract, and human release authority.
2. Define every cross-project edge as a typed contract with one owner, an
   immutable artifact/version/checksum, compatibility rule, and consumer check.
3. Create one package per project. A cross-project coordinator never directly
   edits several repositories.
4. Prefer expand-migrate-contract: producer expands compatibly, consumers adopt,
   then producer contracts only after consumer proof.
5. Validate each repository, then validate the combined set from immutable
   revisions. Document merge order and per-project rollback.

Git has no atomic transaction across repositories. Report partial state and
rollback readiness accurately.

## Provider adapters

Prefer Herdr when the leader runs inside a Herdr-managed pane. It provides panes,
agent state, output capture, waiting, and lifecycle controls for Codex and external
CLI providers. If Herdr or its skill is unavailable, recommend installation and
fall back to native Codex subagents. Only direct external-CLI fallback requires the
provider probe for command availability, version, non-interactive execution,
structured output, resume, hooks, and permission controls.

| Tier | Capability | Suitable work |
| --- | --- | --- |
| 0 | Terminal process only | Manual/interactive observation |
| 1 | Non-interactive prompt and process detection | Bounded read-only work |
| 2 | Structured report and resume | Managed implementation/review |
| 3 | Hooks, policy controls, or native API | Long-running governed work |

Do not guess provider flags. Do not silently substitute a provider named by the
user. Prefer a different provider/model for critical independent review.

## Isolation and durable state

- Read-only work may use a shared checkout only when it creates no state.
- Direct S0 leader edits may use the current checkout while preserving user changes.
- A single editing worker may use a pre-existing dedicated checkout with an exclusive
  writer lease. Require a worktree or equivalent isolation for concurrent writers,
  ambiguous ownership, unsafe shared state, long-lived independent diffs, or stricter
  project policy.
- Data repair uses a disposable clone/snapshot before any production action.
- Untrusted source should use a sandbox/container.
- Durable state records run ID, objective, project fingerprints, packages,
  leases, events, approvals, evidence, and budgets outside the source tree by
  default.

Each active worker has a lease and heartbeat. On failure, collect available
evidence, mark the package orphaned, resume the session only if supported, or
create a bounded handoff package.

Every run-owned pane, agent, process, Playwright browser/context, temporary path,
and worktree is registered in durable state. Reconcile resources during close and
resume. Cleanup requires verified ownership and retained evidence; preserve dirty
worktrees and ambiguous resources with explicit recovery instructions.

## Verification and approval

Use this order:

1. scope and ownership verification;
2. deterministic checks;
3. project tests;
4. cross-project contract/integration checks;
5. semantic diff review;
6. independent cross-provider review for S3 work;
7. human approval;
8. post-condition audit.

Human approval is mandatory for push, merge, deploy, production write, migration
apply, external message, destructive action, security-policy weakening, and
credential use beyond normal least privilege.

## Evidence and reporting

Evidence must identify artifact type, path/reference, checksum where practical,
command, exit code, source/base SHA, producer, and timestamp. The final report
states accepted, blocked, and rejected packages; exact checks; residual risks;
pending approvals; cross-project compatibility; release order; and rollback
state.

## Version 0.1.0 boundaries

Included:

- Codex skill workflow and references.
- Provider probe, run-state initialization, and worker-report validation.
- Single-project and multi-project governance.

Not included:

- automatic production deployment;
- automatic merge/push;
- a dashboard or hosted control plane;
- credential collection;
- unbounded recursive agent spawning;
- model consensus as a substitute for evidence.
