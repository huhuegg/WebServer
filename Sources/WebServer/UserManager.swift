//
//  UserManager.swift
//  WebServerPackageDescription
//
//  Created by huhuegg on 2017/10/26.
//

import Foundation
import SwiftyJSON

let kAccountHost = "http://gaplay.ztgame.com"
class UserManager {
    static var _userManager = UserManager()
    
    static var shared:UserManager {
        return _userManager
    }
    
    let queue = DispatchQueue(label: "UserManager")
    
    var accountServerTimeOffset:Int = 0
    
    var sessionUserInfo:Dictionary<String,UserInfo> = Dictionary() // sessionId -> userInfo
    var userIdActiveSession:Dictionary<String,String> = Dictionary() // userId -> sessionId
    
    func setRole(sessionId:String, role:Int, callback:@escaping (_ status:Bool)->()) {
        queue.async {
            if let userInfo = self.sessionUserInfo[sessionId] {
                userInfo.role = role
                callback(true)
            } else {
                callback(false)
            }
        }
        
    }
    
    func getUserInfo(sessionId:String, callback:@escaping(_ userInfo:UserInfo?)->()) {
        
        if let userInfo = sessionUserInfo[sessionId] {
            callback(userInfo)
            return
        } else {
            sessionUserInfo(sessionId: sessionId, callback: { (userInfo) in
                callback(userInfo)
                return
            })
        }
        callback(nil)
    }
    
    func sessionUserInfo(sessionId:String, callback:@escaping (_ userInfo:UserInfo?)->()) {
        if accountServerTimeOffset == 0 {
            getAdustTime(callback: { (adustTimeStatus, adustTimeErrmsg) in
                if adustTimeStatus {
                    self.getSessionUserInfo(sessionId: sessionId, callback: { (status, errmsg, info) in
                        if let userInfo = UserInfo.fromNetworkSessionInfoDict(info) {
                            self.saveUserInfo(sessionId: sessionId, userInfo: userInfo, callback: {
                                callback(userInfo)
                                return
                            })
                        } else {
                            callback(nil)
                            return
                        }
                    })
                } else {
                    callback(nil)
                    return
                }
            })
        } else {
            self.getSessionUserInfo(sessionId: sessionId, callback: { (status, errmsg, info) in
                if let userInfo = UserInfo.fromNetworkSessionInfoDict(info) {
                    self.saveUserInfo(sessionId: sessionId, userInfo: userInfo, callback: {
                        callback(userInfo)
                        return
                    })
                } else {
                    callback(nil)
                    return
                }
            })
        }
    }
    
