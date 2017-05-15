//
//  UserInfo.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/15.
//
//

class UserInfo {
    var sessionId:String = ""
    var userSid:String = ""
    var nickName:String = ""
    var avatarUrl:String = ""
    var isOnline:Bool = false
    var role:Int = 0
    
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
            return userInfo
        }
        
        
        return nil
    }
}
