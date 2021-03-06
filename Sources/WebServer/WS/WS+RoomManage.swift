//
//  WS+MessageManage.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/15.
//
//

import PerfectWebSockets
import PerfectThread
import PerfectHTTP
import Foundation

extension WS {
    func loadFromRedis() {
        
    }
    
    func findRoomIfExist(_ roomSid:String, callback:@escaping (_ room:Room?)->()) {
        q.dispatch {
            if let room = self.rooms[roomSid] {
                callback(room)
            } else {
                callback(nil)
            }
        }
    }
    
    func joinRoom(_ socket:WebSocket, roomSid:String, roleId:Int, callback:@escaping (_ room:Room?)->()) {
        isClientExist(socket) { (clientInfo) in
            if let u = clientInfo?.userInfo {
                self.q.dispatch {
                    self.userInRoom[u.userSid] = roomSid
                    self.findRoomIfExist(roomSid, callback: { (room) in
                        self.q.dispatch {
                            if let existRoom = room {
                                var isUserInRoom:Bool = false
                                for (idx,_) in existRoom.userList.enumerated() {
                                    if existRoom.userList[idx].userSid == u.userSid {
                                        existRoom.userList[idx].role = roleId
                                        isUserInRoom = true
                                        self.printLog("updateUser:\(u.userSid) role:\(roleId) in room:\(roomSid)")
                                        break
                                    }
                                }
                                
                                if !isUserInRoom {
                                    let userInfo = u
                                    userInfo.role = roleId
                                    self.printLog("addUser:\(userInfo.userSid) role:\(roleId) into Room:\(roomSid)")
                                    existRoom.userList.append(userInfo)
                                    self.redisSetUserRoomSid(userInfo.userSid, roomSid: roomSid, callback: { (setUserRoomStatus) in
                                    })
                                    self.redisAddUserToRoom(roomSid, userSid: userInfo.userSid, callback: { (addUserStatus) in
                                        
                                    })
                                }
                                callback(existRoom)
                                
                            } else {
                                self.q.dispatch {
                                    let newRoom = Room()
                                    newRoom.sid = roomSid
                                    let userInfo = u
                                    userInfo.role = roleId
                                    newRoom.userList.append(userInfo)
                                    self.rooms[roomSid] = newRoom
                                    
                                    let status = self.startLogger(roomId: roomSid)
                                    self.isRoomLogStarted[roomSid] = false
                                    self.printLog("创建room:\(roomSid)的日志文件, status:\(status.description)")
                                    
                                    callback(newRoom)
                                    self.printLog("create new room:\(roomSid) with user:\(userInfo.userSid)")
                                    self.printLog("after createRoom, rooms count:\(self.rooms.keys.count)")
                                    self.redisCreateRoomAndAddUser(roomSid, userSid: userInfo.userSid, callback: { (status) in
                                        self.printLog("redisCreateRoom \(status)")
                                    })
                                    self.redisSetUserRoomSid(userInfo.userSid, roomSid: roomSid, callback: { (setUserRoomStatus) in
                                    })
                                    
                                }
                            }

                        }
                    })
                }
            } else {
                callback(nil)
            }
        }
    }
    
    func leaveRoom(_ socket:WebSocket, roomSid:String, callback:@escaping (_ isSuccess:Bool)->()) {
        isClientExist(socket) { (clientInfo) in
            if let c = clientInfo {
                if let u = c.userInfo {
                    self.removeUserFormRoomIfExist(roomSid, userSid: u.userSid) { (isSuccess) in
                        if isSuccess {
                            self.q.dispatch {
                                if let _ = self.userInRoom.removeValue(forKey: u.userSid) {
                                    self.printLog("remove user:\(u.userSid) from room:\(roomSid) success!")
                                    callback(true)
                                } else {
                                    callback(false)
                                }
                                self.redisRemoveUserFromRoom(roomSid, userSid: u.userSid, callback: { (status) in
                                    self.printLog("redisRemoveUser \(status)")
                                })
                                self.redisRemoveUserRoomSid(u.userSid, callback: { (removeUserRoomSidStatus) in
                                    
                                })
                            }
                        } else {
                            self.printLog("removeUserFromRoom failed")
                            callback(false)
                        }
                    }
                } else {
                    callback(false)
                }
            } else {
                callback(false)
            }
        }

    }

    func userRoom(_ userSid:String, callback:@escaping (_ room:Room?)->()) {
        q.dispatch {
            if let roomSid = self.userInRoom[userSid] {
                if let room = self.rooms[roomSid] {
                    callback(room)
                } else {
                    self.printLog("user:\(userSid) is not in any room")
                    callback(nil)
                }
            } else {
                self.printLog("user:\(userSid) is not in any room")
                callback(nil)
            }
        }
    }
    
