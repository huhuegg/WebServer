//
//  ClientInfo.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/15.
//
//

import PerfectWebSockets
import PerfectHTTP

class ClientInfo {
    var handler:WebSocketSessionHandler?
    var request:HTTPRequest?
    var socket:WebSocket?
    var userInfo:UserInfo?
}
