//
//  UploadHandler.swift
//  Upload Enumerator
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

import PerfectHTTP
import PerfectMustache
import PerfectLib
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif
let serverAddress = server.serverAddress == "0.0.0.0" ? "127.0.0.1" : server.serverAddress
let downloadHost = "http://" + serverAddress  + ":" + String(server.serverPort)
struct UploadHandler: MustachePageHandler { // all template handlers must inherit from PageHandler
	
	func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {

//		var values = MustacheEvaluationContext.MapType()
		// Grab the WebRequest so we can get information about what was uploaded
        let request = contxt.webRequest
        let response = contxt.webResponse
    
        //print("🌐  \(#function) uri:\(request.uri)")
        guard let type = HttpHandler.valueForKey(request: request, key: "type"), let sid = HttpHandler.valueForKey(request: request, key: "sid") else {
            HttpHandler.responseReq(response: response, returnCode: .parmarError, errMsg: "params error(\(request.params()))", data: nil)
            return
        }

        guard let uploads = request.postFileUploads , uploads.count > 0 else {
            HttpHandler.responseReq(response: response, returnCode: .parmarError, errMsg: "upload file count error!", data: nil)
            return
        }
        
        var downloads:Array<String> = Array()
        var ary = [[String:Any]]()
        
        for upload in uploads {
            //post时body中混杂有param和file的时候，在uploads中会有fieldName==""的数据，上传文件时需过滤掉
            if upload.fileName == "" {
                break
            }
            ary.append([
                "fieldName": upload.fieldName,
                "contentType": upload.contentType,
                "fileName": upload.fileName,
                "fileSize": upload.fileSize,
                "tmpFileName": upload.tmpFileName
                ])
            //print("ary:\(ary)")
            let userUploadDir = Dir(request.documentRoot + "/" + "uploads/" + type + "/" + sid)
            //let userUploadDir = Dir(Dir.workingDir.path + "webroot/" + "uploads/" + type + "/" + sid)
            //print("userUploadDir:\(userUploadDir.path)")
            do {
                try userUploadDir.create()
            } catch {
                print("#\(type)# create sid:\(sid) upload dir failed:\(error)")
                HttpHandler.responseReq(response: response, returnCode: .failed, errMsg: "create upload file dir error!", data: nil)
                return
            }

            // 将文件转移走，如果目标位置已经有同名文件则进行覆盖操作。
            let thisFile = File(upload.tmpFileName)
            do {

                let uploadFileName = randomString() + "." + upload.fileName.filePathExtension

                print("💾  save upload file: \(upload.fileName) -> \(uploadFileName)")
                
                let userDownloadDir = Dir(request.documentRoot + "/" + "downloads/" + type + "/" + sid)
                print("userDownloadDir:\(userDownloadDir.path)")
                try userDownloadDir.create()
                
                let _ = try thisFile.moveTo(path: userDownloadDir.path + uploadFileName, overWrite: true)
                let downloadPath = downloadHost + "/" + "downloads/" + type + "/" + sid + "/" + uploadFileName
                downloads.append(downloadPath)
            } catch {
                print(error)
                HttpHandler.responseReq(response: response, returnCode: .failed, errMsg: "upload file failed", data: nil)
                return
            }
        }
        
        HttpHandler.responseReq(response: response, returnCode: .success, errMsg: "success", data: ["downloads":downloads])
	}
    
    func randomString() ->String {
        return UUID().string
    }

}
