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

## Getting started in an app repo

Add this repo to an existing Xcode or iOS app repository as a submodule:

```bash
git submodule add https://github.com/daveboster/xcode-repo-tools.git tools/xcode-repo-tools
git submodule update --init --recursive
```

Use the shared Bats setup helper from your app repo tests:

```bash
load "tools/xcode-repo-tools/test/helpers/bats_setup"

setup() {
  source "tools/xcode-repo-tools/lib/simulators.sh"
  source "tools/xcode-repo-tools/lib/xcodebuild.sh"
}
```

Then write app-specific Bats files that read like pre-PR checks while delegating
common simulator and `xcodebuild` behavior to this repo.

For a starter UI baseline scenario, copy:

```bash
tools/xcode-repo-tools/examples/starter-ui-baseline.bats
```

into your app repo's own `integration/` directory and update these values as
needed:

- `XRT_TOOLS_DIR`: submodule path, defaults to `tools/xcode-repo-tools`.
- `XRT_BASELINE_SIM_NAME`: reusable baseline simulator name.
- `XRT_UI_TEST_PROJECT`: app Xcode project path.
- `XRT_UI_TEST_SCHEME`: app UI test scheme.
- `XRT_UI_TEST_LOGIN_SELECTOR`: non-parallel test that primes the baseline.
- `XRT_UI_TEST_SMOKE_SELECTOR`: parallel-safe test selector that validates
  baseline reuse.

Run it from the app repo with credentials loaded into the shell:

```bash
TEST_USERNAME="your-test-account@example.com" \
TEST_PASSWORD="your-test-password" \
bats integration/starter-ui-baseline.bats
```

## Pre-PR checks

Before opening a pull request, make sure submodules are initialized:

```bash
git submodule update --init --recursive
```

Run the unit suite while developing:

```bash
test/bats/bin/bats test
```

Run shell syntax checks for the Bash libraries, test helpers, tests, integration
scenarios, checks, and executable wrappers:

```bash
bash -n lib/*.sh test/helpers/*.bash test/*.bats integration/*.bats checks/*.bats bin/*
```

Run the repo's local pre-PR Bats suite before opening the pull request:

```bash
test/bats/bin/bats checks/pre_pr.bats
```

The pre-PR suite runs the unit Bats tests and checks tracked files for common
secret patterns, local-only file leaks, and accidental changes to the committed
UI test credential template.

GitHub Actions runs the same suite through `.github/workflows/pre-pr.yml` on
pull requests and pushes to `main`.

Integration scenarios that exercise real simulators or Xcode should be run by
the developer on a prepared local machine when the changed behavior requires
that coverage:

```bash
test/bats/bin/bats integration
```

## Commit and release-note convention

Commit messages should use Conventional Commits so release notes can be
generated from git history. The first line should be short, clear, and
user-readable:

```text
fix: avoid simulator status pipe leak
```

Use the commit type to control release-note behavior:

- `feat:` for new user-visible helper behavior.
- `fix:` for user-visible bug fixes and reliability improvements.
- `docs:`, `test:`, `refactor:`, `ci:`, and `chore:` for internal changes that
  should usually be excluded from user-facing release notes.

Release notes should be short bullet points written for users, not an
implementation changelog:

```text
- Improved reliability of simulator status checks.
- Added reusable UI test baseline helpers.
```

### GitHub ruleset setup checklist

Use a GitHub repository ruleset to keep commit history compatible with this
release-note workflow. GitHub documents repository rulesets and commit metadata
regex restrictions in
[Creating rulesets for a repository](https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository).

The repository is configured with a GitHub ruleset plus the required
`Pre-PR Checks` workflow. Native GitHub branch rules enforce the protected
branch and required-check behavior; the required workflow enforces the commit
message convention for the commits in a pull request.

- [x] Target `main`.
- [x] Require pull requests before merging.
- [x] Require the `Pre-PR Checks` workflow to pass.
- [x] Require commit messages to match the Conventional Commit prefix:
      `^(feat|fix|docs|test|refactor|ci|chore)(\([a-z0-9._-]+\))?!?: .{1,72}$`
