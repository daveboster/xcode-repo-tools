#!/usr/bin/env bats

load "../test/helpers/bats_setup"

setup_file() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
  source "$BATS_TEST_DIRNAME/../lib/xcodebuild.sh"

  local repo_root
  local scenario_name
  local existing_row
  local existing_udid
  local existing_state
  local template_row
  local template_name
  local created_row

  repo_root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  scenario_name="Bats App Baseline iPhone"

  if [[ -z "${TEST_USERNAME:-}" || -z "${TEST_PASSWORD:-}" ]]; then
    printf 'TEST_USERNAME and TEST_PASSWORD must be set before running UI tests.\n' >&2
    return 1
  fi

  if existing_row="$(xrt_sims_find_by_name "$scenario_name" 2>/dev/null)"; then
    existing_udid="$(printf '%s\n' "$existing_row" | awk -F '\t' '{ print $2 }')"
    printf '%s\n' "$scenario_name" >"$BATS_FILE_TMPDIR/scenario-name"
    printf '%s\n' "$existing_udid" >"$BATS_FILE_TMPDIR/simulator-udid"
    printf '%s\n' "existing" >"$BATS_FILE_TMPDIR/simulator-origin"
    return 0
  fi

  template_row="$(xrt_sims_list_available | awk -F '\t' '$1 ~ /^iPhone / && !found { print; found = 1 }')"
  template_name="$(printf '%s\n' "$template_row" | awk -F '\t' '{ print $1 }')"

  [[ -n "$template_name" ]]

  xrt_sims_create "$scenario_name" "$template_name"

  created_row="$(xrt_sims_find_by_name "$scenario_name")"

  printf '%s\n' "$scenario_name" >"$BATS_FILE_TMPDIR/scenario-name"
  printf '%s\n' "$template_name" >"$BATS_FILE_TMPDIR/template-name"
  printf '%s\n' "$created_row" | awk -F '\t' '{ print $2 }' >"$BATS_FILE_TMPDIR/simulator-udid"
  printf '%s\n' "created" >"$BATS_FILE_TMPDIR/simulator-origin"
}

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
  source "$BATS_TEST_DIRNAME/../lib/xcodebuild.sh"
}

teardown_file() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"

  if [[ ! -f "$BATS_FILE_TMPDIR/simulator-udid" ]]; then
    return 0
  fi

  local simulator_udid
  simulator_udid="$(cat "$BATS_FILE_TMPDIR/simulator-udid")"

  if xrt_sims_status --quiet "$simulator_udid" >/dev/null; then
    xrt_sims_stop "$simulator_udid" >/dev/null 2>&1 || true
  fi
}

scenario_name() {
  cat "$BATS_FILE_TMPDIR/scenario-name"
}

simulator_udid() {
  cat "$BATS_FILE_TMPDIR/simulator-udid"
}

simulator_origin() {
  cat "$BATS_FILE_TMPDIR/simulator-origin"
}

write_swift_credentials() {
  local credentials_swift="$BATS_TEST_DIRNAME/../src/UITests/UITests/UITestCredentials.swift"

  cat >"$credentials_swift" <<EOF
import Foundation

enum UITestCredentials {
   static let username = "$TEST_USERNAME"
   static let password = "$TEST_PASSWORD"
}
EOF
}

@test "xcodebuild UI test scenario has credentials" {
  [[ -n "${TEST_USERNAME:-}" ]]
  [[ -n "${TEST_PASSWORD:-}" ]]
}

@test "xcodebuild UI test scenario simulator exists" {
  run xrt_sims_find_by_name "$(scenario_name)"

  assert_success
  assert_output --partial "$(scenario_name)"
}

@test "xcodebuild UI test scenario starts simulator" {
  run xrt_sims_wait_until_booted "$(simulator_udid)"

  assert_success
}

@test "xcodebuild UI test scenario simulator is booted" {
  run xrt_sims_status "$(simulator_udid)"

  assert_success
  assert_output "Booted"
}

@test "xcodebuild UI test scenario primes Apple ID on baseline simulator" {
  if [[ "$(simulator_origin)" == "existing" ]]; then
    skip "Baseline simulator already exists; launch test validation covers reuse."
  fi

  write_swift_credentials

  run xrt_xcodebuild_run_ui_tests \
    "src/UITests/UITests.xcodeproj" \
    "UITests" \
    "$(simulator_udid)" \
    "UITests/UITests/test_Login_With_Apple_Id" \
    "specific"

  assert_success
}

@test "xcodebuild UI test scenario runs launch tests in parallel mode" {
  run xrt_xcodebuild_run_ui_tests \
    "src/UITests/UITests.xcodeproj" \
    "UITests" \
    "$(simulator_udid)" \
    "UITests/UITestsLaunchTests" \
    "normal"

  assert_success
}
