//
//  XHandler.swift
//  WebServer
//
//  Created by huhuegg on 2017/10/26.
//

import PerfectHTTP
import SwiftyJSON

class XHandler: HttpHandler {
    class func setRole(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        if request.method == .get {
            print("#GET#params:\(request.queryParams)")
        } else {
            print("#POST#params:\(request.params())")
        }
        
        guard let (k,_) = request.params().first else {
            responseXReq(response: response, status: .failed, errMsg: "params is nil", data: nil)
            return
        }
        do {
            let json = try JSON(parseJSON: k)
            guard let roleId = json["role_id"].int,
                let sessionId = json["session_id"].string
                else {
                    responseXReq(response: response, status: .failed, errMsg: "params error(\(request.params()))", data: nil)
                    return
            }
            UserManager.shared.setRole(sessionId: sessionId, role: roleId, callback: { (status) in
                if status == true {
                    responseXReq(response: response, status: .succeed, errMsg: "", data: nil)
                    return
                } else {
                    responseXReq(response: response, status: .failed, errMsg: "setRole failed", data: nil)
                    return
                }
            })
            
        } catch {
            responseXReq(response: response, status: .failed, errMsg: "decode params failed", data: nil)
            return
        }
    }
 
    class func getRole(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        if request.method == .get {
            print("#GET#params:\(request.queryParams)")
        } else {
            print("#POST#params:\(request.params())")
        }
        
        guard let (k,_) = request.params().first else {
            responseXReq(response: response, status: .failed, errMsg: "params is nil", data: nil)
            return
        }
        do {
            let json = try JSON(parseJSON: k)
            if let sessionId = json["session_id"].string {
                UserManager.shared.getUserInfo(sessionId: sessionId, callback: { (userInfo) in
                    if let userInfo = userInfo {
                        var data:Dictionary<String,Any> = Dictionary()
                        data["uid"] = userInfo.userSid
                        data["role_id"] = userInfo.role
                        
                        responseXReq(response: response, status: .succeed, errMsg: "", data: data)
                        return
                    }
                })
            } else {
                responseXReq(response: response, status: .failed, errMsg: "sessionId not found", data: nil)
                return
            }
        } catch {
            print("decode params failed")
            responseXReq(response: response, status: .failed, errMsg: "decode params failed", data: nil)
            return
        }
        
        
    }
    
    class func createCourse(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        if request.method == .get {
            print("#GET#params:\(request.queryParams)")
        } else {
            print("#POST#params:\(request.params())")
        }
        
        guard let (k,_) = request.params().first else {
            responseXReq(response: response, status: .failed, errMsg: "params is nil", data: nil)
            return
        }
        do {
            let json = try JSON(parseJSON: k)
            if let sessionId = json["session_id"].string, let title = json["title"].string, let desc = json["desc"].string, let start_time = json["start_time"].double, let duration = json["duration"].int, let pic = json["pic"].string {
                UserManager.shared.getUserInfo(sessionId: sessionId, callback: { (userInfo) in
                    if let userInfo = userInfo {
                        let course = Course(ownerUserSid: userInfo.userSid, title: title, desc: desc, starttime: start_time, duration: duration, imageUrl: pic)
                        course.status = .waiting
                        CourseManager.shared.newCourse(course: course)
                        CourseManager.shared.changeStatus(course: course)
                        
                        responseXReq(response: response, status: .succeed, errMsg: "", data: course.toDict())
                        return
                    }
                })
            } else {
                responseXReq(response: response, status: .failed, errMsg: "params error", data: nil)
                return
            }
        } catch {
            print("decode params failed")
            responseXReq(response: response, status: .failed, errMsg: "decode params failed", data: nil)
            return
        }
        responseXReq(response: response, status: .failed, errMsg: "", data: nil)
    }
    
    class func courseList(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        if request.method == .get {
            print("#GET#params:\(request.queryParams)")
        } else {
            print("#POST#params:\(request.params())")
        }
        
        guard let (k,_) = request.params().first else {
            responseXReq(response: response, status: .failed, errMsg: "params is nil", data: nil)
            return
        }
        do {
            let json = try JSON(parseJSON: k)
            //{\"session_id\":\"tcph7orkjv5ie54cgu2lh5c7e7\",\"page_index\":1,\"page_size\":20,\"status\":[1,2]}
            if let sessionId = json["session_id"].string, let status = json["status"].arrayObject {
                UserManager.shared.getUserInfo(sessionId: sessionId, callback: { (userInfo) in
                    if let userInfo = userInfo {
                        var list:Array<Dictionary<String,Any>> = Array()
                        for s in status {
                            if let s = s as? Int {
                                if s == CourseStatus.waiting.rawValue {
                                    for i in CourseManager.shared.waitingCourse {
                                        list.append(i.toDict())
                                    }
                                }
                                if s == CourseStatus.ing.rawValue {
                                    for i in CourseManager.shared.ingCourse {
                                        list.append(i.toDict())
                                    }
                                }
                                if s == CourseStatus.end.rawValue {
                                    for i in CourseManager.shared.completedCourse {
                                        list.append(i.toDict())
                                    }
                                }
                            }
                        }
                        var data:Dictionary<String,Any> = Dictionary()
                        data["list"] = list
                        responseXReq(response: response, status: .succeed, errMsg: "", data: data)
                        return
                    } else {
                        responseXReq(response: response, status: .failed, errMsg: "userInfo is nil", data: nil)
                        return
                    }
                })
            } else {
                responseXReq(response: response, status: .failed, errMsg: "params error", data: nil)
                return
            }
        } catch {
            print("decode params failed")
            responseXReq(response: response, status: .failed, errMsg: "decode params failed", data: nil)
            return
        }
    }
}
