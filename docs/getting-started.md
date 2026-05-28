# Getting started

Use this guide to add `xcode-repo-tools` to an existing Xcode or iOS app repo.

## Check Bats

Make sure Bats is available before adding tests:

```bash
command -v bats || test -x tools/xcode-repo-tools/test/bats/bin/bats
```

If Bats is not available, follow the
[Bats tutorial](https://bats-core.readthedocs.io/en/stable/tutorial.html) or
initialize this repo's submodules after adding `xcode-repo-tools`.

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

## Test a development branch

To try an unreleased `xcode-repo-tools` branch from a consuming app repo, switch
the submodule checkout to that branch:

```bash
XRT_BRANCH="dev/docs-organize-readme"

git -C tools/xcode-repo-tools fetch origin
git -C tools/xcode-repo-tools switch -C "$XRT_BRANCH" "origin/$XRT_BRANCH"
git -C tools/xcode-repo-tools pull --ff-only
```

When you are done testing, reset the submodule checkout back to the main
release branch:

```bash
git -C tools/xcode-repo-tools fetch origin
git -C tools/xcode-repo-tools switch main
git -C tools/xcode-repo-tools pull --ff-only
```

Only commit the changed submodule pointer in the consuming app repo when you
intend to pin that repo to the selected branch commit.

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
mkdir -p test/integration
cp tools/xcode-repo-tools/examples/xrt-example-config.bash test/xrt-example-config.bash
cp tools/xcode-repo-tools/examples/starter-ui-baseline.bats test/integration/ui-baseline.bats
```

Update these values in `test/xrt-example-config.bash` as needed:

- `XRT_TOOLS_DIR`: submodule path, defaults to `tools/xcode-repo-tools`.
- `XRT_BASELINE_SIM_NAME`: reusable baseline simulator name.
- `XRT_UI_TEST_PROJECT`: bundled fixture project used to prime the baseline.
- `XRT_UI_TEST_SCHEME`: bundled fixture UI test scheme.
- `XRT_UI_TEST_ICLOUD_SETUP_SELECTOR`: non-parallel test that primes the baseline.
- `XRT_UI_TEST_SMOKE_SELECTOR`: bundled fixture smoke selector that validates
  baseline reuse.
- `XRT_PROJECT_UI_TEST_PROJECT`: your app's main UI test project.
- `XRT_PROJECT_UI_TEST_SCHEME`: your app's main UI test scheme.
- `XRT_PROJECT_UI_TEST_SMOKE_SELECTOR`: your app's parallel-safe smoke selector.

Run it from the app repo with credentials loaded into the shell:

```bash
TEST_USERNAME="your-test-account@example.com" \
TEST_PASSWORD="your-test-password" \
bats test/integration/ui-baseline.bats
```

## Walkthrough

After the submodule is installed, follow the [walkthrough](walkthrough.md) to
copy starter Bats files into your app repo, create a reusable iPhone baseline
simulator, run UI tests from that baseline, and clean up the image.

See [Testing](testing.md) for local credential and VS Code task setup.
