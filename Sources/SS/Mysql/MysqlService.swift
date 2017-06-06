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
    
    let q = Threading.getQueue(name: "#Mysql Thread#", type: Threading.QueueType.serial)

    private class func setOptions(_ mysql:MySQL)->Bool {
        guard mysql.setOption(MySQLOpt.MYSQL_OPT_RECONNECT, true) else {
            return false
        }
        guard mysql.setOption(MySQLOpt.MYSQL_OPT_CONNECT_TIMEOUT, 5) else {
            return false
        }
        guard mysql.setOption(MySQLOpt.MYSQL_OPT_READ_TIMEOUT, 10) else {
            return false
        }
        guard mysql.setOption(MySQLOpt.MYSQL_OPT_WRITE_TIMEOUT, 10) else {
            return false
        }
        guard mysql.setOption(MySQLOpt.MYSQL_SET_CHARSET_NAME, "utf8") else {
            return false
        }
        return true
    }
    
    private class func connServer()->MySQL? {
        let mysql = MySQL()
        let _ = setOptions(mysql)
        
        guard mysql.connect(host: MysqlService.defaultHost, user: MysqlService.defaultUser, password: MysqlService.defaultPassword, db: MysqlService.defaultDB, port: UInt32(MysqlService.defaultPort)) else {
            print(mysql.errorMessage())
            return nil
        }
        return mysql
    }
    
    private class func useDB(_ mysql:MySQL, _ dbName:String)->Bool {
        guard mysql.selectDatabase(named: dbName) else {
            print(mysql.errorMessage())
            return false
        }
        return true
    }
    
    class func listDB(_ dbNameWildcard:String? = nil) -> [String]? {
        guard let mysql = connServer() else {
            return nil
        }
        
        defer {
            mysql.close()
        }
        
        return mysql.listDatabases(wildcard:dbNameWildcard)
    }
    
    class func listTable(_ dbName:String, tableNameWildcard:String? = nil) -> [String]? {
        guard let mysql = connServer() else {
            return nil
        }
        
        defer {
            mysql.close()
        }
        
        guard useDB(mysql, dbName) else {
            return nil
        }
        
        return mysql.listTables(wildcard: tableNameWildcard)
    }
    
    class func query(dbName:String,sql:String,callback:(_ status:Bool, _ result:Array<Array<String?>>?)->()){
        let mysql = MySQL()
        guard mysql.connect(host: MysqlService.defaultHost, user: MysqlService.defaultUser, password: MysqlService.defaultPassword, db: MysqlService.defaultDB, port: UInt32(MysqlService.defaultPort)) else {
            print("connect mysql server failed!")
            callback(false, nil)
            return
        }
        defer {
            mysql.close()
        }
        
        guard mysql.selectDatabase(named: dbName) else {
            print("use \(dbName) failed!")
            callback(false,nil)
            return
        }
        
        let status = mysql.query(statement: sql)
        if let results = mysql.storeResults() {
            let numRows = results.numRows()
            let fields = results.numFields()
            
            while let row = results.next() {
                row
            }
            
            results.forEachRow(callback: { (element) in
                element[0]
            })
        }
        callback(status,nil)
    }
    
    
}