    func saveUserInfo(sessionId:String, userInfo:UserInfo, callback:@escaping ()->()) {
        queue.async {
            if let oldSessionId = self.userIdActiveSession[userInfo.userSid] {
                //删除用户的旧session对应信息
                self.sessionUserInfo.removeValue(forKey: oldSessionId)
            }
            self.userIdActiveSession[userInfo.userSid] = sessionId
            self.sessionUserInfo[sessionId] = userInfo
            callback()
        }
        
    }
    
    
    private func getSessionUserInfo(sessionId:String, callback:@escaping (_ status:Bool, _ errmsg:String, _ info:Dictionary<String,Any>?)->()) {
        self.getCurrentTimestamp { (timestamp) in
            var dict:Dictionary<String,String> = Dictionary()
            dict["sessionid"] = sessionId
            dict["timestamp"] = timestamp
            let paramStr = self.paramsFrom(dict: dict)
            
            let urlStr = kAccountHost + "/passport/LoadSession?" + paramStr
            
            print("URL:\(urlStr)")
            guard let url = URL(string: urlStr) else {
                callback(false,"url error",nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.timeoutInterval = 10
            request.httpMethod = "GET"
            
            
            let config = URLSessionConfiguration.default
            
            let session = URLSession(configuration: config)
            
            let sessionTask = session.dataTask(with: request) { (data, resp, error) in
                guard let httpResp = resp as? HTTPURLResponse else {
                    //print("resp failed")
                    callback(false,"resp",nil)
                    return
                }
                
                if (error != nil || httpResp.statusCode != 200) {
                    print("resp error! code:\(httpResp.statusCode) error:\(String(describing: error))")
                } else {
                    if let data = data {
                        do {
                            print("111111111111111: \(String(data: data, encoding: .utf8))")
                            let json = try JSON(data: data)
                            let code = json["code"].intValue
                            let msg = json["msg"].stringValue
                            
                            if let dataDict = json["data"].dictionaryObject {
                                callback(code == 0 ? true:false,msg,dataDict)
                                session.finishTasksAndInvalidate()
                                return
                            } else {
                                print("can't found data key")
                            }
                        } catch {
                            print("convert data to json failed")
                        }
                    } else {
                        print("data is nil")
                    }
                }
                session.finishTasksAndInvalidate()
                callback(false,"",nil)
                return
            }
            sessionTask.resume()
        }
    }
    
    private func getAdustTime(callback:@escaping (_ status:Bool, _ errmsg:String)->()) {
        self.getCurrentTimestamp { (timestamp) in
            var dict:Dictionary<String,String> = Dictionary()
            dict["timestamp"] = timestamp
            let paramStr = self.paramsFrom(dict: dict)
            
            let urlStr = kAccountHost + "/passport/AdustTime?" + paramStr
            guard let url = URL(string: urlStr) else {
                callback(false,"url error")
                return
            }
            
            var request = URLRequest(url: url)
            request.timeoutInterval = 10
            request.httpMethod = "GET"
            
            
            let config = URLSessionConfiguration.default
            
            let session = URLSession(configuration: config)
            
            let sessionTask = session.dataTask(with: request) { (data, resp, error) in
                guard let httpResp = resp as? HTTPURLResponse else {
                    //print("resp failed")
                    callback(false,"resp")
                    return
                }
                
                if (error != nil || httpResp.statusCode != 200) {
                    print("resp error! code:\(httpResp.statusCode) error:\(String(describing: error))")
                } else {
                    if let data = data {
                        do {
                            let json = try JSON(data: data)
                            if let timestamp = json["timestamp"].int {
                                self.queue.async {
                                    self.accountServerTimeOffset = timestamp - Int(Date().timeIntervalSince1970)
                                    callback(true,"")
                                    return
                                }
                            } else {
                                callback(false,"timestamp not found")
                                return
                            }
                        } catch {
                            callback(false,"convert data to json failed")
                            return
                        }
                    } else {
                        callback(false, "data is nil")
                    }
                }
                session.finishTasksAndInvalidate()
            }
            sessionTask.resume()
        }
        
    }
    
    private func paramsFrom(dict:Dictionary<String,String>) -> String {
        let appId = "100005"
        let privateKey = "ncABgk2TtQN4nUhd"
        
        var newDict:Dictionary<String,String> = dict
        newDict["appid"] = appId
        newDict["uuid"] = UUID().uuidString.md5
        
        var str:String = ""
        for key in newDict.keys.sorted() {
            if let value = newDict[key] {
                let tmpStr = key + "=" + value
                if str == "" {
                    str += tmpStr
                } else {
                    str += "&" + tmpStr
                }
            }
        }
        let checkStr = str + privateKey
        let sign = checkStr.md5
        str += "&sign=" + sign
        return str
    }
    
    private func getCurrentTimestamp(callback:@escaping(_ timestamp: String)->()) {
        queue.async {
            let date = Date().timeIntervalSince1970
            let offset = self.accountServerTimeOffset
            
            let timeInterval:Int = Int(date) + Int(offset)
            print("date:\(date) offset:\(offset) new:\(timeInterval)")
            callback(String(timeInterval))
        }
        
    }
}
