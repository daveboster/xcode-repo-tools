#!/usr/bin/env bats

load "../test/helpers/bats_setup"

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
}

@test "xrt_sims_find_by_name returns an available simulator by exact name" {
  local available
  local iphone_row
  local iphone_name

  available="$(xrt_sims_list_available)"
  iphone_row="$(printf '%s\n' "$available" | awk -F '\t' '$1 ~ /^iPhone / { print; exit }')"
  iphone_name="$(printf '%s\n' "$iphone_row" | awk -F '\t' '{ print $1 }')"

  [[ -n "$iphone_name" ]]

  run xrt_sims_find_by_name "$iphone_name"

  assert_success
  assert_line "$iphone_row"
}
