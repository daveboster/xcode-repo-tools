#!/usr/bin/env bats

load "helpers/bats_setup"
load "helpers/mock_xcrun"

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  mkdir -p "$BATS_TEST_TMPDIR/bin"
}

setup_default_xcrun_mock() {
  xrt_mock_xcrun_default_simctl_list_devices_available \
    "$BATS_TEST_TMPDIR/bin" \
    "$BATS_TEST_TMPDIR/simctl-devices.txt" \
    "${1:-}"
}

assert_xcrun_command_logged() {
  local expected_command="$1"

  grep -Fx "$expected_command" "$BATS_TEST_TMPDIR/xcrun-commands.log"
}

@test "xrt_sims_list_available prints available simulator name udid and state" {
  setup_default_xcrun_mock

  run xrt_sims_list_available

  assert_success
  assert_line $'iPhone 17\tAAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE\tShutdown'
  assert_line $'iPhone 17 Pro\t11111111-2222-3333-4444-555555555555\tBooted'
}

@test "xrt_sims_find_by_name returns the exact matching simulator row" {
  setup_default_xcrun_mock

  run xrt_sims_find_by_name "iPhone 17 Pro"

  assert_success
  assert_output $'iPhone 17 Pro\t11111111-2222-3333-4444-555555555555\tBooted'
}

@test "xrt_sims_find_by_name fails when no simulator matches the name" {
  setup_default_xcrun_mock

  run xrt_sims_find_by_name "XRT Missing Simulator"

  assert_failure
  assert_output --partial "No available simulator named: XRT Missing Simulator"
}

@test "xrt_sims_wait_until_booted boots shutdown simulator and waits for bootstatus" {
  setup_default_xcrun_mock "$BATS_TEST_TMPDIR/xcrun-commands.log"

  run xrt_sims_wait_until_booted "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"

  assert_success
  assert_xcrun_command_logged "simctl boot AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
  assert_xcrun_command_logged "simctl bootstatus AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE -b"
}
