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
		.package(url: "git@github.com:happn-app/DummyLinuxOSLog.git", from: "1.0.0")
	],
	targets: [
		.target(
			name: "SemiSingleton",
			dependencies: ["DummyLinuxOSLog"]
		),
		.testTarget(
			name: "SemiSingletonTests",
			dependencies: ["SemiSingleton"]
		)
	]
)
