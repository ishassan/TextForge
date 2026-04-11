// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TextForgeCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TextForgeCore",
            targets: ["TextForgeCore"]
        )
    ],
    targets: [
        .target(
            name: "TextForgeCore",
            path: "TextForge",
            exclude: [
                "App",
                "DesignSystem",
                "Features",
                "Persistence",
                "Resources",
                "WidgetsStub",
                "Services/ClipboardMonitoringService.swift",
                "Services/Documents",
                "Services/Snippets"
            ]
        ),
        .executableTarget(
            name: "TextForgeCoreSmoke",
            dependencies: ["TextForgeCore"],
            path: "TextForgeTests/Smoke"
        )
    ]
)
