#!/usr/bin/env bats

load "../test/helpers/bats_setup"

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
}

@test "xrt_sims_status reports booted for a booted simulator" {
  local available
  local booted_row
  local booted_udid

  available="$(xrt_sims_list_available)"
  booted_row="$(printf '%s\n' "$available" | awk -F '\t' '$3 == "Booted" { print; exit }')"
  booted_udid="$(printf '%s\n' "$booted_row" | awk -F '\t' '{ print $2 }')"

  [[ -n "$booted_udid" ]]

  run xrt_sims_status "$booted_udid"

  assert_success
  assert_output "Booted"
}

@test "xrt_sims_status reports shutdown for a non-booted simulator" {
  local available
  local shutdown_row
  local shutdown_udid

  available="$(xrt_sims_list_available)"
  shutdown_row="$(printf '%s\n' "$available" | awk -F '\t' '$3 == "Shutdown" && $1 ~ /^(iPhone|iPad) / { print; exit }')"
  shutdown_udid="$(printf '%s\n' "$shutdown_row" | awk -F '\t' '{ print $2 }')"

  [[ -n "$shutdown_udid" ]]

  run xrt_sims_status "$shutdown_udid"

  assert_success
  assert_output "Shutdown"
}

@test "xrt_sims_status fails when the simulator cannot be found" {
  local missing_udid="00000000-0000-0000-0000-000000000000"

  run xrt_sims_status "$missing_udid"

  assert_failure
  assert_output --partial "No available simulator with UDID: $missing_udid"
}

@test "xrt_sims_status quiet mode returns no output when the simulator cannot be found" {
  local missing_udid="00000000-0000-0000-0000-000000000000"

  run xrt_sims_status --quiet "$missing_udid"

  assert_success
  assert_output ""
}
