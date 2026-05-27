#!/usr/bin/env bats

load "../test/helpers/bats_setup"

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
}

@test "xrt_sims_list_available returns at least one iPhone and iPad simulator" {
  run xrt_sims_list_available

  assert_success
  assert_output --partial "iPhone"
  assert_output --partial "iPad"
}
