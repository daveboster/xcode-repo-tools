# xcode-repo-tools

## Purpose

`xcode-repo-tools` is a local-only reusable Bash automation library for Xcode
and iOS repositories.

The repo will hold shared helper libraries and executable wrappers for
simulator management, `xcodebuild` UI test execution, repo checks, markdown
checks, and logging.

## Two-layer architecture

### Layer 1: reusable Bash automation helper repo

This repo owns the reusable Bash helper code. Helpers live under `lib/`, and
command-line wrappers live under `bin/`.

The helpers should stay generic enough to be reused from multiple Xcode and iOS
app repositories.

### Layer 2: consuming app repos

App repositories, such as ExpansePlanner, can add this repo as a submodule and
write app-specific Bats files that call these helpers.

Those app-level Bats files should read like pre-PR or GitHub Actions check
specifications for the app repository.

## Why Bats is used differently in each layer

In this repo, Bats is the TDD and unit testing tool for Bash helper behavior.
Future implementation work should start with failing Bats tests, then add the
minimal Bash helper behavior needed to pass.

In consuming repos, Bats is primarily an orchestration and specification layer.
App-specific tests can describe readable pre-PR and GitHub Actions checks while
delegating reusable behavior to this repo.

## Extreme TDD workflow

This repo uses an Extreme TDD workflow for behavior implementation. Extreme TDD
starts with an integration test so each feature is anchored to a real outcome
before unit tests or helper code are added.

The cycle is:

1. Write an integration test for the desired behavior.
2. Run the integration test and confirm it is red for the expected reason.
3. Write the smallest unit test that moves the integration test closer to
   green.
4. Run the unit test and confirm it is red for the expected reason.
5. Implement the minimum Bash helper code needed to make that unit test green.
6. Refactor only while the unit test remains green.
7. Repeat the unit red-green-refactor cycle until the original integration test
   is green.
8. Refactor one final time if needed, with both unit and integration tests
   green before stopping.

The integration test limits the scope of implementation. Do not add unit tests,
helper functions, options, wrappers, or abstractions unless they are required to
make the current integration test pass.

## Current scope

The initial scaffold performs only Steps 1 through 5. Steps 6 through 11 are
listed here as the high-level progress tracker for future work:

- [x] Step 1: initialize or prepare the local repo.
- [x] Step 2: create the initial directory structure.
- [x] Step 3: add Bats helper dependencies.
- [x] Step 4: create the shared Bats setup helper.
- [x] Step 5: create placeholder files only.
- [ ] Step 6: implement simulator helpers using TDD.
- [ ] Step 7: implement `xcodebuild` helpers using TDD.
- [ ] Step 8: implement markdown check helpers using TDD.
- [ ] Step 9: implement repo-check orchestration helpers using TDD.
- [ ] Step 10: add executable wrappers.
- [ ] Step 11: add submodule usage instructions for ExpansePlanner.

Stop after scaffolding. Do not implement simulator, `xcodebuild`, markdown, or
repo-check helper behavior in this run.

## Future implementation plan

Future Bash helper behavior should follow the Extreme TDD workflow with Bats.

### Step 6: simulator helpers

#### Approach

- Write failing Bats tests for simulator helper behavior.
- Implement the minimum `lib/simulators.sh` behavior needed to pass.
- Add test coverage for common `xcrun simctl` output parsing.
- Add test coverage for unavailable, missing, and duplicate simulator cases.
- Keep command execution mockable through test helpers.

#### TDD progress checklist

- [ ] `lib/simulators.sh`: simulator helper functions.
  - [x] `xrt_sims_list_available`: listing available simulators
  - [ ] `xrt_sims_find_by_name`: finding a simulator by name and runtime
  - [ ] `xrt_sims_boot`: booting an available simulator
  - [ ] `xrt_sims_wait_until_booted`: waiting until a simulator is booted
- [ ] `test/helpers/mock_xcrun.bash`: mock helpers for `xcrun simctl`.
- [ ] `test/simulators.bats`: failing simulator helper tests.

### Step 7: xcodebuild helpers

#### Approach

- Write failing Bats tests for `xcodebuild` helper behavior.
- Implement the minimum `lib/xcodebuild.sh` behavior needed to pass.
- Add test coverage for scheme, destination, result bundle, and retry argument
  construction.
- Add test coverage for command failure reporting.
- Keep `xcodebuild` invocation mockable through test helpers.

#### TDD progress checklist

- [ ] `test/xcodebuild.bats`: failing tests for UI test command argument
      construction.
- [ ] `lib/xcodebuild.sh`: `xrt_xcodebuild_ui_test_args`.
- [ ] `test/xcodebuild.bats`: failing tests for running UI tests.
- [ ] `lib/xcodebuild.sh`: `xrt_xcodebuild_run_ui_tests`.
- [ ] `test/xcodebuild.bats`: failing tests for result bundle path handling.
- [ ] `lib/xcodebuild.sh`: `xrt_xcodebuild_result_bundle_path`.
- [ ] `test/xcodebuild.bats`: failing tests for readable command failure
      output.
