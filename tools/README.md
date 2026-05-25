# Tools

Product-neutral command line helpers for iOS app repositories.

The public contract is the extensionless command path. Current gate runner
internals use Python only as local developer tooling, and the substrate gates
compile and lint those scripts before consumer repos inherit them. Consumer app
runtimes stay Swift/native and do not depend on Python.

## `lint/run-all`

Runs the fast generic quality gates for this package:

- Swift package tests.
- shellcheck and shfmt for shell scripts.
- SwiftLint strict, SwiftFormat lint, and shared launch-config access checks for Swift roots.
- false-green shell verification checks for scripts and Makefiles.
- Python syntax/Ruff checks, editorconfig, typos, YAML, TOML, JSON, markdown, and offline markdown link checks.
- product-neutrality scan for terms that belong in consumer apps.

Selectors are available for fast local iteration:

```sh
tools/lint/run-all --list-gates
tools/lint/run-all --only swiftlint
tools/lint/run-all --from editorconfig
tools/lint/run-all --after swiftformat
```

Final proof uses `tools/lint/run-all` without selectors.

## `lint/run-dead-code`

Runs the dedicated dead-code gate with Periphery. This is explicit and on-demand, not part of fast `run-all`.

## `lint/run-swift-gates`

Runs the reusable Swift lint bundle: SwiftLint strict, SwiftFormat lint, and
`no-direct-bundle-config` over the same roots. Consumers may pass a local
SwiftLint overlay when product rules are required; the overlay should inherit
`templates/strict-swiftlint.yml` with `parent_config`. Consumers should use the
substrate SwiftFormat config unless a product-only formatting rule is required.

```sh
tools/lint/run-swift-gates Sources Tests
tools/lint/run-swift-gates --swiftlint-config .swiftlint.yml App
```

## `lint/no-false-green-verify`

Fails scripts that read `$?` after a pipeline without `set -o pipefail` or
`PIPESTATUS`. This keeps build, lint, and release verification from passing on
formatter/log-tail exit codes.

```sh
tools/lint/no-false-green-verify tools Makefile
tools/lint/no-false-green-verify --selftest
```

## `lint/no-direct-bundle-config`

Fails direct Swift `Bundle.main` Info.plist reads. Consumers should expose an
app-local config facade backed by `InfoDictionaryConfig` instead, so placeholder
and empty-value semantics stay shared.

```sh
tools/lint/no-direct-bundle-config Sources
tools/lint/no-direct-bundle-config --selftest
```

## `ios-device`

Owns local device, simulator, LAN URL, and signing identity discovery.

Consumers provide project-specific values through arguments or environment variables. The script never stores app names, bundle identifiers, tester lists, or backend hosts.

```sh
tools/ios-device simulator-udid --name "iPhone 17 Pro Max"
tools/ios-device physical-device-udid
tools/ios-device team-id --team-name "Developer Name"
tools/ios-device lan-url --port 5174
```
