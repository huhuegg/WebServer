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
//routes.add(method: .get, uri: "/error", handler: ErrorMessageHandler.error)
//routes.add(method: .get, uri: "/udid", handler: UDIDHandler.udid)
//routes.add(method: .post, uri: "/noteCreate", handler: NoteHandler.create)
//
//routes.add(method: .post, uri: "/error", handler: ErrorMessageHandler.error)
//
//routes.add(method: .get, uri: "/get", handler: RedisHandler.doGet)
//routes.add(method: .get, uri: "/set", handler: RedisHandler.doSet)

//静态文件下载
routes.add(method: .get, uri: "/download/**", handler: DownloadHandler.download)
//文件上传
routes.add(method: .post, uri: "/upload", handler: {(request: HTTPRequest, response: HTTPResponse) in
    //print("🌐  \(#function) uri:\(request.uri)")
    let webRoot = request.documentRoot
    
    mustacheRequest(request: request, response: response, handler: UploadHandler(), templatePath: webRoot + "/response.mustache")
})

//文件上传测试页面
routes.add(method: .get, uri: "/testUpload", handler: {(request: HTTPRequest, response: HTTPResponse) in
    response.status = .ok //200
    guard let type = HttpHandler.valueForKey(request: request, key: "type"), let sid = HttpHandler.valueForKey(request: request, key: "sid") else {
        HttpHandler.responseReq(response: response, returnCode: .parmarError, errMsg: "params error(\(request.params()))", data: nil)
        return
    }
    
    var body = ""
    body += "<html><body>\n"
    body += "<form action=\"/upload?type=\(type)&sid=\(sid)\" method=\"post\" enctype=\"multipart/form-data\">"
    body += "<label>File1:</label> <input type=\"file\" name=\"filetoupload\" id=\"file\" /><br/>"
    body += "<label>File2:</label> <input type=\"file\" name=\"filetoupload\" id=\"file\" /><br/>"
    body += "<input type=\"submit\"/>"
    body += "</form>"
    body += "</body></html>\n"

    response.appendBody(string: body)
    response.completed()
})


//WebSocket
routes.add(method: .get, uri: "/websocket", handler: {
    request, response in

    WebSocketHandler(handlerProducer: {
        (request: HTTPRequest, protocols: [String]) -> WebSocketSessionHandler? in
        
        // 检查客户端的protocols中是否包含指定内容
        guard protocols.contains("X") else {
            return nil
        }
        return WebSocketsHandler()
    }).handleRequest(request: request, response: response)
})

// Add the routes to the server.
server.addRoutes(routes)
//server.serverAddress = "192.168.96.104"
server.serverPort = 10001

server.documentRoot = "~/webroot"

// 创建文件路径
let serverDocumentDir = Dir(server.documentRoot)
let uploadDir = Dir(server.documentRoot + "/uploads")
let downloadDir = Dir(server.documentRoot + "/downloads")
do {
    try serverDocumentDir.create()
    //print("uploadDir:\(uploadDir) downloadDir:\(downloadDir)")
    for d in [uploadDir,downloadDir] {
        for subDirName in ["image","audio","video"] {
            let subDir = Dir(d.path + subDirName)
            try subDir.create()
        }
    }
} catch {
    print("create dir failed:\(error)")
}


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
