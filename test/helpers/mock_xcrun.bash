#!/usr/bin/env bash
set -euo pipefail

xrt_mock_xcrun_simctl_list_devices_available() {
  local mock_bin_dir="$1"
  local output_file="$2"

  mkdir -p "$mock_bin_dir"

  cat >"$mock_bin_dir/xcrun" <<EOF
#!/usr/bin/env bash
if [[ "\$*" != "simctl list devices available" ]]; then
  echo "unexpected xcrun args: \$*" >&2
  exit 64
fi

cat "$output_file"
EOF

  chmod +x "$mock_bin_dir/xcrun"
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

  xrt_mock_xcrun_default_devices_file "$output_file"
  xrt_mock_xcrun_simctl_list_devices_available "$mock_bin_dir" "$output_file"
}
