#!/usr/bin/env bats

load "../test/helpers/bats_setup"

setup_file() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"

  local template_row
  local template_name
  local scenario_name
  local created_row

  template_row="$(xrt_sims_list_available | awk -F '\t' '$1 ~ /^iPhone / && !found { print; found = 1 }')"
  template_name="$(printf '%s\n' "$template_row" | awk -F '\t' '{ print $1 }')"
  scenario_name="XRT Status ${EPOCHSECONDS:-$(date +%s)}"

  [[ -n "$template_name" ]]

  xrt_sims_create "$scenario_name" "$template_name" >/dev/null
  created_row="$(xrt_sims_find_by_name "$scenario_name")"

  printf '%s\n' "$scenario_name" >"$BATS_FILE_TMPDIR/status-scenario-name"
  printf '%s\n' "$created_row" | awk -F '\t' '{ print $2 }' >"$BATS_FILE_TMPDIR/status-simulator-udid"
}

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
}

teardown_file() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"

  if [[ ! -f "$BATS_FILE_TMPDIR/status-simulator-udid" ]]; then
    return 0
  fi

  local simulator_udid
  simulator_udid="$(cat "$BATS_FILE_TMPDIR/status-simulator-udid")"

  if xrt_sims_status --quiet "$simulator_udid" >/dev/null; then
    xrt_sims_stop "$simulator_udid" >/dev/null 2>&1 || true
    xrt_sims_delete "$simulator_udid" >/dev/null 2>&1 || true
  fi
}

status_simulator_udid() {
  cat "$BATS_FILE_TMPDIR/status-simulator-udid"
}

@test "xrt_sims_status reports booted for a booted simulator" {
  local booted_udid

  booted_udid="$(status_simulator_udid)"

  [[ -n "$booted_udid" ]]

  run xrt_sims_wait_until_booted "$booted_udid"

  assert_success

  run xrt_sims_status "$booted_udid"

  assert_success
  assert_output "Booted"
}

@test "xrt_sims_status reports shutdown for a non-booted simulator" {
  local shutdown_udid

  shutdown_udid="$(status_simulator_udid)"

  [[ -n "$shutdown_udid" ]]

  run xrt_sims_stop "$shutdown_udid"

  assert_success

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
