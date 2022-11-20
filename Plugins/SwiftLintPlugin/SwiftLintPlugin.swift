import Foundation
import PackagePlugin

@main
struct SwiftLintPlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PluginContext,
        target: Target
    ) async throws -> [Command] {
        guard let target = target as? SourceModuleTarget else { return [] }

        let inputFiles = target.sourceFiles(withSuffix: "swift").map(\.path)

        guard !inputFiles.isEmpty else { return [] }

        let arguments = [
            "lint",
            "--cache-path", "\(context.pluginWorkDirectory)",
            "\(context.pluginWorkDirectory.appending("Package.swift"))",
        ] + inputFiles.map(\.string)

        return [
            .buildCommand(
                displayName: "SwiftLint",
                executable: try context.tool(named: "swiftlint").path,
                arguments: arguments,
                inputFiles: inputFiles,
                outputFiles: [context.pluginWorkDirectory] // Avoid running every build phase
            ),
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftLintPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(
        context: XcodePluginContext,
        target: XcodeTarget
    ) throws -> [Command] {
        let inputFiles = target.inputFiles
            .filter { $0.type == .source && $0.path.extension == "swift" }
            .map(\.path)

        guard !inputFiles.isEmpty else { return [] }

        let arguments = [
            "lint",
            "--cache-path", "\(context.pluginWorkDirectory)",
        ] + inputFiles.map(\.string)

        return [
            .buildCommand(
                displayName: "SwiftLint",
                executable: try context.tool(named: "swiftlint").path,
                arguments: arguments,
                inputFiles: inputFiles,
                outputFiles: [context.pluginWorkDirectory] // Avoid running every build phase
            ),
        ]
    }
}
#endif
