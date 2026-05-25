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
        "_typos.toml",
        "templates/strict-checkmake.ini",
        "templates/strict-editorconfig-checker.json",
        "templates/strict-markdownlint.json",
        "templates/strict-ruff.toml",
        "templates/strict-swiftformat.config",
        "templates/strict-swiftlint.yml",
        "templates/strict-yamllint.yml",
    ]

    for templatePath in templatePaths {
        let contents = try String(contentsOf: rootURL.appending(path: templatePath), encoding: .utf8)
        for forbiddenTerm in ["c" + "hat", "true" + "care"] {
            #expect(!contents.localizedCaseInsensitiveContains(forbiddenTerm))
        }
    }
}

@Test
internal func `iosx path contract stays self consistent`() throws {
    let commandsOutput = try runIOSX(["commands", "--json"]).standardOutput
    let commandsData = Data(commandsOutput.utf8)
    let parsedCommands = try JSONSerialization.jsonObject(with: commandsData)
    guard let rootObject = parsedCommands as? [String: Any] else {
        throw ToolingSmokeError.invalidCommandCatalog
    }
    guard let commands = rootObject["commands"] as? [[String: Any]] else {
        throw ToolingSmokeError.invalidCommandCatalog
    }

    let pathCommand = commands.first { $0["name"] as? String == "path" }
    guard let pathUsage = pathCommand?["usage"] as? String else {
        throw ToolingSmokeError.invalidCommandCatalog
    }

    let helpOutput = try runIOSX(["--help"]).standardOutput
    #expect(helpOutput.contains(pathUsage.replacingOccurrences(of: "iosx ", with: "")))

    let prefix = "iosx path [--json] "
    #expect(pathUsage.hasPrefix(prefix))
    let targets = pathUsage.dropFirst(prefix.count).split(separator: "|").map(String.init)
    #expect(!targets.isEmpty)

    for target in targets {
        let pathOutput = try runIOSX(["path", "--json", target]).standardOutput
        let pathData = Data(pathOutput.utf8)
        let parsedPath = try JSONSerialization.jsonObject(with: pathData)
        guard let pathObject = parsedPath as? [String: String] else {
            throw ToolingSmokeError.invalidPathResponse(target)
        }
        guard pathObject["kind"] == target else {
            throw ToolingSmokeError.invalidPathResponse(target)
        }
        guard let path = pathObject["path"] else {
            throw ToolingSmokeError.invalidPathResponse(target)
        }

        #expect(FileManager.default.fileExists(atPath: path))
    }
}

private struct ToolProcessOutput {
    var standardOutput: String
    var standardError: String
}

private enum ToolingSmokeError: Error, CustomStringConvertible {
    case invalidCommandCatalog
    case invalidPathResponse(String)
    case invalidUTF8(arguments: [String])
    case processFailed(arguments: [String], status: Int32, stderr: String)

    var description: String {
        switch self {
        case .invalidCommandCatalog:
            "iosx commands --json did not contain a valid path command"

        case let .invalidPathResponse(target):
            "iosx path --json returned an invalid response for \(target)"

        case let .invalidUTF8(arguments):
            "iosx \(arguments.joined(separator: " ")) returned non-UTF-8 output"

        case let .processFailed(arguments, status, stderr):
            "iosx \(arguments.joined(separator: " ")) failed with \(status): \(stderr)"
        }
    }
}

private func runIOSX(_ arguments: [String]) throws -> ToolProcessOutput {
    let process = Process()
    let standardOutput = Pipe()
    let standardError = Pipe()
    process.executableURL = packageRoot().appending(path: "tools/iosx")
    process.arguments = arguments
    process.standardOutput = standardOutput
    process.standardError = standardError
    try process.run()
    process.waitUntilExit()

    let outputData = standardOutput.fileHandleForReading.readDataToEndOfFile()
    let errorData = standardError.fileHandleForReading.readDataToEndOfFile()
    guard let outputText = String(data: outputData, encoding: .utf8) else {
        throw ToolingSmokeError.invalidUTF8(arguments: arguments)
    }
    guard let errorText = String(data: errorData, encoding: .utf8) else {
        throw ToolingSmokeError.invalidUTF8(arguments: arguments)
    }

    if process.terminationStatus != 0 {
        throw ToolingSmokeError.processFailed(
            arguments: arguments,
            status: process.terminationStatus,
            stderr: errorText,
        )
    }
    return ToolProcessOutput(standardOutput: outputText, standardError: errorText)
}

private func packageRoot() -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}
