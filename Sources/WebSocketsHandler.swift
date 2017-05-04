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

class WebSocketsHandler: WebSocketSessionHandler {
    // The name of the super-protocol we implement.
    // This is optional, but it should match whatever the client-side WebSocket is initialized with.
    let socketProtocol: String? = "X"
    
    // This function is called by the WebSocketHandler once the connection has been established.
    func handleSession(request: HTTPRequest, socket: WebSocket) {
        
        // Read a message from the client as a String.
        // Alternatively we could call `WebSocket.readBytesMessage` to get binary data from the client.
        socket.readStringMessage {
            // This callback is provided:
            //	the received data
            //	the message's op-code
            //	a boolean indicating if the message is complete (as opposed to fragmented)
            string, op, fin in
            
            // The data parameter might be nil here if either a timeout or a network error, such as the client disconnecting, occurred.
            // By default there is no timeout.
            guard let string = string else {
                // This block will be executed if, for example, the browser window is closed.
                socket.close()
                return
            }
            
            // Print some information to the console for informational purposes.
            print("Read msg: \(string) op: \(op) fin: \(fin)")
            
            // Echo the data we received back to the client.
            // Pass true for final. This will usually be the case, but WebSockets has the concept of fragmented messages.
            // For example, if one were streaming a large file such as a video, one would pass false for final.
            // This indicates to the receiver that there is more data to come in subsequent messages but that all the data is part of the same logical message.
            // In such a scenario one would pass true for final only on the last bit of the video.
            socket.sendStringMessage(string: "[S->C]" + string, final: true) {
                
                // This callback is called once the message has been sent.
                // Recurse to read and echo new message.
                self.handleSession(request: request, socket: socket)
            }
        }
    }
}
