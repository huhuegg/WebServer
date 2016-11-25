//
//  HttpHandler.swift
//  WebServer
//
//  Created by admin on 2016/11/22.
//
//

import PerfectHTTP

class HttpHandler:NetworkHandler {
    class func valueForKey(request:HTTPRequest, key:String) -> String? {
        print("request:\(request)")
        let params = request.params()
        for (k,v) in params {
            if k == key {
                return v
            }
        }
        print("valueForKey:\(key) not found")
        return nil
    }
    
    class func responseReq(response: HTTPResponse, returnCode:ReturnCode, errMsg:String, data:Dictionary<String,Any>?) {
        response.setHeader(.contentType, value: "application/json")
        response.status = .ok //200
        
        var bodyDict:Dictionary<String,Any> = data == nil ? Dictionary():data!
        bodyDict["code"] = returnCode.rawValue
        bodyDict["msg"] = errMsg
        var bodyJson = ""
        do {
            bodyJson = try bodyDict.jsonEncodedString()
        } catch _ {
        }
        response.appendBody(string: bodyJson)
        print("📄  responseBody:\(bodyJson)")
        response.completed()
    }
}
