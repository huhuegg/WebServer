//
//  UUIDHandler.swift
//  WebServer
//
//  Created by admin on 2016/11/25.
//
//

import PerfectHTTP

class UUIDHandler: HttpHandler {
    class func udid(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        responseReq(response: response, returnCode: ReturnCode.success, errMsg: "", data: ["uuid":UUID().string])
    }
}
