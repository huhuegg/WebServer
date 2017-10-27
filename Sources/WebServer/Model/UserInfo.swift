//
//  UserInfo.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/15.
//
//

import SwiftyJSON

class UserInfo {
    var sessionId:String = ""
    var userSid:String = ""
    var nickName:String = ""
    var avatarUrl:String = ""
    var isOnline:Bool = false
    var role:Int = 0
    var desc:String = ""
    var stars:Int = 0
    
    class func fromDict(_ data:[String:Any]?)-> UserInfo? {
        guard let d = data else {
            print("userInfo data is nil")
            return nil
        }
        if let _ = d["uid"] {
            let userInfo = UserInfo()
            userInfo.userSid = d["uid"] as! String
            userInfo.nickName = d["nickname"] as! String
            userInfo.avatarUrl = d["avatar"] as! String
            userInfo.isOnline = d["online"] as! Bool
            if let desc = d["desc"] as? String {
                userInfo.desc = desc
            }
            if let roleId = d["roleId"] as? Int {
                userInfo.role = roleId
            }
            if let starts = d["stars"] as? Int {
                userInfo.stars = starts
            }
            return userInfo
        }

        return nil
    }
    
    func toDict() -> Dictionary<String,Any> {
        var dict:Dictionary<String,Any> = Dictionary()
        dict["uid"] = self.userSid
        dict["nickname"] = self.nickName
        dict["avatar"] = self.avatarUrl
        dict["roleId"] = self.role
        dict["desc"] = self.desc
        dict["stars"] = self.stars
        return dict
    }
    
    func addStars(count:Int) {
        self.stars += count
    }
    
    class func fromNetworkSessionInfoDict(_ data:[String:Any]?)-> UserInfo? {
        guard let d = data else {
            print("userInfo data is nil")
            return nil
        }
        if let uid = d["uid"] as? String {
            let userInfo = UserInfo()
            userInfo.userSid = uid
            return userInfo
        } else {
            print("fromNetworkSessionInfoDict  uid not found")
            return nil
        }
    }
}
