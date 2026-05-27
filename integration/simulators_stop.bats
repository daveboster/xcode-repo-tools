#!/usr/bin/env bats

load "../test/helpers/bats_setup"

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
}

@test "xrt_sims_stop is safe for stopped and booted simulator lifecycle" {
  local available
  local stopped_row
  local stopped_udid

  available="$(xrt_sims_list_available)"
  stopped_row="$(printf '%s\n' "$available" | awk -F '\t' '$3 != "Booted" && $1 ~ /^(iPhone|iPad) / { print; exit }')"
  stopped_udid="$(printf '%s\n' "$stopped_row" | awk -F '\t' '{ print $2 }')"

  [[ -n "$stopped_udid" ]]

  run xrt_sims_status "$stopped_udid"

  assert_success
  refute_output "Booted"

  run xrt_sims_stop "$stopped_udid"

  assert_success

  run xrt_sims_status "$stopped_udid"

  assert_success
  refute_output "Booted"

  run xrt_sims_wait_until_booted "$stopped_udid"

  assert_success

  run xrt_sims_status "$stopped_udid"

  assert_success
  assert_output "Booted"

  run xrt_sims_wait_until_booted "$stopped_udid"

  assert_success

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
