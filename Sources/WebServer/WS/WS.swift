//
//  WS.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/5.
//
//


import PerfectWebSockets
import PerfectThread
import PerfectLib
import Jobs

class WS {
    static var ws = WS()
    
    static var instance:WS {
        return ws
    }
    
    init() {
        check()
    }
    
    func check() {
        Jobs.add(interval: .seconds(3)) {
            self.printLog("~~~ checkRoomUsers ~~~")
            self.checkRoomUsers()
        }
    }
    
    var clients:Dictionary<Int,ClientInfo> = Dictionary()
    var rooms:Dictionary<String,Room> = Dictionary()
    var userInRoom:Dictionary<String,String> = Dictionary()
    var roomLogger:Dictionary<String,File> = Dictionary()
    var needRemoveFromRoomUserInfo:Dictionary<String,Int> = Dictionary()
    
    let q = Threading.getQueue(name: "#WebSocket Thread#", type: Threading.QueueType.serial)
    
    func printLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
        
        print("\(file.lastFilePathComponent)[\(line)], \(method): \(message)")
    }
    
}

