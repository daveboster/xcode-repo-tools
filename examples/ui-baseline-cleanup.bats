#!/usr/bin/env bats

# Copy this file into a consuming repo's integration/ directory.
# It stops and deletes the reusable iPhone baseline simulator.

XRT_APP_ROOT="${XRT_APP_ROOT:-$BATS_TEST_DIRNAME/..}"
XRT_TOOLS_DIR="${XRT_TOOLS_DIR:-$XRT_APP_ROOT/tools/xcode-repo-tools}"
XRT_BASELINE_STATE_DIR="${XRT_BASELINE_STATE_DIR:-$XRT_APP_ROOT/.xrt-state}"

load "$XRT_TOOLS_DIR/test/helpers/bats_setup"

setup() {
  source "$XRT_TOOLS_DIR/lib/simulators.sh"
}

baseline_udid() {
  cat "$XRT_BASELINE_STATE_DIR/baseline-iphone-udid"
}

@test "baseline simulator state exists" {
  run test -s "$XRT_BASELINE_STATE_DIR/baseline-iphone-udid"

  assert_success
}

@test "stop baseline simulator" {
  run xrt_sims_stop "$(baseline_udid)"

  assert_success
}

@test "delete baseline simulator" {
  run xrt_sims_delete "$(baseline_udid)"

  assert_success

  rm -f "$XRT_BASELINE_STATE_DIR/baseline-iphone-udid"
}
