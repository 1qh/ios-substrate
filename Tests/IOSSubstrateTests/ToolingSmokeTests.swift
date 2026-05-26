import Foundation
import Testing

@Test
internal func `ios helper scripts have valid shell syntax`() throws {
    let scripts = [
        "tools/iosx",
        "tools/ios-device",
        "tools/ios-sim",
        "tools/ios-xcode",
        "tools/lint/run-dead-code",
    ]

    for script in scripts {
        let scriptURL = packageRoot().appending(path: script)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-n", scriptURL.path]
        try process.run()
        process.waitUntilExit()
        #expect(process.terminationStatus == 0)
    }
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
internal func `iosx command catalog stays self consistent`() throws {
    let commands = try iosxCommandCatalog()
    let helpOutput = try runIOSX(["--help"]).standardOutput

    for command in commands {
        #expect(helpOutput.contains(command.usage.replacingOccurrences(of: "iosx ", with: "")))
        #expect(!command.name.isEmpty)
        #expect(!command.usage.isEmpty)
        #expect(!command.purpose.isEmpty)
    }

    let commandNames = commands.map(\.name)
    #expect(Set(commandNames).count == commandNames.count)
}

@Test
internal func `iosx command catalog dispatches every advertised command`() throws {
    let expectedSmokeArguments: [(String, [String])] = [
        ("doctor", ["doctor", "--fast", "--json"]),
        ("version", ["version", "--json"]),
        ("commands", ["commands", "--json"]),
        ("path", ["path", "--json", "root"]),
        ("device", ["device", "--help"]),
        ("sim", ["sim", "--help"]),
        ("xcode", ["xcode", "--help"]),
        ("lint swift-gates", ["lint", "swift-gates", "--help"]),
        ("lint swiftformat", ["lint", "swiftformat", "--version"]),
        ("lint markdown", ["lint", "markdown", "tools/README.md"]),
        ("lint typos", ["lint", "typos", "--version"]),
        ("lint checkmake", ["lint", "checkmake", "--version"]),
        ("lint shellcheck", ["lint", "shellcheck", "--version"]),
        ("lint shfmt", ["lint", "shfmt", "--version"]),
        ("lint false-green", ["lint", "false-green", "--selftest"]),
        ("lint no-direct-bundle-config", ["lint", "no-direct-bundle-config", "--selftest"]),
        ("lint no-direct-ios-helper", ["lint", "no-direct-ios-helper", "--selftest"]),
        ("lint run-all", ["lint", "run-all", "--selftest"]),
        ("lint dead-code", ["lint", "dead-code", "--help"]),
    ]
    let expectedNames = expectedSmokeArguments.map(\.0)
    let smokeArgumentsByName = Dictionary(uniqueKeysWithValues: expectedSmokeArguments)
    let commands = try iosxCommandCatalog()

    #expect(commands.map(\.name) == expectedNames)

    for command in commands {
        guard let arguments = smokeArgumentsByName[command.name] else {
            throw ToolingSmokeError.uncoveredCommand(command.name)
        }

        let output = try runIOSX(arguments)
        #expect(!output.standardOutput.isEmpty)
    }
}

@Test
internal func `iosx path contract stays self consistent`() throws {
    let commands = try iosxCommandCatalog()
    let pathCommand = commands.first { $0.name == "path" }
    guard let pathUsage = pathCommand?.usage else {
        throw ToolingSmokeError.invalidCommandCatalog
    }

    let prefix = "iosx path [--json] "
    #expect(pathUsage.hasPrefix(prefix))
    let targets = pathUsage.dropFirst(prefix.count).split(separator: "|").map(String.init)
    #expect(!targets.isEmpty)
    #expect(Set(targets).count == targets.count)

    for target in targets {
        let pathOutput = try runIOSX(["path", "--json", target]).standardOutput
        let pathData = Data(pathOutput.utf8)
        let parsedPath = try JSONSerialization.jsonObject(with: pathData)
        guard let pathObject = parsedPath as? [String: String] else {
            throw ToolingSmokeError.invalidPathResponse(target)
        }
        guard Set(pathObject.keys) == Set(["kind", "path"]) else {
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

@Test
internal func `iosx path json failure contract stays stable`() throws {
    let output = try runIOSX(["path", "--json", "not-a-path-target"], expectedStatus: 2)
    let errorObject = try jsonObject(output.standardOutput, error: .invalidPathResponse("not-a-path-target"))

    #expect(errorObject["ok"] as? Bool == false)
    #expect(errorObject["error"] as? String == "unknown-path-target")
    #expect(errorObject["target"] as? String == "not-a-path-target")
    #expect(output.standardError.isEmpty)
}

@Test
internal func `iosx doctor tiers expose stable JSON contract`() throws {
    let fastDoctor = try iosxDoctorJSON(["doctor", "--fast", "--json"])
    let allDoctor = try iosxDoctorJSON(["doctor", "--all", "--json"])

    #expect(fastDoctor["ok"] as? Bool == true)
    #expect(fastDoctor["scope"] as? String == "fast")
    #expect(fastDoctor["root"] as? String == packageRoot().path)
    #expect((fastDoctor["version"] as? String)?.isEmpty == false)
    #expect((fastDoctor["missing"] as? [String])?.isEmpty == true)

    #expect(allDoctor["ok"] as? Bool == true)
    #expect(allDoctor["scope"] as? String == "all")
    #expect(allDoctor["root"] as? String == packageRoot().path)
    #expect((allDoctor["version"] as? String)?.isEmpty == false)
    #expect((allDoctor["missing"] as? [String])?.isEmpty == true)
}

@Test
internal func `iosx doctor json failure contract stays stable`() throws {
    let output = try runIOSX(
        ["doctor", "--fast", "--json"],
        environment: ["PATH": "/bin:/usr/bin:/usr/sbin:/sbin"],
        expectedStatus: 1,
    )
    let doctor = try doctorJSON(output.standardOutput, arguments: ["doctor", "--fast", "--json"])

    #expect(doctor["ok"] as? Bool == false)
    #expect(doctor["scope"] as? String == "fast")
    #expect(doctor["root"] as? String == packageRoot().path)
    #expect((doctor["version"] as? String)?.isEmpty == false)
    #expect((doctor["missing"] as? [String])?.isEmpty == false)
    #expect(output.standardError.contains("iosx: missing executable:"))
}

private struct IOSXCommandCatalog: Decodable {
    let commands: [IOSXCommandSpec]
}

private struct IOSXCommandSpec: Decodable {
    let name: String
    let usage: String
    let purpose: String
}

private func iosxCommandCatalog() throws -> [IOSXCommandSpec] {
    let commandsOutput = try runIOSX(["commands", "--json"]).standardOutput
    let decoded = try JSONDecoder().decode(IOSXCommandCatalog.self, from: Data(commandsOutput.utf8))
    guard !decoded.commands.isEmpty else {
        throw ToolingSmokeError.invalidCommandCatalog
    }

    return decoded.commands
}

private func iosxDoctorJSON(_ arguments: [String]) throws -> [String: Any] {
    let output = try runIOSX(arguments).standardOutput
    return try doctorJSON(output, arguments: arguments)
}

private func doctorJSON(_ output: String, arguments: [String]) throws -> [String: Any] {
    let object = try jsonObject(output, error: .invalidDoctorResponse(arguments))

    for requiredKey in ["ok", "scope", "root", "version", "missing"] where object[requiredKey] == nil {
        throw ToolingSmokeError.invalidDoctorResponse(arguments)
    }
    return object
}

private func jsonObject(_ output: String, error: ToolingSmokeError) throws -> [String: Any] {
    let data = Data(output.utf8)
    let parsed = try JSONSerialization.jsonObject(with: data)
    guard let object = parsed as? [String: Any] else {
        throw error
    }

    return object
}

private struct ToolProcessOutput {
    var standardOutput: String
    var standardError: String
}

private enum ToolingSmokeError: Error, CustomStringConvertible {
    case invalidCommandCatalog
    case invalidDoctorResponse([String])
    case invalidPathResponse(String)
    case invalidUTF8(arguments: [String])
    case processFailed(arguments: [String], status: Int32, stderr: String)
    case uncoveredCommand(String)

    var description: String {
        switch self {
        case .invalidCommandCatalog:
            "iosx commands --json did not contain a valid command catalog"

        case let .invalidDoctorResponse(arguments):
            "iosx \(arguments.joined(separator: " ")) returned an invalid doctor response"

        case let .invalidPathResponse(target):
            "iosx path --json returned an invalid response for \(target)"

        case let .invalidUTF8(arguments):
            "iosx \(arguments.joined(separator: " ")) returned non-UTF-8 output"

        case let .processFailed(arguments, status, stderr):
            "iosx \(arguments.joined(separator: " ")) failed with \(status): \(stderr)"

        case let .uncoveredCommand(command):
            "iosx command catalog entry has no smoke dispatch coverage: \(command)"
        }
    }
}

private func runIOSX(
    _ arguments: [String],
    environment: [String: String] = [:],
    expectedStatus: Int32 = 0,
) throws -> ToolProcessOutput {
    let process = Process()
    let standardOutput = Pipe()
    let standardError = Pipe()
    process.executableURL = packageRoot().appending(path: "tools/iosx")
    process.arguments = arguments
    process.environment = ProcessInfo.processInfo.environment.merging(environment) { _, new in new }
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

    if process.terminationStatus != expectedStatus {
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
