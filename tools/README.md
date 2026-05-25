# Tools

Product-neutral command line helpers for iOS app repositories. The daily command is `iosx`.

The public contract is the `iosx` command. It is optimized for coding agents:
commands are deterministic, failures name the missing tool or contract, and
discovery commands support JSON where agents need stable parsing. Current gate
runner internals use Python only as local developer tooling, and the substrate
gates compile and lint those scripts before consumer repos inherit them.
Consumer app runtimes stay Swift/native and do not depend on Python.
`iosx doctor --fast` fails when a fast-loop helper, strict config file, or
external gate binary is missing. `iosx doctor --all` also checks dedicated
on-demand dead-code tooling.

## Install

Install the single command into PATH for agent-operated sessions:

```sh
tools/install-local
iosx doctor
iosx doctor --fast
```

Consumer repos should depend on `iosx`, not a checkout-relative tool path.

## Agent contract

Future coding-agent sessions should learn and use one command:

```sh
iosx commands --json
iosx doctor --fast --json
iosx doctor --all --json
iosx version --json
iosx path --json swiftlint-config
iosx path --json markdownlint-config
iosx path --json typos-config
```

Do not call substrate helper files directly from consumer repos. If a generic
operation is missing from `iosx`, add it to `iosx` first, dogfood it here, then
consume the command from app repositories.

## `lint/run-all`

Runs the fast generic quality gates for this package:

- `iosx doctor --fast` public fast-loop contract verification.
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

Full tooling proof also runs `iosx doctor --all`; it is separate from the fast
gate because dead-code scanning remains dedicated and on-demand.

## `lint/run-dead-code`

Runs the dedicated dead-code gate with Periphery. This is explicit and on-demand, not part of fast `run-all`.

## `lint/run-swift-gates`

Runs the reusable Swift lint bundle: SwiftLint strict, SwiftFormat lint, and
`no-direct-bundle-config` over the same roots. Consumers may pass a local
SwiftLint overlay when product rules are required. The overlay contains
product-only rules; `iosx` composes it over the substrate strict floor at
runtime. Consumers should use the substrate SwiftFormat config unless a
product-only formatting rule is required.

```sh
iosx lint swift-gates Sources Tests
iosx lint swift-gates --swiftlint-overlay .swiftlint.yml App
```

## `lint/no-false-green-verify`

Fails scripts that read `$?` after a pipeline without `set -o pipefail` or
`PIPESTATUS`. This keeps build, lint, and release verification from passing on
formatter/log-tail exit codes.

```sh
iosx lint false-green tools Makefile
iosx lint false-green --selftest
```

## `lint/no-direct-ios-helper`

Fails consumer Makefiles that reimplement product-neutral iOS helper snippets
already owned by this substrate: simulator create/boot/list/install/launch/reset/push,
simulator privacy/location/UI/log/app-container helpers, ad-hoc simulator app
signing, physical-device install/launch/discovery/app inspection, LAN URL
discovery, and generic ExportOptions plist writing.

```sh
iosx lint no-direct-ios-helper Makefile tools/make
iosx lint no-direct-ios-helper --selftest
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
iosx device list-devices --json-output /tmp/devices.json
iosx device app-info --device <core-device-udid> --bundle-id dev.example.app --json-output /tmp/apps.json
iosx device install-launch --app /tmp/App.app --bundle-id dev.example.app
iosx device team-id --team-name "Developer Name"
iosx device lan-url --port 5174
```

## `iosx sim`

Owns product-neutral simulator operations that otherwise tend to be copied into
every app Makefile.

```sh
iosx sim create-if-needed --name "iPhone 17 Pro Max" --device-type com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max
iosx sim boot-wait --name "iPhone 17 Pro Max" --open
iosx sim booted-udid --name "iPhone 17 Pro Max"
iosx sim list-devices --booted
iosx sim install --app /tmp/App.app --codesign retry
iosx sim install-launch --app /tmp/App.app --bundle-id dev.example.app --codesign retry
iosx sim launch --bundle-id dev.example.app --env DEBUG_CAPTURE=1
iosx sim terminate --bundle-id dev.example.app
iosx sim uninstall --bundle-id dev.example.app
iosx sim privacy --service camera --bundle-id dev.example.app
iosx sim location --latlng 21.0285,105.8542
iosx sim ui --appearance dark
iosx sim log-show --predicate 'subsystem == "dev.example.app"' --last 60s --info
iosx sim log-stream --predicate 'subsystem == "dev.example.app"' --level info
iosx sim app-container --bundle-id dev.example.app --type app
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
iosx path checkmake-config
iosx path editorconfig-checker-config
iosx path markdownlint-config
iosx path ruff-config
iosx path swiftlint-config
iosx path swiftformat-config
iosx path typos-config
iosx path yamllint-config
```
