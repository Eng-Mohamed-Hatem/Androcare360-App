# Analysis: Agora Video-Calling Service Audit and Fix

**Created**: 2026-03-31  
**Status**: Consistent before implementation

## Consistency Review

- The constitution now explicitly covers telemedicine lifecycle governance, server-owned session control, and the prohibition on patient-side completion from cleanup.
- The spec focuses on the concrete risks found in the current repo: missing active-backend callable handlers, incomplete pending-call restoration, and mixed client/server completion ownership.
- The clarify document records the remaining unknowns without blocking a minimal safe implementation.
- The plan translates the spec into concrete Flutter and Functions workstreams with explicit config verification for `databaseId: 'elajtech'` and `europe-west1`.
- The tasks map directly to the plan and avoid implementation work outside the declared scope.

## Risks Accepted for This Pass

- No new persistent call-session model is introduced in this remediation.
- Timeout retry policy remains only partially specified beyond the current safe fixes.
- Legacy Agora/Zoom folders remain in the repo but are treated as non-authoritative for this implementation.

## Go/No-Go Check Before `/speckit.implement`

- `spec.md` exists under `.specify/specs/agora-audit-and-fix/`
- `plan.md` exists under `.specify/specs/agora-audit-and-fix/`
- checklist, tasks, and analysis are now present
- implementation may proceed without violating the user’s sequencing requirement
