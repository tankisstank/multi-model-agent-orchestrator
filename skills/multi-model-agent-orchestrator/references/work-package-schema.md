# Work-package schema

```yaml
id: WP1
title: concise verb-led title
objective: observable outcome
project_id: project registry ID
mode: read-only | edit | data-dry-run | approval-gated
base_sha: immutable starting revision
dependencies: []
provider: auto | codex | claude | grok | gemini
reviewer: null | provider/name
backend: herdr | codex-native | direct-cli-after-probe
workspace: current-checkout | shared-readonly | existing-exclusive | worktree | snapshot | sandbox
workspace_reason: concise risk/ownership justification
exclusive_writer_lease: null | { owner: worker-id, expires_at: ISO-8601 }
allowed_paths: []
forbidden_paths: []
inputs: { artifacts: [], contracts: [] }
tasks: []
required_commands: []
expected_evidence: []
acceptance_criteria: []
stop_conditions: []
approval_requirements: []
budget: { max_attempts: 3, max_elapsed_minutes: 45, max_review_rounds: 2 }
resources: []
cleanup: { required: true, status: pending }
```

Invariants:

- One package owns one project and only its allowed paths.
- Dependencies must be accepted or declared speculative.
- Production, external write, merge, push, and deploy are always approval-gated.
- Every acceptance criterion needs a validation method or evidence type.
- A worktree is required only when the workspace-selection rules require isolation.
- `current-checkout` is reserved for direct S0 leader work; editing workers need an
  exclusive checkout, worktree, snapshot, or sandbox.
