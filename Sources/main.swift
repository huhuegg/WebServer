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

// 创建路径用于存储上传文件
let uploadDir = Dir(Dir.workingDir.path + "uploads")
do {
    print("uploadDir:\(uploadDir)")
    try uploadDir.create()
    let audioDir = Dir(uploadDir.path + "audio")
    do {
        try audioDir.create()
    } catch {
        print("create upload audio dir failed:\(error)")
    }
} catch {
    print("create uploads dir failed:\(error)")
}

// Create HTTP server.
let server = HTTPServer()

// Register your own routes and handlers
var routes = Routes()
routes.add(method: .get, uri: "/udid", handler: UDIDHandler.udid)
routes.add(method: .post, uri: "/noteCreate", handler: NoteHandler.create)

routes.add(method: .get, uri: "/get", handler: RedisHandler.doGet)
routes.add(method: .get, uri: "/set", handler: RedisHandler.doSet)

//静态文件下载
routes.add(method: .get, uri: "/download/**", handler: DownloadHandler.download)
//文件上传
routes.add(method: .post, uri: "/upload", handler: {(request: HTTPRequest, response: HTTPResponse) in
    print("🌐  \(#function) uri:\(request.uri)")
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
    print("📄  testUpload:\(body)")
    response.completed()
})


// Add the routes to the server.
server.addRoutes(routes)

server.serverPort = 10001

// Set a document root.
// This is optional. If you do not want to serve static content then do not set this.
// Setting the document root will automatically add a static file handler for the route /**
server.documentRoot = "./webroot"

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
configureServer(server)

do {    
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}


