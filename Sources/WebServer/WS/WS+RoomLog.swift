//
//  WS+RoomLog.swift
//  WebServer
//
//  Created by huhuegg on 2017/10/24.
//

import Foundation
import PerfectLib

enum WSMsgType:String {
    case req = "req"
    case resp = "resp"
    case push = "push"
}

extension WS {
    func startLogger(roomId:String)->Bool {
        let logDir = "~/webroot/downloads"
        let filePath = logDir + "/" + roomId
        let f:File = File(filePath)
        do {
            try f.open(.write, permissions: .rwUserGroup)
            roomLogger[roomId] = f
            let currectTimeInterval = Date().timeIntervalSince1970
            //let msg = String(currectTimeInterval) + "\n"
            //try f.write(string: msg)
            return true
        } catch {
            return false
        }
    }
    
    func stopLogger(roomId:String)->Bool {
        if let file = roomLogger[roomId] {
            usleep(1000 * 5000) //5s
            file.close()
            roomLogger.removeValue(forKey: roomId)
            return true
        }
        return false
    }
    
    func log(roomSid:String, wsMsgType: WSMsgType, from:String, to:Array<String>, recv: String) {
        let currectTimeInterval = Date().timeIntervalSince1970

        if let status = self.isRoomLogStarted[roomSid] {
            if status == true {
                var dict:[String:Any] = Dictionary()
                dict["type"] = wsMsgType.rawValue
                dict["from"] = from
                dict["to"] = to
                dict["data"] = recv
                do {
                    if let file = roomLogger[roomSid] {
                        let s = try dict.jsonEncodedString()
                        let msg = String(currectTimeInterval) + s + "\n"
                        try file.write(string: msg)
                    } else {
                        self.printLog("记录日志失败")
                    }
                } catch {
                    self.printLog("log encodeJsonString failed")
                }
            } else {
                self.printLog("未开始上课，忽略")
            }
        }
        
        
        
    }

}
