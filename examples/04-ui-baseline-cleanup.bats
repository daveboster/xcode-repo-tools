#!/usr/bin/env bats

# Copy this file into a consuming repo's test/integration/ directory.
# It stops and deletes the reusable iPhone baseline simulator.

source "$BATS_TEST_DIRNAME/../xrt-example-config.bash"

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
