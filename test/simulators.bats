#!/usr/bin/env bats

load "helpers/bats_setup"
load "helpers/mock_xcrun"

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  mkdir -p "$BATS_TEST_TMPDIR/bin"
}

@test "xrt_sims_list_available prints available simulator name udid and state" {
  xrt_mock_xcrun_default_simctl_list_devices_available \
    "$BATS_TEST_TMPDIR/bin" \
    "$BATS_TEST_TMPDIR/simctl-devices.txt"

  run xrt_sims_list_available

  assert_success
  assert_line $'iPhone 17\tAAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE\tShutdown'
  assert_line $'iPhone 17 Pro\t11111111-2222-3333-4444-555555555555\tBooted'
}

@test "xrt_sims_find_by_name returns the exact matching simulator row" {
  xrt_mock_xcrun_default_simctl_list_devices_available \
    "$BATS_TEST_TMPDIR/bin" \
    "$BATS_TEST_TMPDIR/simctl-devices.txt"

  run xrt_sims_find_by_name "iPhone 17 Pro"

  assert_success
  assert_output $'iPhone 17 Pro\t11111111-2222-3333-4444-555555555555\tBooted'
}

@test "xrt_sims_find_by_name fails when no simulator matches the name" {
  xrt_mock_xcrun_default_simctl_list_devices_available \
    "$BATS_TEST_TMPDIR/bin" \
    "$BATS_TEST_TMPDIR/simctl-devices.txt"

  run xrt_sims_find_by_name "XRT Missing Simulator"

  assert_failure
  assert_output --partial "No available simulator named: XRT Missing Simulator"
}

@test "xrt_sims_wait_until_booted boots shutdown simulator and waits for bootstatus" {
  xrt_mock_xcrun_default_simctl_list_devices_available \
    "$BATS_TEST_TMPDIR/bin" \
    "$BATS_TEST_TMPDIR/simctl-devices.txt" \
    "$BATS_TEST_TMPDIR/xcrun-commands.log"

  run xrt_sims_wait_until_booted "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"

  assert_success
  grep -Fx "simctl boot AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE" \
    "$BATS_TEST_TMPDIR/xcrun-commands.log"
  grep -Fx "simctl bootstatus AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE -b" \
    "$BATS_TEST_TMPDIR/xcrun-commands.log"
}
