//
//  WS+Private.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/15.
//
//

import PerfectWebSockets
import PerfectThread
import PerfectHTTP

extension WS {
    func isClientExist(_ socket:WebSocket) ->Bool {
        let address:Int = socketMemoryAddress(socket)
        if clients[address] == nil {
            return false
        }
        return true
    }
    
    func addClientIfNeed(_ handler:WebSocketSessionHandler, request: HTTPRequest, socket:WebSocket) {
        if !isClientExist(socket) {
            addClient(handler, request:request, socket:socket)
        } else {
            updateClientInfo(handler, request: request, socket:socket)
        }
    }
    
    func removeClient(_ socket:WebSocket) {
        let address:Int = socketMemoryAddress(socket)
        if let clientInfo:Dictionary<String,Any> = clients[address] as? Dictionary<String, Any> {
            print("delClient:\(address) userSid:\(clientInfo["userSid"])")
            q.dispatch {
                self.clients.removeValue(forKey: address)
            }
        }

    }
    
    func clientInfo(_ socket:WebSocket) -> ClientInfo? {
        let address:Int = socketMemoryAddress(socket)
        if clients[address] == nil {
            return nil
            
        }
        return clients[address]
    }
    
    func userSocket(_ userSid:String) -> WebSocket? {
        for address in clients.keys {
            if let userInfo = clients[address]?.userInfo {
                if userInfo.userSid == userSid {
                    return clients[address]?.socket
                }
            }
        }
        return nil
    }
    
    func socketUserSid(_ socket:WebSocket) -> String? {
        return clientInfo(socket)?.userInfo?.userSid
    }
    
    func updateUserInfo(_ socket:WebSocket, userInfo:UserInfo) {
        
        if let clientInfo = clientInfo(socket) {
            q.dispatch {
                clientInfo.userInfo = userInfo
            }
            printLog("updateUserInfo success")
        } else {
            printLog("updateUserInfo failed")
        }
    }
}

extension WS {
    
    
    fileprivate func addClient(_ handler:WebSocketSessionHandler, request: HTTPRequest, socket:WebSocket) {
        let address:Int = socketMemoryAddress(socket)
        var clientInfo = ClientInfo()
        clientInfo.handler = handler
        clientInfo.request = request
        clientInfo.socket = socket
        
        print("addClient:\(address)")
        q.dispatch {
            self.clients[address] = clientInfo
        }
    }
    
    fileprivate func updateClientInfo(_ handler:WebSocketSessionHandler, request: HTTPRequest, socket:WebSocket) {
        if let clientInfo = clientInfo(socket) {
            q.dispatch {
                clientInfo.handler = handler
                clientInfo.request = request
            }
        }
    }
    
    fileprivate func socketMemoryAddress(_ socket:WebSocket) -> Int {
        return unsafeBitCast(socket, to: Int.self)
    }
}
