#!/usr/bin/env bats

load "../test/helpers/bats_setup"

setup_file() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"

  local available
  local template_row
  local template_name
  local scenario_name

  available="$(xrt_sims_list_available)"
  template_row="$(printf '%s\n' "$available" | awk -F '\t' '$1 ~ /^(iPhone|iPad) / { print; exit }')"
  template_name="$(printf '%s\n' "$template_row" | awk -F '\t' '{ print $1 }')"
  scenario_name="XRT Create Delete ${EPOCHSECONDS:-$(date +%s)}"

  printf '%s\n' "$template_name" >"$BATS_FILE_TMPDIR/template-name"
  printf '%s\n' "$scenario_name" >"$BATS_FILE_TMPDIR/scenario-name"
}

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
}

template_name() {
  cat "$BATS_FILE_TMPDIR/template-name"
}

scenario_name() {
  cat "$BATS_FILE_TMPDIR/scenario-name"
}

created_udid() {
  cat "$BATS_FILE_TMPDIR/created-udid"
}

@test "xrt_sims_create_delete scenario source exists and destination is absent" {
  local template
  local destination
  local existing_destination

  template="$(template_name)"
  destination="$(scenario_name)"

  [[ -n "$template" ]]

  existing_destination="$(
    xrt_sims_list_available |
      awk -F '\t' -v name="$destination" '$1 == name { print; exit }'
  )"

  [[ -z "$existing_destination" ]]
}

@test "xrt_sims_create creates a simulator modeled after an existing simulator" {
  local destination
  local created_row

  run xrt_sims_create "$(scenario_name)" "$(template_name)"

  assert_success

  created_row="$(xrt_sims_find_by_name "$(scenario_name)")"
  printf '%s\n' "$created_row" | awk -F '\t' '{ print $2 }' >"$BATS_FILE_TMPDIR/created-udid"

  [[ -n "$(created_udid)" ]]
}

@test "xrt_sims_create fails when destination already exists" {
  run xrt_sims_create "$(scenario_name)" "$(template_name)"

  assert_failure
  assert_output --partial "Simulator already exists: $(scenario_name)"
}

@test "xrt_sims_create_delete scenario created simulator starts stopped" {
  run xrt_sims_status "$(created_udid)"

  assert_success
  refute_output "Booted"
}

@test "xrt_sims_create_delete scenario boots created simulator" {
  run xrt_sims_wait_until_booted "$(created_udid)"

  assert_success

  run xrt_sims_status "$(created_udid)"

  assert_success
  assert_output "Booted"
}

@test "xrt_sims_delete fails when created simulator is booted" {
  run xrt_sims_delete "$(created_udid)"

  assert_failure
  assert_output --partial "Cannot delete booted simulator: $(created_udid)"
}

@test "xrt_sims_create_delete scenario stops created simulator" {
  run xrt_sims_stop "$(created_udid)"

  assert_success

  run xrt_sims_status "$(created_udid)"

  assert_success
  refute_output "Booted"
}

@test "xrt_sims_delete deletes the created simulator" {
  local existing_destination

  run xrt_sims_delete "$(created_udid)"

  assert_success

  existing_destination="$(
    xrt_sims_list_available |
      awk -F '\t' -v name="$(scenario_name)" '$1 == name { print; exit }'
  )"

  [[ -z "$existing_destination" ]]
}

@test "xrt_sims_delete fails when simulator no longer exists" {
  run xrt_sims_delete "$(created_udid)"

  assert_failure
  assert_output --partial "No available simulator with UDID: $(created_udid)"
}
