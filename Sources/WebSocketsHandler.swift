//
//  WebSocketsHandler.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/4.
//
//

import PerfectLib
import PerfectWebSockets
import PerfectHTTP

let kWebsocketCommandName = "cmd"
let kWebsocketDataName = "data"
let kWebsocketCodeName = "code"
let kWebsocketMsgName = "msg"
class WebSocketsHandler: WebSocketSessionHandler {
    //客户端与服务器协议匹配
    let socketProtocol: String? = "X"
    
    // 连接建立后handleSession立即被调用
    func handleSession(request: HTTPRequest, socket: WebSocket) {
        //print(self)
        // 收取二进制消息[UInt8]
        socket.readBytesMessage { (bytes, op, fin) in
            guard let data = bytes else {
                print("socket.close()")
                socket.close()
                return
            }
            print("Read data length: \(data.count) op: \(op) fin: \(fin)")
            
            socket.sendBinaryMessage(bytes: data, final: true, completion: {
                
            });
        }

        // 收取文本消息
        socket.readStringMessage {
            // 数据， 消息操作码， 消息是否完整
            string, op, fin in

            // 当连接超时或网络错误时数据为nil，以此为依据关闭客户端socket
            guard let string = string else {
                print("socket.close()")
                socket.close()
                return
            }
            
            // Print some information to the console for informational purposes.
            //print("Read msg: \(string) op: \(op) fin: \(fin)")
            do {
                if let decoded = try string.jsonDecode() as? [String:AnyObject] {
                    if let command = decoded[kWebsocketCommandName] as? Int, let data = decoded[kWebsocketDataName] as? [String:Any] {
                        guard let cmd = WebSocketCommand(rawValue: command) else {
                            print("command:\(command) no defined")
                            return
                        }
                        print("<---Client# command:\(cmd) data:\(data)")
                        
                        switch cmd {
                        case .reqUserStatusChange:
                            guard let sessionId = data["sessionId"] as? String, let userSid = data["uid"] as? String, let online = data["online"] as? Bool else {
                                print("parms error");
                                return
                            }
                            let respCommand = WebSocketCommand.respUserStatusChange
                            let pushCommand = WebSocketCommand.pushUserStatusChange
                            
                            var d:Dictionary<String,Any> = Dictionary()
                            d["uid"] = userSid
                            d["online"] = 1
                            self.sendMsg(request, socket: socket, command: respCommand, code: true, msg: "resp", data: d)
                            self.sendMsg(request, socket: socket, command: pushCommand, code: true, msg: "push", data: d)
                            break
                        default:
                            break
                        }
                        
                        
//                        if command == WebSocketCommand.reqDeviceAdmin.rawValue {
//                            let respCommand = WebSocketCommand.respDeviceAdmin
//                            let pushCommand = WebSocketCommand.pushDeviceAdmin
//                            
//                            var respData:[String:Any] = [:]
//                            respData["a"]="a"
//                            respData["b"]=1
//                            respData["c"]=false
//                            
//                            self.sendMsg(request, socket: socket, command: respCommand, code: true, msg: "respCommand", data: respData)
//                            self.sendMsg(request, socket: socket, command: pushCommand, code: true, msg: "pushCommand", data: respData)
//                        }
                    } else {
                        print("reqMsg format error: \(string)")
                    }
                }
            } catch {
                print("decodeMsg failed:\(string)")
            }
            
            
            // Echo the data we received back to the client.
            // Pass true for final. This will usually be the case, but WebSockets has the concept of fragmented messages.
            // For example, if one were streaming a large file such as a video, one would pass false for final.
            // This indicates to the receiver that there is more data to come in subsequent messages but that all the data is part of the same logical message.
            // In such a scenario one would pass true for final only on the last bit of the video.
            
        }

    }
    
    func sendMsg(_ request: HTTPRequest, socket: WebSocket, command:WebSocketCommand, code:Bool, msg:String, data:[String:Any]?) {
        var dict:[String:Any] = [:]
        dict[kWebsocketCommandName] = command.rawValue
        dict[kWebsocketCodeName] = 1
        dict[kWebsocketMsgName] = msg
        dict[kWebsocketDataName] = data
        do {
            let message = try dict.jsonEncodedString()
            print("--->Client# \(message)")
            socket.sendStringMessage(string: message, final: true) {
                
                // This callback is called once the message has been sent.
                // Recurse to read and echo new message.
                self.handleSession(request: request, socket: socket)
            }
        } catch  {
            print("dict.jsonEncodedString failed")
        }
        
    }
}
