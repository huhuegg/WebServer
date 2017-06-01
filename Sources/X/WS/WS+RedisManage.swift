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
    
    func redisUpdateUserInfo(userInfo:UserInfo, callback:@escaping (_ isSuccess:Bool)->()) {
        RedisService.instance.getClient { (_, client) in
            guard let c = client else {
                callback(false)
                return
            }
            
            let key = self.redisUserInfoKey(userInfo.userSid)
            let fields = ["sessionId","userSid","nickName","avatarUrl","isOnline","role","desc"]
            
            let sessionId = RedisClient.RedisValue.string(userInfo.sessionId)
            let userSid = RedisClient.RedisValue.string(userInfo.userSid)
            let nickName = RedisClient.RedisValue.string(userInfo.nickName)
            let avatarUrl = RedisClient.RedisValue.string(userInfo.avatarUrl)
            let isOnline = RedisClient.RedisValue.string(userInfo.isOnline ? "1":"0")
            let role = RedisClient.RedisValue.string("\(userInfo.role)")
            let desc = RedisClient.RedisValue.string(userInfo.desc)
            
            let values = [sessionId,userSid,nickName,avatarUrl,isOnline,role,desc]
            
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
    
    //User Room Info
    func redisIsUserRoomExisted(_ userSid:String, callback:@escaping (_ roomSid:String?)->()) {
        RedisService.instance.getClient { (_, client) in
            guard let c = client else {
                callback(nil)
                return
            }
            c.get(key: self.redisUserRoomKey(userSid), callback: { (resp) in
                guard case .bulkString = resp else {
                    callback(nil)
                    return
                }
                guard let roomSid = resp.toString() else {
                    callback(nil)
                    return
                }
                
                self.redisIsRoomExisted(roomSid, callback: { (isRoomExisted) in
                    if !isRoomExisted { //用户对应的roomSid存在，但是room列表中不存在
                        self.redisRemoveUserRoomSid(userSid, callback: { (_) in
                        })
                        callback(nil)
                    } else {
                        callback(roomSid)
                    }
                })
                
            })
        }
    }
    
    func redisSetUserRoomSid(_ userSid:String, roomSid:String, callback:@escaping (_ status:Bool)->()) {
        RedisService.instance.getClient { (_, client) in
            guard let c = client else {
                callback(false)
                return
            }
            
            c.set(key: self.redisUserRoomKey(userSid), value: RedisClient.RedisValue.string(roomSid), callback: { (resp) in
                switch resp {
                case let .simpleString(s):
                    //print("resp: \(s)")
                    if s == "OK" {
                        callback(true)
                    } else {
                        callback(false)
                    }
                    break
                default:
                    callback(false)
                    break
                }
            })
            
            
        }
    }
    
    func redisRemoveUserRoomSid(_ userSid:String, callback:@escaping (_ status:Bool)->()) {
        RedisService.instance.getClient { (_, client) in
            guard let c = client else {
                callback(false)
                return
            }
            
            c.delete(keys: self.redisUserRoomKey(userSid), callback: { (resp) in
                callback(true)
            })
        }
    }

    //Room User Info
    func redisIsRoomExisted(_ roomSid:String, callback:@escaping (_ status:Bool)->()) {
        RedisService.instance.getClient { (_, client) in
            guard let c = client else {
                callback(false)
                return
            }
            
            c.exists(keys: self.redisRoomKey(roomSid), callback: { (resp) in
                guard case .array(let array) = resp else {
                    client?.delete(keys: self.redisRoomKey(roomSid), callback: { (resp) in
                    })
                    callback(false)
                    return
                }
                if array.count == 0 {
                    callback(false)
                } else {
                    callback(true)
                }
            })
        }
    }
    
    func redisCreateRoomAndAddUser(_ roomSid:String, userSid:String, callback:@escaping (_ status:Bool)->()) {
        RedisService.instance.getClient(callback: { (_, client) in
            guard let _ = client else {
                callback(false)
                return
            }
            
            self.redisIsRoomExisted(roomSid, callback: { (roomExisted) in
                if !roomExisted {
                    client?.listAppend(key: self.redisRoomKey(roomSid), values: [RedisClient.RedisValue.string(userSid)], callback: { (resp) in
                        callback(true)
                    })
                } else {
                    self.printLog("room:\(roomSid) already existed! can't createRoom again!")
                    callback(false)
                }
            })
            
        })
    }
    
    func redisDestroyRoom(_ roomSid:String, callback:@escaping (_ status:Bool)->()) {
        RedisService.instance.getClient { (_, client) in
            guard let c = client else {
                callback(false)
                return
            }
            
            c.delete(keys: self.redisRoomKey(roomSid), callback: { (resp) in
                callback(true)
            })
        }
    }
    
    func redisIsRoomUserExisted(_ roomSid:String, userSid:String, callback:@escaping (_ idx:Int?)->()) {
        RedisService.instance.getClient { (_, client) in
            guard let c = client else {
                callback(nil)
                return
            }
            
            c.listRange(key: self.redisRoomKey(roomSid), start: 0, stop: -1, callback: { (resp) in
                guard case .array(let array) = resp else {
                    callback(nil)
                    return
                }
                for (idx,_) in array.enumerated() {
                    if array[idx].toString() == userSid {
                        callback(idx)
                        return
                    }
                }
            })
        }
    }
    
    func redisAddUserToRoom(_ roomSid:String, userSid:String,callback:@escaping (_ addStatus:Bool)->()) {
        RedisService.instance.getClient { (_, client) in
            guard let c = client else {
                callback(false)
                return
            }
            
            self.redisRemoveUserFromRoom(roomSid, userSid: userSid, callback: { (removeStatus) in
                c.listPrepend(key: self.redisRoomKey(roomSid), values: [RedisClient.RedisValue.string(userSid)], callback: { (resp) in
                    callback(true)
                })
            })
        }
    }
    
    func redisRemoveUserFromRoom(_ roomSid:String, userSid:String, callback:@escaping (_ status:Bool)->()) {
        RedisService.instance.getClient { (_, client) in
            guard let c = client else {
                callback(false)
                return
            }
            
            c.listRemoveMatching(key: self.redisRoomKey(roomSid), value: RedisClient.RedisValue.string(userSid), count: 0, callback: { (resp) in
                callback(true)
            })
        }
    }
}

extension WS {
    fileprivate func redisUserInfoKey(_ userSid:String) -> String {
        return "Hash_UserInfo_" + userSid
    }
    
    fileprivate func redisUserRoomKey(_ userSid:String) -> String {
        return "String_Room_For_User_" + userSid
    }
    
    fileprivate func redisRoomKey(_ roomSid:String) -> String {
        return "List_Room_" + roomSid
    }
}
