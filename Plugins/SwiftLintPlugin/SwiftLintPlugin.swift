import Foundation
import PackagePlugin

@main
struct SwiftLintPlugin: BuildToolPlugin {
    func createBuildCommands(
        executable: Path,
        inputFiles: [Path],
        pluginWorkDirectory: Path
    ) -> [Command] {
        guard !inputFiles.isEmpty else { return [] }

        let arguments = [
            "lint",
            "--cache-path", "\(pluginWorkDirectory)",
        ] + inputFiles.map(\.string)

        return [
            .buildCommand(
                displayName: "SwiftLint",
                executable: executable,
                arguments: arguments,
                inputFiles: inputFiles,
                outputFiles: [pluginWorkDirectory] // Avoid running every build phase
            ),
        ]
    }

    func createBuildCommands(
        context: PluginContext,
        target: Target
    ) async throws -> [Command] {
        guard let target = target as? SourceModuleTarget else { return [] }
    
        let inputFiles = target.sourceFiles(withSuffix: "swift").map(\.path)

        return createBuildCommands(
            executable: try context.tool(named: "swiftlint").path,
            inputFiles: inputFiles,
            pluginWorkDirectory: context.pluginWorkDirectory
        )
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

        return createBuildCommands(
            executable: try context.tool(named: "swiftlint").path,
            inputFiles: inputFiles,
            pluginWorkDirectory: context.pluginWorkDirectory
        )
    }
}
#endif
