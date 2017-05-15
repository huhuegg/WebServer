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
        case .reqDeviceAdmin:
            reqDeviceAdmin(socket,  cmd:command, data: data)
        case . reqUserAnswerQuestion:
            reqUserAnswerQuestion(socket,  cmd:command, data: data)
        case .reqUserStatusChange:
            reqUserStatusChange(socket,  cmd:command, data: data)
        case .reqCoursewareOpen:
            reqCoursewareOpen(socket,  cmd:command, data: data)
        case .reqCoursewareClose:
            reqCoursewareClose(socket,  cmd:command, data: data)
        case .reqCoursewareSizeChange:
            reqCoursewareSizeChange(socket,  cmd:command, data: data)
        case .reqMessagewSend:
            reqMessagewSend(socket,  cmd:command, data: data)
        case .reqQuestionCreate:
            reqQuestionCreate(socket,  cmd:command, data: data)
        case .reqSpecifyStudentAnswerQuestion:
            reqSpecifyStudentAnswerQuestion(socket,  cmd:command, data: data)
        case .reqAnswerCheck:
            reqAnswerCheck(socket,  cmd:command, data: data)
        case .reqAnswerSubmit:
            reqAnswerSubmit(socket,  cmd:command, data: data)
        case .reqCreditChange:
            reqCreditChange(socket,  cmd:command, data: data)
        case .reqPlayMediaSynchronously:
            reqPlayMediaSynchronously(socket,  cmd:command, data: data)
        case .reqMediaReady:
            reqMediaReady(socket,  cmd:command, data: data)
        case .reqMediaControl:
            reqMediaControl(socket,  cmd:command, data: data)
        case .reqMediaControlStatus:
            reqMediaControlStatus(socket,  cmd:command, data: data)
        case .reqDocumentOpenClose:
            reqDocumentOpenClose(socket,  cmd:command, data: data)
        case .reqDocumentOpenCloseStatus:
            reqDocumentOpenCloseStatus(socket, cmd: command, data: data)
        case .reqDocumentControl:
            reqDocumentControl(socket,  cmd:command, data: data)
        case .reqDocumentControlStatus:
            reqDocumentControlStatus(socket,  cmd:command, data: data)
        case .reqRoomJoin:
            reqRoomJoin(socket, cmd: command, data: data)
        case .reqRoomLeave:
            reqRoomLeave(socket, cmd: command, data: data)
        case .reqRoomStart:
            reqRoomStart(socket, cmd: command, data: data)
        case .reqRoomEnd:
            reqRoomEnd(socket, cmd: command, data: data)
        default:
            print("command:\(command) error")
        }

    }
    
    
    private func reqDeviceAdmin(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqUserAnswerQuestion(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqUserStatusChange(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
        guard let userInfo = UserInfo.fromDict(data) else {
            sendMsg(socket, command: respCmd!, code: false, msg: "", data: nil)
            return
        }
        updateUserInfo(socket, userInfo: userInfo)
        sendMsg(socket, command: respCmd!, code: true, msg: "", data: nil)
        //TODO: boardcast to room users

    }
    
    private func reqCoursewareOpen(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqCoursewareClose(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqCoursewareSizeChange(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqMessagewSend(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqQuestionCreate(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqSpecifyStudentAnswerQuestion(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqAnswerCheck(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqAnswerSubmit(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqCreditChange(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqPlayMediaSynchronously(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqMediaReady(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqMediaControl(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqMediaControlStatus(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqDocumentOpenClose(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqDocumentOpenCloseStatus(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqDocumentControl(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqDocumentControlStatus(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
    
    private func reqRoomJoin(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
        guard let roomSid = data?["roomId"] as? String, let roleId = data?["roleId"] as? Int else {
            printLog("data error! data:\(data)")
            return
        }
        let code = joinRoom(socket, roomSid: roomSid, roleId: roleId)
        var respData:[String:Any] = [:]
        respData["roomId"] = roomSid
        sendMsg(socket, command: respCmd!, code: code, msg: "", data: respData)
        if let userList = roomUsers(socket, roomSid: roomSid) as? [UserInfo] {
            for u in userList {
                if let userSocket = userSocket(u.userSid) {
                    var pushData:[String:Any] = [:]
                    pushData["roomId"] = roomSid
                    pushData["uid"] = socketUserSid(socket)
                    pushData["roleId"] = roleId
                    sendMsg(userSocket, command: pushCmd!, code: true, msg: "", data: pushData)
                }
            }
        }
    }
    
    private func reqRoomLeave(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
        guard let roomSid = data?["roomId"] as? String else {
            printLog("data error! data:\(data)")
            return
        }
        let status = leaveRoom(socket, roomSid: roomSid)
    }
    
    private func reqRoomStart(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }

    
    private func reqRoomEnd(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        let respCmd = commandFor(cmd, isResp: true)
        let pushCmd = commandFor(cmd, isResp: false)
    }
}

extension WS {
    fileprivate func sendMsg(_ socket: WebSocket, command:WebSocketCommand, code:Bool, msg:String, data:[String:Any]?) {
        var dict:[String:Any] = [:]
        dict[kWebsocketCommandName] = command.rawValue
        dict[kWebsocketCodeName] = 1
        dict[kWebsocketMsgName] = msg
        dict[kWebsocketDataName] = data
        do {
            let message = try dict.jsonEncodedString()
            print("--->Client#(\(command)) \(message)")
            socket.sendStringMessage(string: message, final: true) {
                
                // This callback is called once the message has been sent.
                // Recurse to read and echo new message.
                guard let clientInfo = self.clientInfo(socket) else {
                    print("socket clientInfo not found")
                    return
                }
                
                guard let handler = clientInfo.handler, let request = clientInfo.request else {
                    print("clientInfo error! handler:\(clientInfo.handler) request:\(clientInfo.request)")
                    return
                }
                //self.printLog("handler.handleSession command:\(command)")
                handler.handleSession(request: request, socket: socket)
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
        case .reqDeviceAdmin:
            if isResp {
                return .respDeviceAdmin
            }
            return .pushDeviceAdmin
        case . reqUserAnswerQuestion:
            if isResp {
                return .respUserAnswerQuestion
            }
            return .pushUserAnswerQuestion
        case .reqUserStatusChange:
            if isResp {
                return .respUserStatusChange
            }
            return .pushUserStatusChange
        case .reqCoursewareOpen:
            if isResp {
                return .respCoursewareOpen
            }
            return .pushCoursewareOpen
        case .reqCoursewareClose:
            if isResp {
                return .respCoursewareClose
            }
            return .pushCoursewareClose
        case .reqCoursewareSizeChange:
            if isResp {
                return .respCoursewareSizeChange
            }
            return .pushCoursewareSizeChange
        case .reqMessagewSend:
            if isResp {
                return .respMessageSend
            }
            return .pushMessageSend
        case .reqQuestionCreate:
            if isResp {
                return .respQuestionCreate
            }
            return .pushQuestionCreate
        case .reqSpecifyStudentAnswerQuestion:
            if isResp {
                return .respSpecifyStudentAnswerQuestion
            }
            return .pushSpecifyStudentAnswerQuestion
        case .reqAnswerCheck:
            if isResp {
                return .respAnswerCheck
            }
            return .pushAnswerCheck
        case .reqAnswerSubmit:
            if isResp {
                return .respAnswerSubmit
            }
            return .pushAnswerSubmit
        case .reqCreditChange:
            if isResp {
                return .respCreditChange
            }
            return .pushCreditChange
        case .reqPlayMediaSynchronously:
            if isResp {
                return .respPlayMediaSynchronously
            }
            return .pushPlayMediaSynchronously
        case .reqMediaReady:
            if isResp {
                return .respMediaReady
            }
            return .pushMediaReady
        case .reqMediaControl:
            if isResp {
                return .respMediaControl
            }
            return .pushMediaControl
        case .reqMediaControlStatus:
            if isResp {
                return .respMediaControlStatus
            }
            return .pushMediaControlStatus
        case .reqDocumentOpenClose:
            if isResp {
                return .respDocumentOpenClose
            }
            return .pushDocumentOpenClose
        case .reqDocumentOpenCloseStatus:
            if isResp {
                return .respDocumentOpenCloseStatus
            }
            return .pushDocumentOpenCloseStatus
        case .reqDocumentControl:
            if isResp {
                return .respDocumentControl
            }
            return .pushDocumentControl
        case .reqDocumentControlStatus:
            if isResp {
                return .respDocumentControlStatus
            }
            return .pushDocumentControlStatus
        case .reqRoomJoin:
            if isResp {
                return .respRoomJoin
            }
            return .pushRoomJoin
        case .reqRoomLeave:
            if isResp {
                return .respRoomLeave
            }
            return .pushRoomLeave
        case .reqRoomStart:
            if isResp {
                return .respRoomStart
            }
            return .pushRoomStart
        case .reqRoomEnd:
            if isResp {
                return .respRoomEnd
            }
            return .pushRoomEnd
        default:
            return nil
        }
    }

}
