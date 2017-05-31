//
//  WS+RedisManage.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/31.
//
//

import PerfectRedis

extension WS {
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
    
    fileprivate func redisUserRoomKey(_ userSid:String) -> String {
        return "String_Room_For_User_" + userSid
    }
    
    fileprivate func redisRoomKey(_ roomSid:String) -> String {
        return "List_Room_" + roomSid
    }
}
