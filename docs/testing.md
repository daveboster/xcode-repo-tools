# Testing

This repo uses Bats for Bash unit tests and integration scenarios.

## Install test dependencies

Initialize submodules before running tests:

```bash
git submodule update --init --recursive
```

The repo keeps Bats dependencies under `test/`:

- `test/bats`
- `test/test_helper/bats-support`
- `test/test_helper/bats-assert`

## Unit tests

Run the unit suite while developing:

```bash
test/bats/bin/bats test
```

Run shell syntax checks:

```bash
bash -n lib/*.sh test/helpers/*.bash test/*.bats integration/*.bats checks/*.bats bin/*
```

Run the local pre-PR suite:

```bash
test/bats/bin/bats checks/pre_pr.bats
```

The pre-PR suite runs unit Bats tests and checks tracked files for common
secret patterns, local-only file leaks, commit-message convention, and
accidental changes to the committed UI test credential template.

GitHub Actions runs the same suite through `.github/workflows/pre-pr.yml` on
pull requests and pushes to `main`.

## Integration tests

Integration scenarios that exercise real simulators or Xcode should be run on a
prepared local machine when the changed behavior requires that coverage:

```bash
test/bats/bin/bats integration
```

Run unit and integration suites together:

```bash
test/bats/bin/bats test integration
```

## VS Code tasks

This repo includes default VS Code tasks at `.vscode/tasks.json`.

The default test task runs:

```bash
bats test
```

The integration and all-test tasks source the credential loader first:

```bash
source bin/load-ui-test-credentials && bats integration
source bin/load-ui-test-credentials && bats test integration
```

If `TEST_USERNAME` or `TEST_PASSWORD` is missing, the loader checks macOS
Keychain first, then prompts in the VS Code task terminal.

VS Code keybindings are user-level settings. To run the default test task with
`Cmd+U`, add this to your VS Code Keyboard Shortcuts JSON. To run all Bats
tests, including integration tests, use `Cmd+Shift+U`:

```json
[
  {
    "key": "cmd+u",
    "command": "workbench.action.tasks.test"
  },
  {
    "key": "cmd+shift+u",
    "command": "workbench.action.tasks.runTask",
    "args": "Run all Bats tests"
  }
]
```

## UI test credentials

Some integration tests run Xcode UI tests that require credentials. For the
sample UI test fixture, set these environment variables before running
integration tests:

- `TEST_USERNAME`
- `TEST_PASSWORD`

The fixture uses `src/UITests/UITests/UITestCredentials.swift` as a local
credential bridge. The committed file contains template values only. Before
running the troubleshooting helper, source the credential loader; the helper
rewrites that Swift file locally with the current `TEST_USERNAME` and
`TEST_PASSWORD` values, then runs the UI test.

The credential Swift file is marked with `git update-index --skip-worktree`
after the template is committed, so local secret values do not show in normal
git status output.

Do not commit credential values to this repo. The repo-level VS Code tasks load
credentials with `bin/load-ui-test-credentials`; copy
`.vscode/user-tasks.example.json` into your user-level VS Code `tasks.json` only
when you want a user-level override.

With the recommended keybindings in place:

- `Cmd+U` runs the default unit test task.
- `Cmd+Shift+U` runs all Bats tests, including credential-backed integration
  tests, and prompts for missing credentials.
- Running the `Run Bats integration tests` task directly uses the same
  credential loader.

From a terminal, use inline environment variables instead:

```bash
TEST_USERNAME="your-test-account@example.com" \
TEST_PASSWORD="your-test-password" \
bats integration/xcodebuild_ui_tests_lifecycle.bats
```

You can also source the local credential loader before running UI tests:

```bash
source bin/load-ui-test-credentials
bin/run-ui-test-helper
```

The loader exports `TEST_USERNAME` and `TEST_PASSWORD` into the current shell.
It first checks macOS Keychain for generic passwords in the
`xcode-repo-tools-ui-tests` service, then prompts without echoing input when a
value is missing.

To store the credentials in Keychain:

```bash
security add-generic-password \
  -s xcode-repo-tools-ui-tests \
  -a TEST_USERNAME \
  -w "your-test-account@example.com" \
  -U

security add-generic-password \
  -s xcode-repo-tools-ui-tests \
  -a TEST_PASSWORD \
  -w "your-test-password" \
  -U
```
