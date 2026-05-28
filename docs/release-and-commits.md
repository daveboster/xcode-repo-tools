# Release and commit conventions

Commit messages should use a concise semantic format so release notes can be
generated from git history.

## Commit message format

Use this first-line format:

```text
<type>(<optional-scope>): <subject>
```

The scope is optional. Keep the subject short, clear, present tense, and useful
as source material for a release-note bullet.

Examples:

```text
fix: avoid simulator status pipe leak
feat(simulators): add baseline clone helper
docs(readme): clarify submodule setup
```

Use the commit type to control release-note behavior:

- `feat:` for new user-visible helper behavior.
- `fix:` for user-visible bug fixes and reliability improvements.
- `docs:`, `test:`, `refactor:`, `ci:`, and `chore:` for internal changes that
  should usually be excluded from user-facing release notes.

Choose the narrowest type that explains why the commit matters:

- `docs:` for README, examples, and process documentation.
- `test:` for adding or refactoring tests without changing helper behavior.
- `refactor:` for code cleanup that preserves behavior.
- `ci:` for GitHub Actions, checks, and automation configuration.
- `chore:` for maintenance that is not production helper behavior.

This convention is based on the concise semantic commit format described in
[joshbuchea/semantic-commit-messages.md](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716).

## Release notes

Release notes should be short bullet points written for users, not an
implementation changelog.

Good examples:

```text
- Improved reliability of simulator status checks.
- Added reusable UI test baseline helpers.
```

Avoid implementation details unless the user needs to know them.

## GitHub ruleset setup

Use a GitHub repository ruleset to keep commit history compatible with this
release-note workflow. GitHub documents repository rulesets and commit metadata
regex restrictions in
[Creating rulesets for a repository](https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository).

The repository is configured with a GitHub ruleset plus the required
`Pre-PR Checks` workflow. Native GitHub branch rules enforce the protected
branch and required-check behavior; the required workflow enforces the commit
message convention for the commits in a pull request.

- [x] Target `main`.
- [x] Require pull requests before merging.
- [x] Require the `Pre-PR Checks` workflow to pass.
- [x] Require commit messages to match the Conventional Commit prefix:
      `^(feat|fix|docs|test|refactor|ci|chore)(\([a-z0-9._-]+\))?!?: .{1,72}$`
- [x] Require the first commit-message line to stay short enough for release
      tooling and review summaries.
- [x] Prefer squash or rebase merges so the merged commit message is the
      release-note source.
- [x] Use `feat:` and `fix:` for release-note-worthy changes; use the internal
      types for documentation, tests, refactors, and CI-only work.
