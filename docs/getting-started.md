# Getting started

Use this guide to add `xcode-repo-tools` to an existing Xcode or iOS app repo.

## Add the submodule

```bash
git submodule add https://github.com/daveboster/xcode-repo-tools.git tools/xcode-repo-tools
git submodule update --init --recursive
```

For local development before a remote is available, use a local path instead of
the GitHub URL:

```bash
git submodule add ../xcode-repo-tools tools/xcode-repo-tools
git submodule update --init --recursive
```

## Load helpers from Bats

Use the shared Bats setup helper from app repo tests:

```bash
load "tools/xcode-repo-tools/test/helpers/bats_setup"

setup() {
  source "tools/xcode-repo-tools/lib/simulators.sh"
  source "tools/xcode-repo-tools/lib/xcodebuild.sh"
}
```

Then write app-specific Bats files that read like pre-PR checks while delegating
common simulator and `xcodebuild` behavior to this repo.

## Start from the UI baseline example

Copy the starter scenario into your app repo:

```bash
cp tools/xcode-repo-tools/examples/starter-ui-baseline.bats integration/ui-baseline.bats
```

Update these values in the copied file:

- `XRT_TOOLS_DIR`: submodule path, defaults to `tools/xcode-repo-tools`.
- `XRT_BASELINE_SIM_NAME`: reusable baseline simulator name.
- `XRT_UI_TEST_PROJECT`: app Xcode project path.
- `XRT_UI_TEST_SCHEME`: app UI test scheme.
- `XRT_UI_TEST_LOGIN_SELECTOR`: non-parallel test that primes the baseline.
- `XRT_UI_TEST_SMOKE_SELECTOR`: parallel-safe test selector that validates
  baseline reuse.

Run it from the app repo with credentials loaded into the shell:

```bash
TEST_USERNAME="your-test-account@example.com" \
TEST_PASSWORD="your-test-password" \
bats integration/ui-baseline.bats
```

See [Testing](testing.md) for local credential and VS Code task setup.
