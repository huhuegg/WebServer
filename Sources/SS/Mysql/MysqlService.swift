//
//  MysqlService.swift
//  WebServer
//
//  Created by huhuegg on 2017/6/5.
//
//

import PerfectLib
import PerfectThread
import MySQL

#if os(Linux)
    import GlibC
#else
    import Darwin
#endif


class MysqlService {
    static let defaultHost = "127.0.0.1"
    static let defaultPort = 3306
    static let defaultUser = "root"
    static let defaultPassword = ""
    static let defaultDB = "shadowsocks"
    
    static let mysqlServiceInstance = MysqlService()
    
    
    static var instance:MysqlService {
        return mysqlServiceInstance
    }
    
    var mysql:MySQL?
    
    init() {
        self.mysql = MySQL()
    }
    
    
    let q = Threading.getQueue(name: "#Mysql Thread#", type: Threading.QueueType.serial)

    func connect() {
        let status = mysql?.connect(host: MysqlService.defaultHost, user: MysqlService.defaultUser, password: MysqlService.defaultPassword, db: MysqlService.defaultDB, port: UInt32(MysqlService.defaultPort))
        
    }
}
