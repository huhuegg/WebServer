//
//  NoteHandler.swift
//  WebServer
//
//  Created by admin on 2016/11/24.
//
//

import PerfectHTTP

class NoteHandler: HttpHandler {
    class func create(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        if request.method == .get {
            print("#GET#params:\(request.queryParams)")
        } else {
            print("#POST#params:\(request.params())")
        }

        guard let type = valueForKey(request: request, key: "type"),
              let title = valueForKey(request: request, key: "title"),
              let info = valueForKey(request: request, key: "info"),
              let lastEditTime = valueForKey(request: request, key: "lastEditTime"),
              let fileUrl = valueForKey(request: request, key: "fileUrl"),
              let size = valueForKey(request: request, key: "size")
            else {
            responseReq(response: response, returnCode: .parmarError, errMsg: "params error(\(request.params()))", data: nil)
            return
        }
        let msg = "type:\(type) title:\(title) info:\(info) lastEditTime:\(lastEditTime) fileUrl:\(fileUrl) size:\(size)"
        responseReq(response: response, returnCode: .success, errMsg: msg, data: nil)
    }

}
