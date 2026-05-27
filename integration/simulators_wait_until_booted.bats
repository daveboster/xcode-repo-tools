#!/usr/bin/env bats

load "../test/helpers/bats_setup"

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
}

@test "xrt_sims_wait_until_booted succeeds after a simulator is booted" {
  local available_before
  local available_after
  local bootable_row
  local bootable_udid
  local booted_after_row

  available_before="$(xrt_sims_list_available)"
  bootable_row="$(
    printf '%s\n' "$available_before" |
      awk -F '\t' '$3 != "Booted" && $1 ~ /^(iPhone|iPad) / { print; exit }'
  )"
  bootable_udid="$(printf '%s\n' "$bootable_row" | awk -F '\t' '{ print $2 }')"

  [[ -n "$bootable_udid" ]]

  run xrt_sims_wait_until_booted "$bootable_udid"

  assert_success

  available_after="$(xrt_sims_list_available)"
  booted_after_row="$(
    printf '%s\n' "$available_after" |
      awk -F '\t' -v udid="$bootable_udid" '$2 == udid && $3 == "Booted" { print; exit }'
  )"

  [[ -n "$booted_after_row" ]]
}
