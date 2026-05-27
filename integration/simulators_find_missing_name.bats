#!/usr/bin/env bats

load "../test/helpers/bats_setup"

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
}

@test "xrt_sims_find_by_name fails when no available simulator matches the name" {
  local missing_name="XRT Missing Simulator"
  local available
  local existing_row

  available="$(xrt_sims_list_available)"
  existing_row="$(printf '%s\n' "$available" | awk -F '\t' -v name="$missing_name" '$1 == name { print; exit }')"

  [[ -z "$existing_row" ]]

  run xrt_sims_find_by_name "$missing_name"

  assert_failure
  assert_output --partial "No available simulator named: XRT Missing Simulator"
}
