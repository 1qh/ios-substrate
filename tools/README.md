# Tools

Product-neutral command line helpers for iOS app repositories. The daily command is `iosx`.

The public contract is the `iosx` command. Current gate runner
internals use Python only as local developer tooling, and the substrate gates
compile and lint those scripts before consumer repos inherit them. Consumer app
runtimes stay Swift/native and do not depend on Python.

## Install

Install the single command into PATH for local development:

```sh
tools/install-local
iosx doctor
```

Consumer repos should depend on `iosx`, not a checkout-relative tool path.

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

## `lint/no-direct-ios-helper`

Fails consumer Makefiles that reimplement product-neutral iOS helper snippets
already owned by this substrate: simulator boot/install/launch/reset/push,
ad-hoc simulator app signing, physical-device install/launch/discovery, LAN URL
discovery, and generic ExportOptions plist writing.

```sh
tools/lint/no-direct-ios-helper Makefile tools/make
tools/lint/no-direct-ios-helper --selftest
```

## `lint/no-direct-bundle-config`

Fails direct Swift `Bundle.main` Info.plist reads. Consumers should expose an
app-local config facade backed by `InfoDictionaryConfig` instead, so placeholder
and empty-value semantics stay shared.

```sh
tools/lint/no-direct-bundle-config Sources
tools/lint/no-direct-bundle-config --selftest
```

## `iosx device`

Owns local device, simulator, LAN URL, and signing identity discovery.

Consumers provide project-specific values through arguments or environment variables. The script never stores app names, bundle identifiers, tester lists, or backend hosts.

```sh
iosx device simulator-udid --name "iPhone 17 Pro Max"
iosx device physical-device-udid
iosx device install-launch --app /tmp/App.app --bundle-id dev.example.app
iosx device team-id --team-name "Developer Name"
iosx device lan-url --port 5174
```

## `iosx sim`

Owns product-neutral simulator operations that otherwise tend to be copied into
every app Makefile.

```sh
iosx sim boot-wait --name "iPhone 17 Pro Max" --open
iosx sim install --app /tmp/App.app --codesign retry
iosx sim install-launch --app /tmp/App.app --bundle-id dev.example.app --codesign retry
iosx sim terminate --bundle-id dev.example.app
iosx sim uninstall --bundle-id dev.example.app
iosx sim shutdown --device "iPhone 17 Pro Max"
iosx sim keychain-reset
iosx sim push --bundle-id dev.example.app --payload fixtures/push.apns
iosx sim nuke-all
```

## `iosx xcode`

Owns generic Xcode helper artifacts that should not be handwritten inside
consumer Makefiles.

```sh
iosx xcode export-options \
  --team-id ABCDE12345 \
  --output /tmp/ExportOptions.plist \
  --signing-style automatic \
  --signing-certificate "Apple Distribution"
```

## `iosx path`

Prints installed substrate paths for tools that require a file path.

```sh
iosx path root
iosx path swiftlint-config
iosx path swiftformat-config
```
