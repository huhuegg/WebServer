// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebServer",
    dependencies: [
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
		.package(url:"https://github.com/PerfectlySoft/Perfect-Mustache.git", from: "3.0.0"), //for http(s) upload file
        .package(url:"https://github.com/PerfectlySoft/Perfect-Redis.git", from: "3.0.0"),
        .package(url:"https://github.com/PerfectlySoft/Perfect-WebSockets.git", from: "3.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0-alpha.1"),
		.package(url:"https://github.com/PerfectlySoft/Perfect-MySQL.git", from: "3.0.0"),
		.package(url: "https://github.com/iamjono/SwiftMD5.git", from: "1.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/BrettRToomey/Jobs.git", from: "1.1.1"),                   //定时任务
    ],
	targets: [
        .target(
            name: "WebServer",
            dependencies: ["PerfectRedis","PerfectHTTPServer","PerfectMustache","SwiftyJSON","PerfectWebSockets","PerfectMySQL","SwiftyJSON","PerfectCrypto","SwiftMD5", "Jobs"]
		),
    ]
)
