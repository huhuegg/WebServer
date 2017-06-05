//
//  WebSocketClients+ProcessMessage.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/15.
//
//

import PerfectWebSockets
import PerfectThread
import PerfectHTTP

extension WS {
    func processRequestMessage(_ socket: WebSocket, command:WebSocketCommand, data:[String:Any]?) {
        switch command {
        case .reqOnline:
            break
            
        case .reqOffline:
            break
        default:
            print("command:\(command) error")
        }

    }
    
    private func reqOnline(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true) else {
            printLog("reqCmd:\(cmd.rawValue) resp command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["sessionId":.string, "uid":.string, "nickname":.string, "avatar":.string, "online":.bool])

        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        
        guard let userInfo = UserInfo.fromDict(data) else {
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let deviceToken:String? = data?["deviceToken"] as? String
        updateUserInfo(socket, userInfo: userInfo, deviceToken: deviceToken) { (isSuccess) in
            self.sendMsg(socket, command: respCmd, code: isSuccess, msg: "", data: data)
        }
        
    }

}

extension WS {    
    fileprivate func sendMsgToUser(_ userSid:String, command:WebSocketCommand, data:[String:Any]?, callback:@escaping (_ isSuccess:Bool)->()) {
        self.userOwnerSocket(userSid, callback: { (userSocket) in
            if let _ = userSocket {
                self.sendMsg(userSocket!, command: command, code: true, msg: "", data: data)
                callback(true)
            } else {
                callback(false)
            }
        })
    }

    fileprivate func sendMsg(_ socket: WebSocket, command:WebSocketCommand, code:Bool, msg:String, data:[String:Any]?) {
        var dict:[String:Any] = [:]
        dict[kWebsocketCommandName] = command.rawValue
        dict[kWebsocketCodeName] = code ? 0:1
        dict[kWebsocketMsgName] = msg
        dict[kWebsocketDataName] = data
        do {
            let message = try dict.jsonEncodedString()
            print("--->Client(\(self.socketMemoryAddress(socket)))#(\(command)) \(message)")
            socket.sendStringMessage(string: message, final: true) {
                
                // This callback is called once the message has been sent.
                // Recurse to read and echo new message.
                
                self.clientInfo(socket, callback: { (clientInfo) in
                    if let c = clientInfo {
                        if let handler = c.handler, let request = c.request {
                            //self.printLog("handler.handleSession command:\(command)")
                            handler.handleSession(request: request, socket: socket)
                        } else {
                            print("clientInfo error!")
                        }
                    } else {
                        print("socket clientInfo not found")
                    }
                })
            }
        } catch  {
            print("dict.jsonEncodedString failed")
        }
        
    }
    
    fileprivate func processMessage(command:WebSocketCommand, data:[String:Any]?) -> [String] {
        return []
    }
    
    fileprivate func commandFor(_ reqCmd:WebSocketCommand, isResp:Bool) -> WebSocketCommand? {
        switch reqCmd {
        case .reqOnline:
            if isResp {
                return .respOnline
            }
            break
        case . reqOffline:
            if isResp {
                return .respOffline
            }
            break
        default:
            break
        }
        return nil
    }

}
