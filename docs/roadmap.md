# Roadmap

This checklist tracks the original scaffold plan and current helper progress.

## Project setup

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

## Step 6: simulator helpers

### Approach

- Write failing Bats tests for simulator helper behavior.
- Implement the minimum `lib/simulators.sh` behavior needed to pass.
- Add test coverage for common `xcrun simctl` output parsing.
- Add test coverage for unavailable, missing, and duplicate simulator cases.
- Keep command execution mockable through test helpers.

### TDD progress checklist

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

## Step 7: xcodebuild helpers

### Approach

- Write failing Bats tests for `xcodebuild` helper behavior.
- Implement the minimum `lib/xcodebuild.sh` behavior needed to pass.
- Add test coverage for scheme, destination, result bundle, and retry argument
  construction.
- Add test coverage for command failure reporting.
- Keep `xcodebuild` invocation mockable through test helpers.

### TDD progress checklist

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

## Step 8: markdown check helpers

### Approach

- Write failing Bats tests for markdown check helper behavior.
- Implement the minimum `lib/markdown.sh` behavior needed to pass.
- Add test coverage for changed-file discovery.
- Add test coverage for missing files and empty markdown file sets.
- Keep external markdown tooling optional and easy to mock.

### TDD progress checklist

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

## Step 9: repo-check orchestration helpers

### Approach

- Write failing Bats tests for repo-check orchestration behavior.
- Implement the minimum `lib/repo_checks.sh` behavior needed to pass.
- Add test coverage for composing simulator, build, test, and markdown checks.
- Add test coverage for stop-on-failure behavior.
- Add test coverage for readable summary output.

### TDD progress checklist

- [ ] `test/repo_checks.bats`: failing tests for registering check steps.
- [ ] `lib/repo_checks.sh`: `xrt_repo_checks_add`.
- [ ] `test/repo_checks.bats`: failing tests for running checks in order.
- [ ] `lib/repo_checks.sh`: `xrt_repo_checks_run`.
- [ ] `test/repo_checks.bats`: failing tests for stopping on first failure.
- [ ] `lib/repo_checks.sh`: `xrt_repo_checks_stop_on_failure`.
- [ ] `test/repo_checks.bats`: failing tests for summary output.
- [ ] `lib/repo_checks.sh`: `xrt_repo_checks_print_summary`.
- [ ] `lib/logging.sh`: `xrt_log_info`, `xrt_log_warn`, and `xrt_log_error`.

## Step 10: executable wrappers

### Approach

- Write failing Bats tests for wrapper behavior.
- Implement `bin/prepare-simulators`.
- Implement `bin/run-ui-tests`.
- Implement `bin/run-repo-checks`.
- Verify wrappers delegate to `lib/` helpers instead of duplicating logic.
- Confirm wrappers fail clearly when required arguments are missing.

### TDD progress checklist

- [ ] `test/simulators.bats`: failing wrapper tests for preparing simulators.
- [ ] `bin/prepare-simulators`: `xrt_prepare_simulators_main`.
- [ ] `test/xcodebuild.bats`: failing wrapper tests for running UI tests.
- [ ] `bin/run-ui-tests`: `xrt_run_ui_tests_main`.
- [ ] `test/repo_checks.bats`: failing wrapper tests for running repo checks.
- [ ] `bin/run-repo-checks`: `xrt_run_repo_checks_main`.
- [ ] `test/helpers/assertions.bash`: assertions for wrapper exit status and
      output.

## Step 11: consuming repo usage

### Approach

- Add submodule usage instructions for ExpansePlanner.
- Document expected consuming-repo directory layout.
- Document how app-specific Bats checks should load this repo's helpers.
- Include an example pre-PR check file.
- Include a GitHub Actions usage example.

### TDD progress checklist

- [x] `README.md`: document local-path and remote-url submodule installation.
- [x] `README.md`: document consuming-repo helper loading.
- [x] `README.md`: document app-specific Bats check layout.
- [x] `README.md`: include a reusable starter UI baseline example.
- [ ] `README.md`: include an ExpansePlanner-oriented pre-PR example.
- [ ] `README.md`: include a GitHub Actions example.
