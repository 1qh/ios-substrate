import Foundation
import Testing

@Test
internal func `ios device tool has valid shell syntax`() throws {
    let scriptURL = packageRoot().appending(path: "tools/ios-device")
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-n", scriptURL.path]
    try process.run()
    process.waitUntilExit()
    #expect(process.terminationStatus == 0)
}

@Test
internal func `ios device tool provides help`() throws {
    let scriptURL = packageRoot().appending(path: "tools/ios-device")
    let process = Process()
    process.executableURL = scriptURL
    process.arguments = ["--help"]
    try process.run()
    process.waitUntilExit()
    #expect(process.terminationStatus == 0)
}

@Test
internal func `substrate templates stay product neutral`() throws {
    let rootURL = packageRoot()
    let templatePaths = [
        "templates/strict-swiftformat.config",
        "templates/strict-swiftlint.yml",
    ]

    for templatePath in templatePaths {
        let contents = try String(contentsOf: rootURL.appending(path: templatePath), encoding: .utf8)
        for forbiddenTerm in ["c" + "hat", "true" + "care"] {
            #expect(!contents.localizedCaseInsensitiveContains(forbiddenTerm))
        }
    }
}

private func packageRoot() -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}
