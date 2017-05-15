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


extension WS {
    func joinRoom(_ socket:WebSocket, roomSid:String, roleId:Int)->Bool {
        guard isClientExist(socket) else {
            printLog("socket is not existed!")
            return false
        }
        guard let clientInfo = clientInfo(socket) else {
            printLog("socket client info not existed!")
            return false
        }
        
        guard let userInfo = clientInfo.userInfo else {
            printLog("clientInfo.userInfo is nil")
            return false
        }
        if let existRoom = findRoomIfExist(roomSid) {
            var isUserInRoom = false
            for u in existRoom.userList {
                if u.userSid == userInfo.userSid {
                    userInfo.role = roleId
                    isUserInRoom = true
                    self.printLog("updateUser:\(userInfo.userSid) role:\(roleId) in room:\(roomSid)")
                }
            }
            if !isUserInRoom {
                userInfo.role = roleId
                q.dispatch {
                    self.printLog("addUser:\(userInfo.userSid) role:\(roleId) into Room:\(roomSid)")
                    existRoom.userList.append(userInfo)
                }
            }
            
        } else {
            let newRoom = Room()
            newRoom.sid = roomSid
            newRoom.userList.append(userInfo)
            q.dispatch {
                self.rooms[roomSid] = newRoom
                self.printLog("create new room:\(roomSid) with user:\(userInfo.userSid)")
            }
        }
        return true
    }
    
    func leaveRoom(_ socket:WebSocket, roomSid:String)->Bool {
        guard isClientExist(socket) else {
            printLog("socket is not existed!")
            return false
        }
        guard let clientInfo = clientInfo(socket) else {
            printLog("socket client info not existed!")
            return false
        }
        guard let userInfo = clientInfo.userInfo else {
            printLog("clientInfo.userInfo is nil")
            return false
        }

        guard removeUserFormRoomIfExist(roomSid, userSid: userInfo.userSid) else {
            printLog("removeUserFromRoom failed")
            return false
        }
        return true
    }

    func roomUsers(_ socket:WebSocket, roomSid:String)-> [UserInfo] {
        if let room = findRoomIfExist(roomSid) {
            return room.userList
        }
        return []
    }
    
}

extension WS {
    fileprivate func findRoomIfExist(_ roomSid:String) ->Room? {
        guard let room = self.rooms[roomSid] else {
            return nil
        }
        return room
    }
    
    fileprivate func removeUserFormRoomIfExist(_ roomSid:String, userSid:String)->Bool {
        guard let room = findRoomIfExist(roomSid) else {
            printLog("room not existed!")
            return false
        }
        
        var userIndex:Int = -1
        for (idx,value) in room.userList.enumerated() {
            if value.userSid == userSid {
                userIndex = idx
                break
            }
        }
        if (userIndex > 0) {
            q.dispatch {
                self.printLog("remove user:\(userSid) from room:\(roomSid)")
                room.userList.remove(at: userIndex)
            }
            return true
        } else {
            printLog("can't find user:\(userSid) in room:\(roomSid), removeUser failed!")
            return false
        }
        
    }

}
