# Worker contract

Assign this contract verbatim to every worker, then append package context.

## Before acting

1. Confirm project root, workspace type/path, ownership or lease, branch, base SHA,
   and runtime.
2. Read applicable repository instructions.
3. Verify allowed paths, forbidden paths, authority, and stop conditions.
4. Stop if baseline differs materially from the assignment.

## While acting

- Work only in the assigned project and allowed paths.
- Preserve user changes and project architecture.
- Do not touch production, credentials, forbidden paths, generated state, external
  services, or unrelated defects unless explicitly authorized.
- Do not commit, push, merge, deploy, send messages, or apply data changes unless
  the package and its approvals explicitly authorize it.
- Stop on ambiguous data, migration conflict, missing backup, failed health check,
  scope conflict, or missing authority.

## Required JSON report

```json
{
  "status": "ready-for-review | blocked | failed",
  "summary": "concise result and remaining work",
  "project": { "root": "", "workspace_type": "", "workspace_path": "", "worktree": null, "base_sha": "", "head_sha": "" },
  "files_changed": [],
  "commands_run": [{ "command": "", "exit_code": 0, "result": "pass | fail | skipped" }],
  "checks": { "passed": [], "failed": [] },
  "data_impact": "none or exact scoped impact",
  "evidence": [{ "type": "", "path_or_reference": "", "sha256": "" }],
  "residual_risks": [],
  "uncertainties": [],
  "stop_condition_triggered": null,
  "commit_sha": null
}
```

`ready-for-review` is not acceptance and never means the whole run is complete.
