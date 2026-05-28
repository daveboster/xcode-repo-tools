# UI baseline walkthrough

This walkthrough starts after an app repo has added `xcode-repo-tools` at
`tools/xcode-repo-tools`.

It copies starter Bats files into the app repo, creates a reusable iPhone
baseline simulator, runs UI tests from that baseline, and then cleans up the
baseline image.

## 1. Add a first pre-PR check

Create the app repo test directory and copy the
[starter pre-PR check](../examples/app-pre-pr.bats):

```bash
mkdir -p test
cp tools/xcode-repo-tools/examples/app-pre-pr.bats test/pre_pr.bats
```

Run it:

```bash
tools/xcode-repo-tools/test/bats/bin/bats test/pre_pr.bats
```

## 2. Copy the baseline setup scenario

Copy the [baseline setup scenario](../examples/ui-baseline-setup.bats) into
the app repo:

```bash
mkdir -p test/integration
cp tools/xcode-repo-tools/examples/ui-baseline-setup.bats test/integration/ui-baseline-setup.bats
```

The setup scenario creates or recreates an iPhone simulator named
`Bats App Baseline iPhone`.

It also includes disabled tests for credential-backed setup:

- A commented-out test that checks `TEST_USERNAME` and `TEST_PASSWORD`.
- A commented-out test that calls `xrt_xcodebuild_run_ui_tests` in `specific`
  mode to prime the baseline image with an app-specific iCloud setup test.

Enable those tests only after setting the app project, scheme, and selector
values.

Run the setup:

```bash
tools/xcode-repo-tools/test/bats/bin/bats test/integration/ui-baseline-setup.bats
```

## 3. Copy the UI test scenario

Copy the [UI test scenario](../examples/ui-tests-from-baseline.bats) into the
app repo:

```bash
cp tools/xcode-repo-tools/examples/ui-tests-from-baseline.bats test/integration/ui-tests-from-baseline.bats
```

Set your app's Xcode project and UI test scheme, then run the scenario:

```bash
XRT_UI_TEST_PROJECT="YourApp.xcodeproj" \
XRT_UI_TEST_SCHEME="YourAppUITests" \
tools/xcode-repo-tools/test/bats/bin/bats test/integration/ui-tests-from-baseline.bats
```

The scenario uses the existing baseline simulator and runs
`UITests/UITestsLaunchTests` in normal mode. Normal mode allows Xcode's
parallel testing behavior to clone and reuse the baseline.

The copied file also includes a disabled test that shows how to call a targeted
test class or method with `xrt_xcodebuild_run_ui_tests`.

## 4. Copy the cleanup scenario

Copy the [cleanup scenario](../examples/ui-baseline-cleanup.bats) into the app
repo:

```bash
cp tools/xcode-repo-tools/examples/ui-baseline-cleanup.bats test/integration/ui-baseline-cleanup.bats
```

Run cleanup when you want to stop and delete the baseline image:

```bash
tools/xcode-repo-tools/test/bats/bin/bats test/integration/ui-baseline-cleanup.bats
```

## Copy all walkthrough files

```bash
mkdir -p test/integration
cp tools/xcode-repo-tools/examples/app-pre-pr.bats test/pre_pr.bats
cp tools/xcode-repo-tools/examples/ui-baseline-setup.bats test/integration/ui-baseline-setup.bats
cp tools/xcode-repo-tools/examples/ui-tests-from-baseline.bats test/integration/ui-tests-from-baseline.bats
cp tools/xcode-repo-tools/examples/ui-baseline-cleanup.bats test/integration/ui-baseline-cleanup.bats
```

## Run setup image

```bash
tools/xcode-repo-tools/test/bats/bin/bats test/integration/ui-baseline-setup.bats
```

## Run UI tests

```bash
XRT_UI_TEST_PROJECT="YourApp.xcodeproj" \
XRT_UI_TEST_SCHEME="YourAppUITests" \
tools/xcode-repo-tools/test/bats/bin/bats test/integration/ui-tests-from-baseline.bats
```

## Clean up

```bash
tools/xcode-repo-tools/test/bats/bin/bats test/integration/ui-baseline-cleanup.bats
```
