# iOS substrate

Reusable SwiftUI app substrate. Docs live in `ios-substrate-docs`.

## Current baseline

- Swift package floor: iOS 18 and macOS 26.
- Code primitives: app identity, Info.plist config parsing, backend origin validation, release channel config, telemetry toggles, and debug backend override storage.
- Tooling primitives: strict SwiftFormat, SwiftLint, launch-config access, false-green verification, editorconfig, markdown, YAML, JSON, shell, typo, package-test, and product-neutrality gates.

## Gates

```sh
tools/lint/run-all.py
tools/lint/run-all.py --list-gates
tools/lint/run-all.py --from swiftlint
tools/lint/run-dead-code
```

`run-all.py` is the fast development gate. `run-dead-code` is explicit because dead-code scans can be slower and should not block every small edit loop.
