//
//  MysqlTestHandler.swift
//  WebServer
//
//  Created by huhuegg on 2017/6/7.
//
//

import PerfectHTTP


class MysqlTestHandler:HttpHandler {
    
    class func listDB(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        guard let wildcard = valueForKey(request: request, key: "wildcard") else {
            responseReq(response: response, returnCode: .parmarError, errMsg: "params error(\(request.params()))", data: nil)
            return
        }
        
        var returnCode:ReturnCode = .failed
        var data:Dictionary<String,Any>?
        if let result = MysqlService.listDB(wildcard == "" ? "%":wildcard) {
            returnCode = .success
            data = Dictionary()
            data["data"] = data
            responseReq(response: response, returnCode: returnCode, errMsg: "", data: data)
        } else {
            returnCode = .failed
            responseReq(response: response, returnCode: returnCode, errMsg: "failed", data: data)
        }
        
        if
        //        RedisService.doSet(key: key, value: value, callback: { succeed in
        //            let returnCode:ReturnCode = succeed == true ? .success : .failed
        //            let errMsg:String = succeed == true ? "success" : "redis set -> \(key):\(value) false"
        //            responseReq(response: response, returnCode: returnCode, errMsg: errMsg, data: nil)
        //        })
    }
    
    class func listTable(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        
        guard let wildcard = valueForKey(request: request, key: "wildcard") else {
            responseReq(response: response, returnCode: .parmarError, errMsg: "params error(\(request.params()))", data: nil)
            return
        }
        
        //        RedisService.doGet(key: key, callback: { (succeed,value) in
        //            if succeed == true && value != nil {
        //                responseReq(response: response, returnCode: .success, errMsg: "success", data: ["value":value!])
        //            } else {
        //                responseReq(response: response, returnCode: .failed, errMsg: "redis get -> \(key) failed", data: ["value":""])
        //            }
        //        })
    }
}
