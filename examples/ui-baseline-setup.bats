#!/usr/bin/env bats

# Copy this file into a consuming repo's integration/ directory.
# It creates or recreates a reusable iPhone baseline simulator.

XRT_APP_ROOT="${XRT_APP_ROOT:-$BATS_TEST_DIRNAME/..}"
XRT_TOOLS_DIR="${XRT_TOOLS_DIR:-$XRT_APP_ROOT/tools/xcode-repo-tools}"
XRT_BASELINE_SIM_NAME="${XRT_BASELINE_SIM_NAME:-Bats App Baseline iPhone}"
XRT_BASELINE_STATE_DIR="${XRT_BASELINE_STATE_DIR:-$XRT_APP_ROOT/.xrt-state}"

load "$XRT_TOOLS_DIR/test/helpers/bats_setup"

setup_file() {
  source "$XRT_TOOLS_DIR/lib/simulators.sh"

  mkdir -p "$XRT_BASELINE_STATE_DIR"

  local existing_row
  local existing_udid
  if existing_row="$(xrt_sims_find_by_name "$XRT_BASELINE_SIM_NAME" 2>/dev/null)"; then
    existing_udid="$(printf '%s\n' "$existing_row" | awk -F '\t' '{ print $2 }')"
    xrt_sims_stop "$existing_udid" >/dev/null
    xrt_sims_delete "$existing_udid" >/dev/null
  fi
}

setup() {
  source "$XRT_TOOLS_DIR/lib/simulators.sh"
}

baseline_udid() {
  cat "$XRT_BASELINE_STATE_DIR/baseline-iphone-udid"
}

@test "create iPhone baseline simulator" {
  local template_row
  local template_name
  local created_row
  local created_udid

  template_row="$(xrt_sims_list_available | awk -F '\t' '$1 ~ /^iPhone / { print; exit }')"
  template_name="$(printf '%s\n' "$template_row" | awk -F '\t' '{ print $1 }')"

  run test -n "$template_name"
  assert_success

  run xrt_sims_create "$XRT_BASELINE_SIM_NAME" "$template_name"
  assert_success

  created_row="$(xrt_sims_find_by_name "$XRT_BASELINE_SIM_NAME")"
  created_udid="$(printf '%s\n' "$created_row" | awk -F '\t' '{ print $2 }')"

  printf '%s\n' "$created_udid" >"$XRT_BASELINE_STATE_DIR/baseline-iphone-udid"
}

@test "boot iPhone baseline simulator" {
  run xrt_sims_wait_until_booted "$(baseline_udid)"

  assert_success
}

# Enable this test when your setup requires credential-backed UI tests.
# @test "credential environment variables are available" {
#   run test -n "${TEST_USERNAME:-}"
#   assert_success
#
#   run test -n "${TEST_PASSWORD:-}"
#   assert_success
# }

# Enable this test after setting project, scheme, and selector values for your
# app. Run this in specific mode so the baseline simulator itself is primed.
# @test "prime iCloud baseline in non-parallel mode" {
#   source "$XRT_TOOLS_DIR/lib/xcodebuild.sh"
#
#   run xrt_xcodebuild_run_ui_tests \
#     "${XRT_UI_TEST_PROJECT:?Set XRT_UI_TEST_PROJECT}" \
#     "${XRT_UI_TEST_SCHEME:?Set XRT_UI_TEST_SCHEME}" \
#     "$(baseline_udid)" \
#     "${XRT_UI_TEST_ICLOUD_SETUP_SELECTOR:?Set XRT_UI_TEST_ICLOUD_SETUP_SELECTOR}" \
#     "specific"
#
#   assert_success
# }
