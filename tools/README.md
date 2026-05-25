# Tools

Product-neutral command line helpers for iOS app repositories.

## `lint/run-all.py`

Runs the fast generic quality gates for this package:

- Swift package tests.
- shellcheck and shfmt for shell scripts.
- SwiftLint strict, SwiftFormat lint, and shared launch-config access checks for Swift roots.
- editorconfig, typos, YAML, TOML, JSON, markdown, and offline markdown link checks.
- product-neutrality scan for terms that belong in consumer apps.

Selectors are available for fast local iteration:

```sh
tools/lint/run-all.py --list-gates
tools/lint/run-all.py --only swiftlint
tools/lint/run-all.py --from editorconfig
tools/lint/run-all.py --after swiftformat
```

Final proof uses `tools/lint/run-all.py` without selectors.

## `lint/run-dead-code`

Runs the dedicated dead-code gate with Periphery. This is explicit and on-demand, not part of fast `run-all.py`.

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
