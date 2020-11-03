// swift-tools-version:5.1
import PackageDescription


let package = Package(
	name: "SemiSingleton",
	products: [
		.library(name: "SemiSingleton", targets: ["SemiSingleton"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
		.package(url: "https://github.com/happn-tech/RecursiveSyncDispatch.git", from: "1.0.0")
	],
	targets: [
		.target(name: "SemiSingleton", dependencies: [
			.product(name: "Logging", package: "swift-log"),
			.product(name: "RecursiveSyncDispatch", package: "RecursiveSyncDispatch")
		]),
		.testTarget(name: "SemiSingletonTests", dependencies: ["SemiSingleton"])
	]
)
