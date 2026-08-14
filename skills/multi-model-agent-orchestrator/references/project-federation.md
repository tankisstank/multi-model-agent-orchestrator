# Project federation

Use federation when projects share a runtime API, schema, library, deployment,
event, data flow, or coordinated release.

## Register projects

```yaml
id: api
root: /absolute/project/path
repository: { default_branch: main }
instructions: [AGENTS.md]
source_of_truth: project-local tracker or docs
validation: { quick: [], integration: [] }
release_authority: human
```

Capture base SHA, dirty state, instruction hash, and validation contract before
planning. Project-local policy always wins over federation defaults.

## Define contract edges

```yaml
from: web
to: api
type: runtime-api | schema | build-time | shared-library | deployment | data
owner: api
artifact: path, package version, image digest, or schema checksum
compatibility: backward-compatible | expand-migrate-contract | breaking
validation: consumer command or integration probe
```

## Coordinated change set

1. Create one package per project; contract owners publish immutable artifacts.
2. Prefer expand-migrate-contract: producer expands, consumers adopt, producer
   contracts only after consumers prove migration.
3. Test each project in its own workspace, then run combined validation.
4. Define merge/release order and per-project rollback before approval.

Git has no atomic transaction across repositories. Report precisely which projects
changed, remain compatible, are blocked, and have a proven rollback path.
