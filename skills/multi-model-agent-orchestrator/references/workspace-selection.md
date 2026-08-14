# Workspace selection

Choose the least costly option that preserves ownership, user changes, and reliable
verification. Worktrees are conditional, not a default requirement.

| Situation | Workspace | New worktree? |
| --- | --- | --- |
| Plan, audit, review, or commands guaranteed not to create state | `shared-readonly` | No |
| Small cohesive S0 edit performed directly by the leader | `current-checkout` | No |
| One editing worker already has a dedicated checkout and exclusive writer lease | `existing-exclusive` | No |
| Two or more writers, overlapping time, or leader and worker may both edit | `worktree` | Yes |
| Shared checkout is dirty or package needs an independently reviewable long-lived diff | `worktree` | Usually |
| Non-Git/data dry run requiring disposable state | `snapshot` | No Git worktree |
| Untrusted code or strong runtime isolation required | `sandbox` | No Git worktree required |

Tests, formatters, builds, browsers, and package managers may create caches, lockfiles,
screenshots, or generated files. Do not classify them as `shared-readonly` unless the
command is known to leave the checkout and shared environment unchanged.

## Decision rules

1. Use `current-checkout` only for leader-owned S0 work. Preserve existing user
   changes and do not let another writer use it concurrently.
2. Use `existing-exclusive` only after recording the checkout path, base SHA, dirty
   state, owner, lease, and proof that no other writer will use it.
3. Require `worktree` or equivalent isolation when writers can overlap, ownership is
   ambiguous, the user checkout must remain untouched, or rollback/review needs an
   independent diff boundary.
4. Prefer `snapshot` or `sandbox` when Git worktrees do not isolate the relevant data,
   runtime, secrets, services, or untrusted execution.
5. Honor stricter project instructions or an explicit user request for isolation.

Record `workspace`, `workspace_reason`, `owner`, and `exclusive_writer_lease` in the
package. If the assumptions change during execution, stop and reselect the workspace.
