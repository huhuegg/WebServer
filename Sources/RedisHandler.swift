//
//  RedisHandler.swift
//  SwiftServer
//
//  Created by admin on 2016/11/21.
//
//
import PerfectHTTP


class RedisHandler:HttpHandler {
    
    class func redisSet(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        guard let key = valueForKey(request: request, key: "key"), let value = valueForKey(request: request, key: "value") else {
            responseReq(response: response, returnCode: .parmarError, errMsg: "params error(\(request.params()))", data: nil)
            return
        }

//        RedisService.doSet(key: key, value: value, callback: { succeed in
//            let returnCode:ReturnCode = succeed == true ? .success : .failed
//            let errMsg:String = succeed == true ? "success" : "redis set -> \(key):\(value) false"
//            responseReq(response: response, returnCode: returnCode, errMsg: errMsg, data: nil)
//        })
    }

    class func redisGet(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        guard let key = valueForKey(request: request, key: "key") else {
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