- [x] Require the first commit-message line to stay short enough for release
      tooling and review summaries.
- [x] Prefer squash or rebase merges so the merged commit message is the
      release-note source.
- [x] Use `feat:` and `fix:` for release-note-worthy changes; use the internal
      types for documentation, tests, refactors, and CI-only work.

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

## XTDD branch and commit flow

Use this branch flow when adding one helper behavior:

1. Start from the current development branch, usually `dev/initial`.
2. Create a focused feature branch, such as `dev/xrt-sims-find-by-name`.
3. Add the first integration test for the desired real behavior.
4. Run the integration test and confirm it fails for the expected reason.
5. Commit that red integration test on the feature branch with `test:`.
6. Add one focused unit test for the next required helper behavior.
7. Run the unit test and confirm it fails for the expected reason.
8. Commit that red unit test with `test:`.
9. Implement the smallest helper code needed to make the unit test pass.
10. Run unit tests, the target integration test, and then the full suite.
11. Commit the green implementation with `feat:`.
12. Skip refactor work if there is no meaningful cleanup.
13. Merge the feature branch back into `dev/initial` with a release-note-ready
    `feat:` merge commit.
14. Do follow-up refactors separately with `refactor:` commits so they can be
    excluded from user-facing release notes.

Release-note guidance:

- Use `feat:` commits or merge commits for user-visible behavior.
- Use `test:` commits for red test checkpoints.
- Use `refactor:` commits for cleanup-only work that should not appear in user
  release notes.

This repo also includes a repo-local Codex skill for this workflow at
`.codex/skills/xcode-repo-tools-xtdd`. Use it for future helper work when you
want the integration-first branch flow applied consistently.

Example skill prompts:

```text
Use $xcode-repo-tools-xtdd to implement xrt_sims_boot.
Start from dev/initial, create a focused dev branch, add the red integration test first, then use unit red-green-refactor commits until the integration test is green.
```

```text
Use $xcode-repo-tools-xtdd for the next simulator helper: xrt_sims_boot.
```

```text
Use $xcode-repo-tools-xtdd to start xrt_sims_wait_until_booted.
Only create the focused branch and commit the first red integration test. Stop before unit tests or implementation.
```

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
  - [x] `xrt_sims_find_by_name`: finding a simulator by name and runtime
  - [x] `xrt_sims_wait_until_booted`: booting a simulator if needed and
        waiting until it is booted
  - [x] `xrt_sims_status`: returning whether a simulator is booted.
    - [x] Return an error when the simulator cannot be found.
    - [x] Support a quiet mode option that suppresses the not-found error.
  - [x] `xrt_sims_stop`: stopping a simulator if it exists.
    - [x] Return success when the simulator is already stopped.
    - [x] Return an error when the simulator cannot be found.
  - [x] `xrt_sims_delete`: deleting an existing simulator.
    - [x] Return an error when the simulator is booted.
    - [ ] Support a force option that shuts down a booted simulator before
          deleting it.
  - [x] `xrt_sims_create`: creating a simulator.
    - [x] Create a simulator from an existing available simulator name as the
          template.
    - [x] Return an error when the simulator already exists.
  - [ ] `xrt_sims_clone`: cloning a source simulator and shutting down the
        source simulator first if needed.
    - [ ] Return an error when the destination simulator already exists.
    - [ ] Support a force option that deletes an existing destination before
          cloning.
  - [ ] `xrt_sims_boot`: deferred until an async boot-only use case exists
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

### UI test environment variables

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

Do not commit credential values to this repo. To use the VS Code keyboard
shortcuts with local credentials, copy `.vscode/user-tasks.example.json` into
your user-level VS Code `tasks.json`, then replace the placeholder credential
values.

With those user-level task overrides in place:

- `Cmd+U` runs the default unit test task.
- `Cmd+Shift+U` runs all Bats tests, including credential-backed integration
  tests.
- Running the `Run Bats integration tests` task directly also includes the
  credential environment variables.

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

## Future submodule usage example

```bash
git submodule add https://github.com/daveboster/xcode-repo-tools.git tools/xcode-repo-tools
```
