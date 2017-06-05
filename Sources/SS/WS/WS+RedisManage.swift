//
//  WS+RedisManage.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/31.
//
//

import PerfectRedis

extension WS {
    
    private func respToArray(_ resp:RedisResponse)->Array<String>? {
        guard case .array(let array) = resp else {
            return nil
        }
        var data:Array<String> = Array()
        
        for d in array {
            if let s = d.toString() {
                data.append(s)
            }
        }
        return data
    }
    
    func redisUpdateUserInfo(userInfo:UserInfo, deviceToken:String?, callback:@escaping (_ isSuccess:Bool)->()) {
        RedisService.instance.getClient { (_, client) in
            guard let c = client else {
                callback(false)
                return
            }
            
            let key = self.redisUserInfoKey(userInfo.userSid)
            var fields = ["sessionId","userSid","nickName","avatarUrl","isOnline","role","desc"]
            
            let sessionId = RedisClient.RedisValue.string(userInfo.sessionId)
            let userSid = RedisClient.RedisValue.string(userInfo.userSid)
            let nickName = RedisClient.RedisValue.string(userInfo.nickName)
            let avatarUrl = RedisClient.RedisValue.string(userInfo.avatarUrl)
            let isOnline = RedisClient.RedisValue.string(userInfo.isOnline ? "1":"0")
            let role = RedisClient.RedisValue.string("\(userInfo.role)")
            let desc = RedisClient.RedisValue.string(userInfo.desc)
            
            var values = [sessionId,userSid,nickName,avatarUrl,isOnline,role,desc]
            
            if let token = deviceToken {
                fields.append("deviceToken")
                values.append(RedisClient.RedisValue.string(token))
            }
            
            guard fields.count == values.count else {
                callback(false)
                return
            }
            
            c.hmset(key: key, fields: fields, values: values, callback: { (resp) in
                callback(resp.isSimpleOK)
            })
        }
    }
    
    func redisGetUserInfo(_ userSid:String, callback:@escaping (_ isSuccess:Bool,_ userInfo:UserInfo?)->()) {
        RedisService.instance.getClient { (_, client) in
            guard let c = client else {
                callback(false,nil)
                return
            }
            
            let key = self.redisUserInfoKey(userSid)
            let fields = ["sessionId","userSid","nickName","avatarUrl","isOnline","role","desc"]
            
            c.hmget(key: key, fields: fields, callback: { (resp) in
                guard case .array(let array) = resp else {
                    callback(false, nil)
                    return
                }
                guard array.count == fields.count else {
                    callback(false,nil)
                    return
                }
                
                guard let sessionId = array[0].toString(),let userSid = array[1].toString(),let nickName = array[2].toString(),let avatarUrl = array[3].toString(), let isOnline = array[4].toString(),let role = array[5].toString(),let desc = array[6].toString() else {
                    callback(false,nil)
                    return
                }

                let userInfo = UserInfo()
                userInfo.sessionId = sessionId == "NULL" ? "":sessionId
                userInfo.userSid = userSid == "NULL" ? "":userSid
                userInfo.nickName = nickName == "NULL" ? "":nickName
                userInfo.avatarUrl = avatarUrl == "NULL" ? "":avatarUrl
                userInfo.isOnline = isOnline == "1" ? true:false
                userInfo.role = role == "NULL" ? -1:Int(role)!
                userInfo.desc = desc == "NULL" ? "":desc
                
                callback(resp.isSimpleOK, userInfo)
                
            })
            
        }
    }
    
}

extension WS {
    fileprivate func redisUserInfoKey(_ userSid:String) -> String {
        return "SS_Hash_UserInfo_" + userSid
    }
}
