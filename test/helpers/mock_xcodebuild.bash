#!/usr/bin/env bash
set -euo pipefail

xrt_mock_xcodebuild() {
  local mock_bin_dir="$1"
  local command_log_file="$2"

  mkdir -p "$mock_bin_dir"

  cat >"$mock_bin_dir/xcodebuild" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >>"$command_log_file"
EOF

  chmod +x "$mock_bin_dir/xcodebuild"
}
