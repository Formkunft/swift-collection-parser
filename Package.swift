// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "swift-collection-parser",
	products: [
		.library(
			name: "CollectionParser",
			targets: ["CollectionParser"]),
	],
	targets: [
		.target(
			name: "CollectionParser"),
		.testTarget(
			name: "CollectionParserTests",
			dependencies: ["CollectionParser"]),
	]
)
