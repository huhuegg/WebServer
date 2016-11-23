//
//  DownloadHandler.swift
//  WebServer
//
//  Created by admin on 2016/11/23.
//
//

import PerfectHTTP
import PerfectLib

class DownloadHandler: HttpHandler {
    class func download(request: HTTPRequest, _ response: HTTPResponse) {
        print("🌐  \(#function) uri:\(request.uri)")
        // get the portion of the request path which was matched by the wildcard
        request.path = request.urlVariables[routeTrailingWildcardKey]!
        

        let documentRoot = Dir.workingDir.path + "webroot/" + "uploads/"
        let handler = StaticFileHandler(documentRoot: documentRoot)
        handler.handleRequest(request: request, response: response)
        
    }
}
