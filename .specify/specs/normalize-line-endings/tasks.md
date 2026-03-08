# Tasks: Normalize line endings to LF across the Flutter app

**Input**: Design documents from `.specify/specs/normalize-line-endings/`
**Prerequisites**: plan.md (required), spec.md (required)

## Phase 1: Implementation

**Goal**: Apply the `.gitattributes` policy and commit the change.

- [ ] T001 Create or update `.gitattributes` in repo root with:
  ```text
  * text=auto

  *.dart text eol=lf
  *.yaml text eol=lf
  *.yml  text eol=lf
  *.md   text eol=lf
  *.json text eol=lf
  ```
- [ ] T002 Stage the `.gitattributes` file: `git add .gitattributes`
- [ ] T003 Commit with message: `chore: enforce LF line endings via .gitattributes`

## Phase 2: Verification

**Goal**: Verify the policy is correctly applied.

- [ ] T004 Verify `.gitattributes` content matches the requirement.
- [ ] T005 Run `git check-attr eol -- lib/main.dart` and confirm output is `eol: lf`.
- [ ] T006 Run `flutter analyze` to ensure no issues were introduced.
