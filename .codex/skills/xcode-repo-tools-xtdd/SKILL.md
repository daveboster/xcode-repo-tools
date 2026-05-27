---
name: xcode-repo-tools-xtdd
description: Use when implementing or extending xcode-repo-tools Bash helper behavior with the repo's integration-first Extreme TDD process, especially for simulator, xcodebuild, markdown, repo-check, or wrapper functions. This skill guides branch creation, red integration tests, focused unit red-green-refactor commits, release-note-friendly merge commits, and cleanup-only refactor commits.
---

# Xcode Repo Tools XTDD

## Overview

Use this skill to implement the next `xcode-repo-tools` helper behavior without
overbuilding. The integration test is the scope guard; unit tests and code exist
only to make that integration test pass.

## Branch Flow

1. Start from `dev/initial` unless the user names another development branch.
2. Create a focused branch named `dev/<helper-or-behavior>`.
3. Keep `main` untouched until the larger body of work is done.
4. Use release-note-friendly `feat:` merge commits when merging behavior back
   into `dev/initial`.
5. Use `refactor:` commits for cleanup-only work that should be excluded from
   user release notes.

## Extreme TDD Cycle

1. Add or update one Bats integration test under `integration/` for the desired
   real behavior.
2. Run the integration test and confirm RED for the expected reason.
3. Commit the red integration test with `test: ...`.
4. Add one focused Bats unit test under `test/` for the next required helper
   behavior.
5. Run the unit test and confirm RED for the expected reason.
6. Commit the red unit test with `test: ...`.
7. Implement the minimum Bash helper code needed to make that unit test green.
8. Run `bats test`, the target integration test, and then `bats test
   integration`.
9. Commit the green implementation with `feat: ...`.
10. Refactor only if there is useful cleanup after green; keep it in a separate
    `refactor:` commit.
11. Merge the feature branch back into `dev/initial` with `--no-ff` and a
    release-note-friendly `feat:` merge commit.

## Guardrails

- Do not add helper functions, flags, wrappers, abstractions, or extra unit
  cases unless the current integration test requires them.
- Prefer existing helper files:
  - simulator behavior: `lib/simulators.sh`, `test/simulators.bats`,
    `integration/simulators_*.bats`, `test/helpers/mock_xcrun.bash`
  - xcodebuild behavior: `lib/xcodebuild.sh`, `test/xcodebuild.bats`,
    `test/helpers/mock_xcodebuild.bash`
- Keep Bats fixtures in shared mock helpers once duplication appears.
- Integration tests may require CoreSimulator access. If sandboxed execution
  blocks `xcrun`, rerun the same command with approval instead of weakening the
  test.

## Verification Commands

Run the narrowest command first, then broaden:

```bash
bats integration/<target>.bats
bats test/<target>.bats
bats test
bats test integration
```

Use `bash -n` for changed Bash files before committing:

```bash
bash -n lib/*.sh test/helpers/*.bash test/*.bats integration/*.bats
```
