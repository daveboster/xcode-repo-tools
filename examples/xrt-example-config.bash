#!/usr/bin/env bash

# Shared defaults for copied walkthrough examples.

if [[ -z "${XRT_APP_ROOT:-}" ]]; then
  if [[ "$(basename "$BATS_TEST_DIRNAME")" == "integration" ]]; then
    XRT_APP_ROOT="$BATS_TEST_DIRNAME/../.."
  else
    XRT_APP_ROOT="$BATS_TEST_DIRNAME/.."
  fi
fi

XRT_TOOLS_DIR="${XRT_TOOLS_DIR:-$XRT_APP_ROOT/tools/xcode-repo-tools}"
XRT_BASELINE_SIM_NAME="${XRT_BASELINE_SIM_NAME:-Bats App Baseline iPhone}"
XRT_BASELINE_STATE_DIR="${XRT_BASELINE_STATE_DIR:-$XRT_APP_ROOT/.xrt-state}"

# Defaults for this repo's bundled UI test fixture. These are useful for
# creating or validating a reusable baseline simulator before app tests run.
XRT_UI_TEST_PROJECT="${XRT_UI_TEST_PROJECT:-$XRT_TOOLS_DIR/src/UITests/UITests.xcodeproj}"
XRT_UI_TEST_SCHEME="${XRT_UI_TEST_SCHEME:-UITests}"
XRT_UI_TEST_SMOKE_SELECTOR="${XRT_UI_TEST_SMOKE_SELECTOR:-UITests/UITestsLaunchTests}"
XRT_UI_TEST_ICLOUD_SETUP_SELECTOR="${XRT_UI_TEST_ICLOUD_SETUP_SELECTOR:-UITests/UITests/test_Login_With_Apple_Id}"

# Defaults for the consuming app's own UI test project. Override these once in
# the environment instead of repeating project paths in each scenario file.
XRT_PROJECT_UI_TEST_PROJECT="${XRT_PROJECT_UI_TEST_PROJECT:-YourApp.xcodeproj}"
XRT_PROJECT_UI_TEST_SCHEME="${XRT_PROJECT_UI_TEST_SCHEME:-YourAppUITests}"
XRT_PROJECT_UI_TEST_SMOKE_SELECTOR="${XRT_PROJECT_UI_TEST_SMOKE_SELECTOR:-UITests/UITestsLaunchTests}"
XRT_PROJECT_UI_TEST_TARGET_SELECTOR="${XRT_PROJECT_UI_TEST_TARGET_SELECTOR:-}"

export XRT_APP_ROOT
export XRT_TOOLS_DIR
export XRT_BASELINE_SIM_NAME
export XRT_BASELINE_STATE_DIR
export XRT_UI_TEST_PROJECT
export XRT_UI_TEST_SCHEME
export XRT_UI_TEST_SMOKE_SELECTOR
export XRT_UI_TEST_ICLOUD_SETUP_SELECTOR
export XRT_PROJECT_UI_TEST_PROJECT
export XRT_PROJECT_UI_TEST_SCHEME
export XRT_PROJECT_UI_TEST_SMOKE_SELECTOR
export XRT_PROJECT_UI_TEST_TARGET_SELECTOR
