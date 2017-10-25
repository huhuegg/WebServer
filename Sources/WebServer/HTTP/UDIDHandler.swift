//
//  UUIDHandler.swift
//  WebServer
//
//  Created by admin on 2016/11/25.
//
//

import PerfectHTTP
import PerfectLib

class UDIDHandler: HttpHandler {
    class func udid(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        responseReq(response: response, returnCode: ReturnCode.success, errMsg: "", data: ["udid":UUID().string])
    }
}
