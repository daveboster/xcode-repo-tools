#!/usr/bin/env bats

load "../test/helpers/bats_setup"

setup_file() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"

  local available
  local stopped_row
  local stopped_udid

  available="$(xrt_sims_list_available)"
  stopped_row="$(printf '%s\n' "$available" | awk -F '\t' '$3 != "Booted" && $1 ~ /^(iPhone|iPad) / { print; exit }')"
  stopped_udid="$(printf '%s\n' "$stopped_row" | awk -F '\t' '{ print $2 }')"

  printf '%s\n' "$stopped_udid" >"$BATS_FILE_TMPDIR/stop-simulator-udid"
}

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
}

stop_simulator_udid() {
  cat "$BATS_FILE_TMPDIR/stop-simulator-udid"
}

@test "xrt_sims_stop test simulator exists" {
  local stopped_udid

  stopped_udid="$(stop_simulator_udid)"
  [[ -n "$stopped_udid" ]]
}

@test "xrt_sims_stop succeeds when simulator is already stopped" {
  local stopped_udid

  stopped_udid="$(stop_simulator_udid)"

  run xrt_sims_status "$stopped_udid"

  assert_success
  refute_output "Booted"

  run xrt_sims_stop "$stopped_udid"

  assert_success

  run xrt_sims_status "$stopped_udid"

  assert_success
  refute_output "Booted"
}

@test "xrt_sims_stop test simulator can be started" {
  local stopped_udid

  stopped_udid="$(stop_simulator_udid)"

  run xrt_sims_status "$stopped_udid"

  assert_success
  refute_output "Booted"

  run xrt_sims_wait_until_booted "$stopped_udid"

  assert_success

  run xrt_sims_status "$stopped_udid"

  assert_success
  assert_output "Booted"
}

@test "xrt_sims_stop leaves already started simulator running when started again" {
  local stopped_udid

  stopped_udid="$(stop_simulator_udid)"

  run xrt_sims_status "$stopped_udid"

  assert_success
  assert_output "Booted"

  run xrt_sims_wait_until_booted "$stopped_udid"

  assert_success

  run xrt_sims_status "$stopped_udid"

  assert_success
  assert_output "Booted"
}

@test "xrt_sims_stop stops a started simulator" {
  local stopped_udid

  stopped_udid="$(stop_simulator_udid)"

  run xrt_sims_status "$stopped_udid"

  assert_success
  assert_output "Booted"

  run xrt_sims_stop "$stopped_udid"

  assert_success

  run xrt_sims_status "$stopped_udid"

  assert_success
  refute_output "Booted"
}

@test "xrt_sims_stop fails when the simulator cannot be found" {
  local missing_udid="00000000-0000-0000-0000-000000000000"

  run xrt_sims_stop "$missing_udid"

  assert_failure
  assert_output --partial "No available simulator with UDID: $missing_udid"
}
