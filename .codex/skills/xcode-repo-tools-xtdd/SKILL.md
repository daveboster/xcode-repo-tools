---
name: xcode-repo-tools-xtdd
description: Use when implementing or extending xcode-repo-tools Bash helper behavior with the repo's integration-first Extreme TDD process, especially for simulator, xcodebuild, markdown, repo-check, or wrapper functions. This skill guides branch creation, review-gated happy-path and non-happy-path integration tests, focused unit red-green-refactor commits, user-run integration verification, release-note-friendly merge commits, and cleanup-only refactor commits.
---

# Xcode Repo Tools XTDD

## Overview

Use this skill to implement the next `xcode-repo-tools` helper behavior without
overbuilding. Integration tests are the scope guard; unit tests and code exist
only to make those integration tests pass.

## Branch Flow

1. Start from `dev/initial` unless the user names another development branch.
2. Create a focused branch named `dev/<helper-or-behavior>`.
3. Keep `main` untouched until the larger body of work is done.
4. Use release-note-friendly `feat:` merge commits when merging behavior back
   into `dev/initial`.
5. Use `refactor:` commits for cleanup-only work that should be excluded from
   user release notes.

## Extreme TDD Cycle

1. Add or update Bats integration tests under `integration/` for the desired
   real behavior. Include the happy path and relevant non-happy paths such as
   missing names, missing devices, invalid arguments, unavailable tooling, or
   command failures when those are part of the helper's contract.
2. Ask the user to run the integration test command and report the RED result.
   Do not spend Codex execution time running integration tests by default.
3. Confirm the user-reported RED state fails for the expected reason.
4. Stop for user review before committing the red integration tests.
5. After approval, commit the red integration tests with `test: ...`.
6. Add one focused Bats unit test under `test/` for the next required helper
   behavior.
7. Run the unit test and confirm RED for the expected reason.
8. Commit the red unit test with `test: ...`.
9. Implement the minimum Bash helper code needed to make that unit test green.
10. Run `bats test` locally. Ask the user to run the relevant integration test
    command, then `bats test integration`, and report the results.
11. Continue the unit red-green-refactor cycle until all scoped integration
    tests are user-confirmed green.
12. Stop for user review before committing the unit test and helper changes
    that make the integration tests green.
13. After approval, commit the green implementation with `feat: ...`.
14. Refactor only if there is useful cleanup after green; keep it in a separate
    `refactor:` commit.
15. Merge the feature branch back into `dev/initial` with `--no-ff` and a
    release-note-friendly `feat:` merge commit.
16. After merging, leave any repo-refactoring uncommitted for user review
    before creating a `refactor:` commit.

## Review Gates

Default to stopping at these points:

- before committing the first red integration test
- before spending Codex time on integration-test execution; ask the user to run
  integration commands by default
- before committing function/unit-test changes that make the integration test
  green
- after merging the feature branch back to `dev/initial`, before committing any
  repo-refactoring

When stopping for review, summarize the changed files, the verification command
the user should run, any unit-test result Codex already ran, and the expected
next commit message.

## Guardrails

- Do not add helper functions, flags, wrappers, abstractions, or extra unit
  cases unless the current integration test requires them.
- Prefer existing helper files:
  - simulator behavior: `lib/simulators.sh`, `test/simulators.bats`,
    `integration/simulators_*.bats`, `test/helpers/mock_xcrun.bash`
  - xcodebuild behavior: `lib/xcodebuild.sh`, `test/xcodebuild.bats`,
    `test/helpers/mock_xcodebuild.bash`
- Keep Bats fixtures in shared mock helpers once duplication appears.
- Integration tests may require CoreSimulator access and can be slow. Ask the
  user to run them by default. Only run integration tests from Codex when the
  user explicitly asks Codex to run them.

## Verification Commands

Run the narrowest command first, then broaden:

```bash
bats integration/<target>.bats
bats test/<target>.bats
bats test
bats test integration
```

Default ownership:

- Codex runs unit tests such as `bats test` and targeted `bats test/<target>.bats`.
- The user runs integration tests such as `bats integration/<target>.bats` and
  `bats test integration`, then reports the result.

Use `bash -n` for changed Bash files before committing:

```bash
bash -n lib/*.sh test/helpers/*.bash test/*.bats integration/*.bats
```
