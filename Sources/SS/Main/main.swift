//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import PerfectWebSockets

import PerfectThread

Log.logger = SysLogger()

//connect redis server
RedisService.instance.initRedis { (isSuccess) in
    if isSuccess {
//        print("connect redis ok!")
    } else {
//        print("connect redis failed!")
    }
}


// Create HTTP server.
let server = HTTPServer()

// Register your own routes and handlers
var routes = Routes()

//WebSocket
routes.add(method: .get, uri: "/ss", handler: {
    request, response in

    WebSocketHandler(handlerProducer: {
        (request: HTTPRequest, protocols: [String]) -> WebSocketSessionHandler? in

        // 检查客户端的protocols中是否包含指定内容
        guard protocols.contains("SS") else {
            print("protocols error!")
            return nil
        }
        return WebSocketsHandler()
    }).handleRequest(request: request, response: response)
})

// Add the routes to the server.
server.addRoutes(routes)
//server.serverAddress = "192.168.96.104"
server.serverPort = 10002

server.documentRoot = "~/webroot"



do {
    // Launch the HTTP server.
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
configureServer(server)
