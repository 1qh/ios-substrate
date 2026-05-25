# Templates

Product-neutral defaults for strict iOS app repositories.

## Files

- `strict-checkmake.ini` — Makefile lint baseline.
- `strict-editorconfig-checker.json` — whitespace and file hygiene baseline.
- `strict-markdownlint.json` — Markdown baseline.
- `strict-swiftformat.config` — SwiftFormat style baseline.
- `strict-swiftlint.yml` — SwiftLint strictness baseline.
- `strict-yamllint.yml` — YAML baseline.

The SwiftLint baseline owns semantic strictness, including test lifecycle,
override/super-call, ownership, optional, force-use, raw-value, and type-safety
rules. The SwiftFormat baseline owns deterministic layout and defers formatter
rules that conflict with SwiftLint-owned semantics.

Consumers copy these files only as app-level configuration. Reusable Swift code stays in package targets.
App names, bundle identifiers, backend hosts, tester lists, and product behavior stay outside these templates.
