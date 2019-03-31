// swift-tools-version:5.0
import PackageDescription


let package = Package(
	name: "SemiSingleton",
	products: [
		.library(name: "SemiSingleton", targets: ["SemiSingleton"]),
	],
	dependencies: [
		.package(url: "https://github.com/happn-tech/DummyLinuxOSLog.git", from: "1.0.1"),
		.package(url: "https://github.com/happn-tech/RecursiveSyncDispatch.git", from: "1.0.0")
	],
	targets: [
		.target(name: "SemiSingleton", dependencies: ["DummyLinuxOSLog", "RecursiveSyncDispatch"]),
		.testTarget(name: "SemiSingletonTests", dependencies: ["SemiSingleton"])
	]
)
