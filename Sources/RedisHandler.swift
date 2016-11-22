//
//  RedisHandler.swift
//  SwiftServer
//
//  Created by admin on 2016/11/21.
//
//
import PerfectHTTP


class RedisHandler:HttpHandler {
    
    class func doSet(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐\(#function) uri:\(request.uri)")
        guard let key = valueForKey(request: request, key: "key"), let value = valueForKey(request: request, key: "value") else {
            responseReq(response: response, returnCode: .parmarError, errMsg: "params error(\(request.params()))", data: nil)
            return
        }

        RedisService.redisSet(key: key, value: value, callback: { succeed in
            let returnCode:ReturnCode = succeed == true ? .success : .failed
            let errMsg:String = succeed == true ? "success" : "redis set -> \(key):\(value) false"
            responseReq(response: response, returnCode: returnCode, errMsg: errMsg, data: nil)
        })
    }

    class func doGet(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐\(#function) uri:\(request.uri)")
        guard let key = valueForKey(request: request, key: "key") else {
            responseReq(response: response, returnCode: .parmarError, errMsg: "params error(\(request.params()))", data: nil)
            return
        }
        
        RedisService.redisGet(key: key, callback: { (succeed,value) in
            if succeed == true && value != nil {
                responseReq(response: response, returnCode: .success, errMsg: "success", data: ["value":value!])
            } else {
                responseReq(response: response, returnCode: .failed, errMsg: "redis get -> \(key) failed", data: ["value":""])
            }
        })
    }
}