- [ ] `lib/xcodebuild.sh`: `xrt_xcodebuild_report_failure`.
- [ ] `test/helpers/mock_xcodebuild.bash`: mock helpers for `xcodebuild`.

### Step 8: markdown check helpers

#### Approach

- Write failing Bats tests for markdown check helper behavior.
- Implement the minimum `lib/markdown.sh` behavior needed to pass.
- Add test coverage for changed-file discovery.
- Add test coverage for missing files and empty markdown file sets.
- Keep external markdown tooling optional and easy to mock.

#### TDD progress checklist

- [ ] `test/markdown.bats`: failing tests for discovering markdown files.
- [ ] `lib/markdown.sh`: `xrt_markdown_files`.
- [ ] `test/markdown.bats`: failing tests for detecting changed markdown
      files.
- [ ] `lib/markdown.sh`: `xrt_markdown_changed_files`.
- [ ] `test/markdown.bats`: failing tests for empty markdown file sets.
- [ ] `lib/markdown.sh`: `xrt_markdown_require_files_or_skip`.
- [ ] `test/markdown.bats`: failing tests for markdown check command
      delegation.
- [ ] `lib/markdown.sh`: `xrt_markdown_run_checks`.

### Step 9: repo-check orchestration helpers

#### Approach

- Write failing Bats tests for repo-check orchestration behavior.
- Implement the minimum `lib/repo_checks.sh` behavior needed to pass.
- Add test coverage for composing simulator, build, test, and markdown checks.
- Add test coverage for stop-on-failure behavior.
- Add test coverage for readable summary output.

#### TDD progress checklist

- [ ] `test/repo_checks.bats`: failing tests for registering check steps.
- [ ] `lib/repo_checks.sh`: `xrt_repo_checks_add`.
- [ ] `test/repo_checks.bats`: failing tests for running checks in order.
- [ ] `lib/repo_checks.sh`: `xrt_repo_checks_run`.
- [ ] `test/repo_checks.bats`: failing tests for stopping on first failure.
- [ ] `lib/repo_checks.sh`: `xrt_repo_checks_stop_on_failure`.
- [ ] `test/repo_checks.bats`: failing tests for summary output.
- [ ] `lib/repo_checks.sh`: `xrt_repo_checks_print_summary`.
- [ ] `lib/logging.sh`: `xrt_log_info`, `xrt_log_warn`, and `xrt_log_error`.

### Step 10: executable wrappers

#### Approach

- Write failing Bats tests for wrapper behavior.
- Implement `bin/prepare-simulators`.
- Implement `bin/run-ui-tests`.
- Implement `bin/run-repo-checks`.
- Verify wrappers delegate to `lib/` helpers instead of duplicating logic.
- Confirm wrappers fail clearly when required arguments are missing.

#### TDD progress checklist

- [ ] `test/simulators.bats`: failing wrapper tests for preparing simulators.
- [ ] `bin/prepare-simulators`: `xrt_prepare_simulators_main`.
- [ ] `test/xcodebuild.bats`: failing wrapper tests for running UI tests.
- [ ] `bin/run-ui-tests`: `xrt_run_ui_tests_main`.
- [ ] `test/repo_checks.bats`: failing wrapper tests for running repo checks.
- [ ] `bin/run-repo-checks`: `xrt_run_repo_checks_main`.
- [ ] `test/helpers/assertions.bash`: assertions for wrapper exit status and
      output.

### Step 11: consuming repo usage

#### Approach

- Add submodule usage instructions for ExpansePlanner.
- Document expected consuming-repo directory layout.
- Document how app-specific Bats checks should load this repo's helpers.
- Include an example pre-PR check file.
- Include a GitHub Actions usage example.

#### TDD progress checklist

- [ ] `README.md`: document local-path and remote-url submodule installation.
- [ ] `README.md`: document consuming-repo helper loading.
- [ ] `README.md`: document app-specific Bats check layout.
- [ ] `README.md`: include an ExpansePlanner-oriented pre-PR example.
- [ ] `README.md`: include a GitHub Actions example.

## Bats dependency notes

This repo uses the following Bats helper dependencies under `test/test_helper/`:

- `bats-support`
- `bats-assert`

They are added as git submodules so this repo can keep test helper dependencies
explicit and reproducible.

## VS Code test task

This repo includes a default VS Code test task at `.vscode/tasks.json`.

The task runs:

```bash
bats test
```

Integration tests that call local Xcode tools directly live under
`integration/`. Run them with:

```bash
bats integration
```

Run both unit and integration tests with:

```bash
bats test integration
```

VS Code keybindings are user-level settings, not repo-level settings. To run
the default test task with `Cmd+U`, add this to your VS Code Keyboard Shortcuts
JSON. To run all Bats tests, including integration tests, use `Cmd+Shift+U`:

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

## Future submodule usage example

```bash
git submodule add <repo-url-or-local-path> tools/xcode-repo-tools
```
