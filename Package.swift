// swift-tools-version: 5.10
import PackageDescription

let package = Package(
	name: "LightTableParser",
	products: [
		.library(
			name: "LightTableParser",
			targets: ["LightTableParser"]),
	],
	targets: [
		.target(
			name: "LightTableParser"),
		.testTarget(
			name: "LightTableParserTests",
			dependencies: ["LightTableParser"]),
	]
)
