// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription



let package = Package(
	name: "SemiSingleton",
	products: [
		.library(
			name: "SemiSingleton",
			targets: ["SemiSingleton"]
		)
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "SemiSingleton",
			dependencies: []
		),
		.testTarget(
			name: "SemiSingletonTests",
			dependencies: ["SemiSingleton"]
		)
	]
)
