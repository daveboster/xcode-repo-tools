#!/usr/bin/env bash
set -euo pipefail

# TODO: Add simulator helpers test-first with Bats.

xrt_sims_list_available() {
  local line
  local device_line_pattern='^[[:space:]]+(.+) \(([0-9A-Fa-f-]{36})\) \(([^)]*)\)[[:space:]]*$'

  xcrun simctl list devices available | while IFS= read -r line; do
    if [[ "$line" =~ $device_line_pattern ]]; then
      printf '%s\t%s\t%s\n' \
        "${BASH_REMATCH[1]}" \
        "${BASH_REMATCH[2]}" \
        "${BASH_REMATCH[3]}"
    fi
  done
}

xrt_sims_find_by_name() {
  local simulator_name="$1"
  local simulator_row

  simulator_row="$(xrt_sims_list_available | awk -F '\t' -v name="$simulator_name" '$1 == name')"

  if [[ -z "$simulator_row" ]]; then
    echo "No available simulator named: $simulator_name" >&2
    return 1
  fi

  printf '%s\n' "$simulator_row"
}

xrt_sims_wait_until_booted() {
  local simulator_udid="$1"

  xcrun simctl boot "$simulator_udid"
  xcrun simctl bootstatus "$simulator_udid" -b
}
