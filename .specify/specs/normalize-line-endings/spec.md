# Feature Specification: Normalize line endings to LF across the Flutter app

**Feature Branch**: `chore/normalize-line-endings`  
**Created**: 2026-03-08  
**Status**: Draft  
**Input**: User description: "Normalize line endings to LF across the Flutter app"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Enforce LF Line Endings (Priority: P1)

Developers working on different operating systems (Windows, Linux, macOS) often encounter issues with line endings (CRLF vs LF). This task ensures that the repository enforces LF line endings for all text files.

**Why this priority**: Crucial for codebase consistency and avoiding unnecessary diffs in version control.

**Independent Test**: Verify that new commits use LF and that `.gitattributes` correctly dictates the policy.

**Acceptance Scenarios**:

1. **Given** a repository with mixed line endings, **When** `.gitattributes` is added with `* text=auto` and specific extensions set to `eol=lf`, **Then** git should handle line endings consistently.
2. **Given** a Windows environment, **When** a `.dart` file is edited and saved, **Then** it should be committed with LF line endings if the policy is active.

---

### Edge Cases

- Existing files with CRLF: Simply adding `.gitattributes` might not change existing files in the index until they are "renormalized" if needed.
- Binary files: Must ensure binary files are not treated as text to avoid corruption.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST have a `.gitattributes` file in the root directory.
- **FR-002**: `.gitattributes` MUST specify `eol=lf` for `*.dart`, `*.yaml`, `*.yml`, `*.md`, and `*.json` files.
- **FR-003**: `.gitattributes` MUST specify `* text=auto` for general text handling.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `.gitattributes` exists and contains the specified rules.
- **SC-002**: `git check-attr eol -- [file]` returns `lf` for target file types.
