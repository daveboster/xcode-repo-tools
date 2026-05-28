# Contributing

Pull requests, bug reports, and other contributions are welcome.

This guide sets clear expectations so contributors and maintainers can improve
the project together with focused issues, small pull requests, useful tests, and
readable documentation.

## Contents

- [Contributing](#contributing)
  - [Contents](#contents)
  - [Conduct](#conduct)
  - [Asking questions](#asking-questions)
  - [Opening issues](#opening-issues)
  - [Feature requests](#feature-requests)
  - [Submitting pull requests](#submitting-pull-requests)
  - [Writing commit messages](#writing-commit-messages)
  - [Code review](#code-review)
  - [Coding style](#coding-style)
  - [Credits](#credits)

## Conduct

This project's code of conduct is to read and apply The Programmer's Oath by
Robert C. Martin. I also recommend the updated Clean Coders episode on the same
topic.

In practical terms, contributors should:

1. Avoid harmful and lazy code.
2. Do your best work and avoid knowingly let defects accumulate.
3. Provide a quick, repeatable proof that released behavior works.
4. Make small releases that do not block others' work.
5. Improve existing work without degrading it.
6. Protect the productivity of yourself and others.
7. Keep work understandable enough so that others can cover it.
8. Make honest statements, share only from actual experience, and avoid promises without certainty.
9. Keep learning and improving the craft.

These points come from Robert C. Martin's November 2015 post,
[The Programmer's Oath](https://blog.cleancoder.com/uncle-bob/2015/11/18/TheProgrammersOath.html).
I'd encourage everyone to read his original article and watch his more recent video,
[Clean Code Episode 45: The Programmer's Oath](https://cleancoders.com/episode/clean-code-episode-45).

## Asking questions

Use GitHub issues for bugs, feature requests, and project-level discussion.
Questions about how to debug a private app repo are usually better handled in
that app repo, not here.

## Opening issues

Before opening an issue:

- Search existing issues for duplicates.
- Check that you are using the latest version of the repo or submodule.
- Include the command you ran, the output you saw, and what you expected.
- Include the macOS, Xcode, and simulator versions when relevant.
- Use fenced code blocks for shell commands, logs, and stack traces.

Do not file public issues for secrets or private credentials. Remove account
names, passwords, tokens, device identifiers, and app-private data before
sharing logs.

## Feature requests

Feature requests are welcome. Keep requests focused on reusable Xcode or iOS
repo automation.

Before requesting a feature:

- Search for an existing request.
- Describe the consuming-repo workflow that needs the helper.
- Explain why the behavior belongs in this reusable repo instead of one app
  repo.
- Include a proposed integration scenario when possible.

## Submitting pull requests

Smaller pull requests are easier to review and merge. Submit one bug fix,
helper behavior, or documentation cleanup at a time.

Before opening a pull request:

```bash
git submodule update --init --recursive
test/bats/bin/bats test
bash -n lib/*.sh test/helpers/*.bash test/*.bats integration/*.bats checks/*.bats bin/*
test/bats/bin/bats checks/pre_pr.bats
```

Run integration scenarios locally when your change affects real simulator or
Xcode behavior:

```bash
test/bats/bin/bats integration
```

### Test a branch from a consuming app repo

When a pull request needs validation from another app repo, switch that app
repo's `xcode-repo-tools` submodule to the development branch:

```bash
XRT_BRANCH="dev/docs-organize-readme"

git -C tools/xcode-repo-tools fetch origin
git -C tools/xcode-repo-tools switch -C "$XRT_BRANCH" "origin/$XRT_BRANCH"
git -C tools/xcode-repo-tools pull --ff-only
```

Run the consuming repo checks that exercise the change. When testing is done,
reset the submodule checkout back to the main release branch:

```bash
git -C tools/xcode-repo-tools fetch origin
git -C tools/xcode-repo-tools switch main
git -C tools/xcode-repo-tools pull --ff-only
```

Do not commit the changed submodule pointer in the consuming app repo unless
that repo should intentionally pin to the tested branch commit.

Pull request expectations:

- Link the relevant issue when one exists.
- Keep unrelated refactors out of behavior changes.
- Add or update tests for helper behavior.
- Update docs when usage, setup, or workflow expectations change.
- Address CI failures with follow-up commits.

## Writing commit messages

Use the project convention from
[Release and commit conventions](docs/release-and-commits.md):

```text
<type>(<optional-scope>): <subject>
```

Allowed types are `feat`, `fix`, `docs`, `test`, `refactor`, `ci`, and `chore`.
Keep the first line short enough for release tooling and review summaries.

Use the body to explain why the change exists when the subject is not enough.
Wrap body text at about 72 characters.

## Code review

Review the code, tests, and documentation, not the author. Good review feedback
is specific, actionable, and explains the reason for the request.

When receiving review feedback:

- Ask clarifying questions when the requested change is ambiguous.
- Prefer small follow-up commits.
- Keep the conversation focused on the behavior and maintainability of the
  change.

## Coding style

Follow the style of the file you are editing.

For Bash helpers:

- Use `set -euo pipefail` in executable Bash files.
- Keep helper behavior in `lib/` and wrapper behavior in `bin/`.
- Keep commands mockable from Bats tests.
- Prefer focused functions over large scripts with hidden global state.

For documentation:

- Start with the user's goal.
- Put the most important information first.
- Use short sections, meaningful headings, and scannable lists.
- Move detailed reference material out of the root README and into `docs/`.

## Credits

This guide is based on and adapted from
[jessesquires/.github CONTRIBUTING.md](https://github.com/jessesquires/.github/blob/main/CONTRIBUTING.md).

Documentation structure follows GitHub's guidance to write for user needs, use
plain language, keep pages scannable, and move details behind clear headings:
[Best practices for GitHub Docs](https://docs.github.com/en/contributing/writing-for-github-docs/best-practices-for-github-docs).