    func roomUsers(_ socket:WebSocket, roomSid:String, callback:@escaping (_ users:[UserInfo])->()) {
        findRoomIfExist(roomSid) { (room) in
            if let room = room {
                callback(room.userList)
            } else {
                callback([])
            }
        }
    }

    func roomOtherUsers(_ socket:WebSocket, roomSid:String, callback:@escaping (_ users:[UserInfo])->()) {
        roomUsers(socket, roomSid: roomSid) { (users) in
            var userArr = users
            for u in users {
                if u.userSid != u.userSid {
                    userArr.append(u)
                }
            }
            callback(userArr)
        }

    }
    
    func checkRoomUsers() {
        //检查所有房间中的用户连接状态
        for roomSid in rooms.keys {
            if let room = rooms[roomSid] {
                printLog("check room:\(roomSid)")
                //TODO:-超过预定课程结束时间并且房间已经没有人则销毁房间
                if let course = CourseManager.shared.findCourseWithStatus(courseId: roomSid, status:.ing) {
                    let endTime:Int = Int(course.starttime) + course.duration * 60
                    let currectTime:Int = Int(Date().timeIntervalSince1970)
                    self.printLog("[ing] roomSid:\(roomSid) currentTime:\(currectTime) endTime:\(endTime) roomUsers:\(room.userList.count)")
                    if currectTime >= endTime { //超过预定课程结束时间
                        if room.userList.count == 0 { //房间已经没有人
                            course.status = .end
                            //将课程标记为已结束
                            CourseManager.shared.changeStatus(course: course)
                            //销毁房间
                            self.destroyRoom(roomSid, callback: { (isSuccess) in
                            })
                            self.printLog("[ing] roomSid:\(roomSid) destroy room and end.")
                            continue
                        }
                    }
                }
                
                
                for u in room.userList {
                    let userSid = u.userSid
                    
                    self.userOwnerSocket(userSid, callback: { (socket) in
                        if socket == nil {
                            self.printLog("check room:\(roomSid) userSid:\(userSid) failed")
                            //添加检测统计计数
                            if let _ = self.needRemoveFromRoomUserInfo[userSid] {
                                self.needRemoveFromRoomUserInfo[userSid]! += 1
                            } else {
                                self.needRemoveFromRoomUserInfo[userSid] = 1
                            }
                        } else {
                            self.printLog("check room:\(roomSid) userSid:\(userSid) ok")
                        }
                    })
                }
            }
        }
        
        for userSid in self.needRemoveFromRoomUserInfo.keys {
            if let count = self.needRemoveFromRoomUserInfo[userSid] {
                //移除错误超过3次的用户
                if count > 3 {
                    userRoom(userSid, callback: { (room) in
                        if let room = room {
                            self.removeUserFormRoomIfExist(room.sid, userSid: userSid, callback: { (status) in
                                self.printLog("#Check# remove user:\(userSid) from room:\(room.sid)")
                                var data:Dictionary<String,Any> = Dictionary()

                                data["courseId"] = room.sid
                                data["uid"] = userSid

                                for u in room.userList {
                                    let command = WebSocketCommand.pushRoomLeave
                                    self.sendMsgToUser(u.userSid, command: command, data: data, callback: { (isSuccess) in
                                        self.printLog("sendMsgToUser:\(u.userSid) command:\(command.rawValue) status:\(isSuccess)")
                                    })
                                }
                            })
                        }
                    })
                    self.needRemoveFromRoomUserInfo.removeValue(forKey: userSid)
                }
            }
        }
        
    }
}

extension WS {
    
    
    fileprivate func removeUserFormRoomIfExist(_ roomSid:String, userSid:String, callback:@escaping (_ isSuccess:Bool) -> ()) {
        findRoomIfExist(roomSid) { (room) in
            if let room = room {
                var userIndex:Int = -1
                for (idx,value) in room.userList.enumerated() {
                    if value.userSid == userSid {
                        userIndex = idx
                        break
                    }
                }
                if (userIndex >= 0) {
                    self.q.dispatch {
                        self.printLog("remove user:\(userSid) from room:\(roomSid)")
                        room.userList.remove(at: userIndex)
                        
                        callback(true)
                    }
                } else {
                    self.printLog("can't find user:\(userSid) in room:\(roomSid), removeUser failed!")
                    callback(false)
                }
            } else {
                self.printLog("room not existed!")
                callback(false)
            }
        }

    }

    private func destroyRoom(_ roomSid:String, callback:@escaping (_ isSuccess:Bool) -> ()) {
        printLog("destroyRoom:\(roomSid)")
        q.dispatch {
            RedisService.instance.getClient(callback: { (_, client) in
                let key = "Room_" + roomSid
                client?.delete(keys: key, callback: { (resp) in

                })
            })
            
            if let _ = self.rooms.removeValue(forKey: roomSid) {
                callback(true)
            } else {
                callback(false)
            }
            self.printLog("after destroyRoom, rooms count:\(self.rooms.keys.count)")
        }
    }
}
