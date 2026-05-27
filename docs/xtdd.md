# Extreme Test Drive Development (XTDD) workflow

This repo uses an Extreme TDD workflow for helper behavior. Extreme TDD starts
with an integration test so each feature is anchored to a real outcome before
unit tests or helper code are added.

## Cycle

1. Write an integration test for the desired behavior.
2. Run the integration test and confirm it is red for the expected reason.
3. Write the smallest unit test that moves the integration test closer to
   green.
4. Run the unit test and confirm it is red for the expected reason.
5. Implement the minimum Bash helper code needed to make that unit test green.
6. Refactor only while the unit test remains green.
7. Repeat the unit red-green-refactor cycle until the original integration test
   is green.
8. Ask the developer to run integration tests when they require real simulator
   or Xcode time.
9. Refactor one final time if needed, with unit tests and developer-confirmed
   integration tests green before stopping.

The integration test limits the scope of implementation. Do not add unit tests,
helper functions, options, wrappers, or abstractions unless they are required to
make the current integration test pass.

## Branch and commit flow

Use this branch flow when adding one helper behavior:

1. Start from the current development branch.
2. Create a focused feature branch, such as `dev/xrt-sims-find-by-name`.
3. Add the first integration test for the desired real behavior.
4. Ask the developer to run the integration test and confirm it fails for the
   expected reason.
5. Commit that red integration test on the feature branch with `test:`.
6. Add one focused unit test for the next required helper behavior.
7. Run the unit test and confirm it fails for the expected reason.
8. Commit that red unit test with `test:`.
9. Implement the smallest helper code needed to make the unit test pass.
10. Run unit tests and local syntax checks.
11. Ask the developer to run the target integration test.
12. Commit the green implementation with `feat:` or `fix:`.
13. Skip refactor work if there is no meaningful cleanup.
14. Do follow-up refactors separately with `refactor:` commits so they can be
    excluded from user-facing release notes.

## Repo-local skill

This repo includes a repo-local Codex skill for this workflow at
`.codex/skills/xcode-repo-tools-xtdd`. Using this is especially helpful for new contributors or contributors unfamiliar with some of the languages/scripting.

Example prompts:

```text
Use $xcode-repo-tools-xtdd to implement xrt_sims_boot.
Start from main, create a focused dev branch, add the red integration test first, then use unit red-green-refactor commits until the integration test is green.
```

```text
Use $xcode-repo-tools-xtdd for the next simulator helper: xrt_sims_boot.
```

```text
Use $xcode-repo-tools-xtdd to start xrt_sims_wait_until_booted.
Only create the focused branch and commit the first red integration test. Stop before unit tests or implementation.
```
