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

@test "xrt_sims_status returns booted state for matching simulator udid" {
  setup_default_xcrun_mock

  run xrt_sims_status "11111111-2222-3333-4444-555555555555"

  assert_success
  assert_output "Booted"
}

@test "xrt_sims_status returns shutdown state for matching simulator udid" {
  setup_default_xcrun_mock

  run xrt_sims_status "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"

  assert_success
  assert_output "Shutdown"
}

@test "xrt_sims_status does not leak broken pipe diagnostics for early match" {
  xrt_sims_list_available() {
    printf '%s\t%s\t%s\n' \
      "iPhone 17" \
      "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE" \
      "Shutdown"
    printf '%s\n' "lib/simulators.sh: line 12: printf: write error: Broken pipe" >&2
    printf '%s\t%s\t%s\n' \
      "iPhone 17 Pro" \
      "11111111-2222-3333-4444-555555555555" \
      "Booted"
  }

  run xrt_sims_status "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"

  assert_success
  assert_output "Shutdown"
}

@test "xrt_sims_status fails when simulator udid is not available" {
  setup_default_xcrun_mock

  run xrt_sims_status "00000000-0000-0000-0000-000000000000"

  assert_failure
  assert_output --partial "No available simulator with UDID: 00000000-0000-0000-0000-000000000000"
}

@test "xrt_sims_status quiet mode succeeds without output when simulator is not available" {
  setup_default_xcrun_mock

  run xrt_sims_status --quiet "00000000-0000-0000-0000-000000000000"

  assert_success
  assert_output ""
}

@test "xrt_sims_wait_until_booted boots shutdown simulator and waits for bootstatus" {
  setup_default_xcrun_mock "$BATS_TEST_TMPDIR/xcrun-commands.log"

  run xrt_sims_wait_until_booted "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"

  assert_success
  assert_xcrun_command_logged "simctl boot AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
  assert_xcrun_command_logged "simctl bootstatus AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE -b"
}

@test "xrt_sims_wait_until_booted succeeds without boot command when simulator is already booted" {
  xrt_mock_xcrun_booted_only_simctl_list_devices_available \
    "$BATS_TEST_TMPDIR/bin" \
    "$BATS_TEST_TMPDIR/simctl-devices.txt" \
    "$BATS_TEST_TMPDIR/xcrun-commands.log"

  run xrt_sims_wait_until_booted "11111111-2222-3333-4444-555555555555"

  assert_success
  ! grep -F "simctl boot 11111111-2222-3333-4444-555555555555" "$BATS_TEST_TMPDIR/xcrun-commands.log"
}

@test "xrt_sims_stop succeeds without shutdown command when simulator is already stopped" {
  setup_default_xcrun_mock "$BATS_TEST_TMPDIR/xcrun-commands.log"

  run xrt_sims_stop "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"

  assert_success
  ! grep -F "simctl shutdown" "$BATS_TEST_TMPDIR/xcrun-commands.log"
}

@test "xrt_sims_stop shuts down booted simulator" {
  xrt_mock_xcrun_booted_only_simctl_list_devices_available \
    "$BATS_TEST_TMPDIR/bin" \
    "$BATS_TEST_TMPDIR/simctl-devices.txt" \
    "$BATS_TEST_TMPDIR/xcrun-commands.log"

  run xrt_sims_stop "11111111-2222-3333-4444-555555555555"

  assert_success
  assert_xcrun_command_logged "simctl shutdown 11111111-2222-3333-4444-555555555555"
}

@test "xrt_sims_stop fails when simulator udid is not available" {
  setup_default_xcrun_mock

  run xrt_sims_stop "00000000-0000-0000-0000-000000000000"

  assert_failure
  assert_output --partial "No available simulator with UDID: 00000000-0000-0000-0000-000000000000"
}

@test "xrt_sims_create creates simulator from template name" {
  setup_default_xcrun_mock "$BATS_TEST_TMPDIR/xcrun-commands.log"

  run xrt_sims_create "XRT Test Simulator" "iPhone 17 Pro"

  assert_success
  assert_output "CCCCCCCC-DDDD-EEEE-FFFF-000000000000"
  assert_xcrun_command_logged "simctl create XRT Test Simulator iPhone 17 Pro"
}

@test "xrt_sims_create fails when destination already exists" {
  setup_default_xcrun_mock

  run xrt_sims_create "iPhone 17 Pro" "iPhone 17"

  assert_failure
  assert_output --partial "Simulator already exists: iPhone 17 Pro"
}

@test "xrt_sims_delete deletes stopped simulator" {
  setup_default_xcrun_mock "$BATS_TEST_TMPDIR/xcrun-commands.log"

  run xrt_sims_delete "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"

  assert_success
  assert_xcrun_command_logged "simctl delete AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
}

@test "xrt_sims_delete fails when simulator is booted" {
  setup_default_xcrun_mock

  run xrt_sims_delete "11111111-2222-3333-4444-555555555555"

  assert_failure
  assert_output --partial "Cannot delete booted simulator: 11111111-2222-3333-4444-555555555555"
}

@test "xrt_sims_delete fails when simulator is not available" {
  setup_default_xcrun_mock

  run xrt_sims_delete "00000000-0000-0000-0000-000000000000"

  assert_failure
  assert_output --partial "No available simulator with UDID: 00000000-0000-0000-0000-000000000000"
}
