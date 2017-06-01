//
//  ErrorMessageHandler.swift
//  WebServer
//
//  Created by admin on 2016/11/24.
//
//

import PerfectHTTP
import PerfectLib

class ErrorMessageHandler: HttpHandler {
    class func error(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        if request.method == .get {
            print("#GET#params:\(request.queryParams)")
        } else {
            print("#POST#params:\(request.params())")
        }
        
        guard let platform = valueForKey(request: request, key: "platform"),let device = valueForKey(request: request, key: "device"),let msg = valueForKey(request: request, key: "msg")
            else {
                responseReq(response: response, returnCode: .parmarError, errMsg: "params error(\(request.params()))", data: nil)
                return
        }
        Log.error(message: "[GCloud] platform:\(platform) device:\(device) errMsg:\(msg)")
        
        responseReq(response: response, returnCode: .success, errMsg: "ok", data: nil)
    }
    
}
