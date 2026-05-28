#!/usr/bin/env bats

# Copy this file into a consuming repo's test/integration/ directory.
# It assumes examples/02-ui-baseline-setup.bats has created the baseline image.

source "$BATS_TEST_DIRNAME/../xrt-example-config.bash"

load "$XRT_TOOLS_DIR/test/helpers/bats_setup"

setup() {
  source "$XRT_TOOLS_DIR/lib/simulators.sh"
  source "$XRT_TOOLS_DIR/lib/xcodebuild.sh"
}

baseline_udid() {
  cat "$XRT_BASELINE_STATE_DIR/baseline-iphone-udid"
}

@test "baseline simulator state exists" {
  run test -s "$XRT_BASELINE_STATE_DIR/baseline-iphone-udid"

  assert_success
}

@test "UITestsLaunchTests can run from baseline in parallel mode" {
  run xrt_xcodebuild_run_ui_tests \
    "$XRT_UI_TEST_PROJECT" \
    "$XRT_UI_TEST_SCHEME" \
    "$(baseline_udid)" \
    "$XRT_UI_TEST_SMOKE_SELECTOR" \
    "normal"

  assert_success
}

# Enable this test after setting your app's project and scheme values.
# @test "app UI smoke tests can run from baseline" {
#   run xrt_xcodebuild_run_ui_tests \
#     "$XRT_PROJECT_UI_TEST_PROJECT" \
#     "$XRT_PROJECT_UI_TEST_SCHEME" \
#     "$(baseline_udid)" \
#     "$XRT_PROJECT_UI_TEST_SMOKE_SELECTOR" \
#     "normal"
#
#   assert_success
# }

# Enable this test after setting a targeted selector for your app.
# @test "targeted app UI test can run from baseline" {
#   run xrt_xcodebuild_run_ui_tests \
#     "$XRT_PROJECT_UI_TEST_PROJECT" \
#     "$XRT_PROJECT_UI_TEST_SCHEME" \
#     "$(baseline_udid)" \
#     "${XRT_PROJECT_UI_TEST_TARGET_SELECTOR:?Set XRT_PROJECT_UI_TEST_TARGET_SELECTOR}" \
#     "normal"
#
#   assert_success
# }
