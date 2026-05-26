# iOS substrate

Reusable SwiftUI app substrate. Docs live in the sibling
`../ios-substrate-docs` repository.

## Current baseline

- Swift package floor: iOS 18 and macOS 26.
- Code primitives: app identity, Info.plist config parsing, backend origin
  validation, release channel config, telemetry toggles, base64url codec, and debug
  backend override storage.
- Tooling primitives: strict SwiftFormat, SwiftLint, launch-config access,
  false-green verification, Python tooling lint, editorconfig, markdown, YAML,
  JSON, shell, typo, CLI doctor, package-test, and product-neutrality gates.
- CLI config discovery: `iosx path` exposes every strict config used by public
  gates, including the repository typo dictionary. `iosx doctor --fast` proves
  fast-loop helpers and gates; `iosx doctor --all` also proves dedicated
  on-demand dead-code tooling.
- Runtime boundary: substrate ships Swift app primitives and local development
  tools only. Python is used only to implement and dogfood local gate scripts;
  no consumer app runtime depends on Python.

## Gates

```sh
iosx lint run-all
iosx lint run-all --list-gates
iosx lint run-all --from swiftlint
iosx lint dead-code
```

`iosx lint run-all` is the fast development gate. `iosx lint dead-code` is explicit because
dead-code scans can be slower and should not block every small edit loop.
