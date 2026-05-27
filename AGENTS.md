# Agent Instructions

## Superpowers

Use the Superpowers plugin/process when available. For implementation work, use
the Superpowers TDD workflow and apply the repo-specific Extreme TDD rule below.

## Extreme TDD

Behavior changes in this repo must start with an integration test.

Follow this cycle:

1. Create or update a Bats integration test that describes the real behavior.
2. Run that integration test and confirm it fails for the expected reason.
3. Add one focused Bats unit test for the next required helper behavior.
4. Run the unit test and confirm it fails for the expected reason.
5. Implement the minimum Bash code needed to pass that unit test.
6. Refactor only while the unit test remains green.
7. Repeat unit red-green-refactor until the integration test is green.
8. Run both unit and integration tests.
9. Refactor one final time only if needed, keeping all tests green.

The integration test is the scope guard. Do not add helper functions, command
options, wrappers, abstractions, or extra unit tests unless they are required to
make the current integration test pass.

## Test commands

Run unit tests with:

```bash
bats test
```

Run integration tests with:

```bash
bats integration
```

Run everything with:

```bash
bats test integration
```

Integration tests may call Xcode and CoreSimulator tools directly. If a
sandboxed agent cannot access those tools, rerun the integration command with
the required approval instead of weakening the test.

## Scope

Keep edits narrowly focused. This repo is a reusable Bash automation library for
Xcode and iOS repositories, so app-specific behavior belongs in consuming repos
unless the README explicitly lists it as reusable library work.
