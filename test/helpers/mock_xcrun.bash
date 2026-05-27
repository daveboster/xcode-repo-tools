#!/usr/bin/env bash
set -euo pipefail

xrt_mock_xcrun_simctl_list_devices_available() {
  local mock_bin_dir="$1"
  local output_file="$2"
  local command_log_file="${3:-}"

  mkdir -p "$mock_bin_dir"

  cat >"$mock_bin_dir/xcrun" <<EOF
#!/usr/bin/env bash
command_log_file="$command_log_file"

if [[ -n "\$command_log_file" ]]; then
  printf '%s\n' "\$*" >>"\$command_log_file"
fi

case "\$*" in
  "simctl list devices available")
    cat "$output_file"
    ;;
  simctl\ boot\ *)
    exit 0
    ;;
  simctl\ bootstatus\ *\ -b)
    exit 0
    ;;
  simctl\ shutdown\ *)
    exit 0
    ;;
  *)
    echo "unexpected xcrun args: \$*" >&2
    exit 64
    ;;
esac
EOF

  chmod +x "$mock_bin_dir/xcrun"
}

xrt_mock_xcrun_booted_only_devices_file() {
  local output_file="$1"

  cat >"$output_file" <<'SIMCTL'
== Devices ==
-- iOS 26.0 --
    iPhone 17 Pro (11111111-2222-3333-4444-555555555555) (Booted) 
SIMCTL
}

xrt_mock_xcrun_booted_only_simctl_list_devices_available() {
  local mock_bin_dir="$1"
  local output_file="$2"
  local command_log_file="${3:-}"

  xrt_mock_xcrun_booted_only_devices_file "$output_file"
  xrt_mock_xcrun_simctl_list_devices_available \
    "$mock_bin_dir" \
    "$output_file" \
    "$command_log_file"
}

xrt_mock_xcrun_default_devices_file() {
  local output_file="$1"

  cat >"$output_file" <<'SIMCTL'
== Devices ==
-- iOS 26.0 --
    iPhone 17 (AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE) (Shutdown) 
    iPhone 17 Pro (11111111-2222-3333-4444-555555555555) (Booted) 
    iPad Pro 13-inch (M5) (99999999-8888-7777-6666-555555555555) (Shutdown) 
SIMCTL
}

xrt_mock_xcrun_default_simctl_list_devices_available() {
  local mock_bin_dir="$1"
  local output_file="$2"
  local command_log_file="${3:-}"

  xrt_mock_xcrun_default_devices_file "$output_file"
  xrt_mock_xcrun_simctl_list_devices_available \
    "$mock_bin_dir" \
    "$output_file" \
    "$command_log_file"
}
