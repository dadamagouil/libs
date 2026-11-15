# Contributing

- Everything (code, comments, documentation, commits, issues) is in **English**.
- **One implementation per problem.** When the same problem is solved twice, keep the best of both and say in a
  comment why.
- **Comments explain the why** (a rule, a trap), not the what. Each file starts with what it is for.
- **Small and readable**: one file, one subject; a file above ~400 lines is split.
- **One folder per technology.** A new technology gets a top-level folder with its own README, tests and CI job.
- **No text, no project name, no URL in a package.** Labels are parameters; build values are `--dart-define`s.
- **Logic apart from widgets**: computations go to `app_core` as pure functions.
- **Each rule has a test** whose title says what it checks, with a single scenario.
- **A SQL change is a new file**, with its test in `sql/tests`; applied files are never edited.
- **Documentation in the same commit**: package README and the root README.

## Checks before every push

```bash
tool/check_all.sh
```

The CI also runs actionlint and Gitleaks; never commit a secret, it stays in the history.
