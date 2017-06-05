//
//  RedisService.swift
//  SwiftServer
//
//  Created by admin on 2016/11/21.
//
//
import PerfectRedis
import PerfectLib
import PerfectThread

#if os(Linux)
    import GlibC
#else
    import Darwin
#endif


class RedisService {
    static let defaultHost = "127.0.0.1"
    static let defaultPort = redisDefaultPort
    static let defaultPassword = "RedisService"
    static let timeout:Double = 10
    
    
    static let redisServiceInstance = RedisService()
    
    
    static var instance:RedisService {
        return redisServiceInstance
    }
    
    let q = Threading.getQueue(name: "#Redis Thread#", type: Threading.QueueType.serial)
    var client:RedisClient?
    var lastActive:Double = 0.0
    var isBusy:Bool = false
    var globalChannel:String = "SSProject"
    
    
    func initRedis(callback:@escaping (_ isSuccess:Bool)->()) {
        RedisService.instance.open { (client) in
            if let _ = client {
                print("connect redis ok!")
                self.q.dispatch {
                    self.client = client
                    callback(true)
                }

            } else {
                print("connect redis failed!")
                callback(false)
            }
            self.startRedisCheckTimer()
        }
    }
    
    private func startRedisCheckTimer() {
        print("startRedisCheckTimer")
        while true {
            Threading.sleep(seconds: 2)
            self.pingCheck(callback: { (status) in
                //print("pingCheckStatus:\(status.description)")
                self.q.dispatch {
                    if !status {
                        //let t = (getNow() - self.lastActive) / 1000
                        //print("pingCheck:\(status) now:\(getNow()) lastActive:\(self.lastActive) timeout:\(RedisService.timeout) t:\(t)")
                        if getNow() - self.lastActive > RedisService.timeout * 1000 {
                            print("redis connection timeout, close!")
                            self.close()
                            self.open(callback: { (c) in
                            })
                        }
                    } else {
                        self.lastActive = getNow()
                    }
                }
                
                
            })
        }
    }
    
    private func open(callback:@escaping(_ client:RedisClient?) ->()) {
        RedisClient.getClient(withIdentifier: RedisClientIdentifier(withHost: RedisService.defaultHost, port: RedisService.defaultPort, password: RedisService.defaultPassword)) {
            c in
            do {
                let client = try c()
                print("create redis client")
                self.q.dispatch {
                    self.client = client
                    self.lastActive = getNow()
                }
                callback(client)
            } catch {
                print("❌ Connect redis server failed")
                self.q.dispatch {
                    self.client = nil
                    self.lastActive = 0
                }
                callback(nil)
            }
        }
        
    }
    
    private func close() {
        q.dispatch {
            self.client = nil
            self.q.dispatch {
                if let c = self.client {
                    print("release redis client")
                    RedisClient.releaseClient(c)
                }
            }
        }
        
        
    }
    
    private func pingCheck(callback:@escaping (_ status:Bool)->()) {
        
        if let c = self.client {
            c.ping(callback: { (response) in
                let pongTime:Double = getNow()
                if response.toString() == "PONG" {
                    //print("PONG:\(getNow())")
                    self.q.dispatch {
                        self.lastActive = pongTime
                    }
                    callback(true)
                } else {
                    callback(false)
                }
            })
        } else {
            callback(false)
        }
    }
    
    func getClient(callback:@escaping (_ isNewClient:Bool, _ client:RedisClient?)->()) {
        q.dispatch {
            if let client = self.client {
                if !self.isBusy {
                    self.isBusy = true
                    callback(false,client)
                    return
                }
            }
            RedisClient.getClient(withIdentifier: RedisClientIdentifier(withHost: RedisService.defaultHost, port: RedisService.defaultPort, password: RedisService.defaultPassword)) {
                c in
                do {
                    let client = try c()
                    callback(true,client)
                } catch {
                    print("❌[New]redisGet failed")
                    callback(true,nil)
                }
            }
        }
        
    }
    
//    private func baseSet(client:RedisClient,key:String, value:String, callback:@escaping (Bool)->()) {
//        client.set(key: key, value: .string(value)) { response in
//            switch response {
//            case let .simpleString(s):
//                //print("resp: \(s)")
//                if s == "OK" {
//                    callback(true)
//                } else {
//                    callback(false)
//                }
//                break
//            default:
//                //print("default")
//                callback(false)
//                break
//            }
//        }
//    }
//    
//    private func baseGet(client:RedisClient, key:String, callback:@escaping (Bool,String?)->()) {
//        client.get(key: key) { response in
//            
//            guard case .bulkString = response else {
//                callback(false,nil)
//                return
//            }
//            let value = response.toString()
//            callback(true,value)
//        }
//    }
//
//    //订阅
//    private func baseSubscribe(client:RedisClient, channels:Array<String>, callback:@escaping (Bool)->()) {
//        client.subscribe(channels: channels) { (resp) in
//            callback(resp.isSimpleOK)
//        }
//    }
//    
//    //退订
//    private func baseUnSubscribe(client:RedisClient, channels:Array<String>, callback:@escaping (Bool)->()) {
//        client.unsubscribe(channels: channels) { (resp) in
//            
//        }
//    }
//    
//    //发布
//    private func basePublish(client:RedisClient, channel:String, message:String, callback:@escaping (Bool)->()) {
//        client.publish(channel: channel, message: .string(message), callback: { (resp) in
//            callback(resp.isSimpleOK)
//        })
//    }
//    
//    //获取订阅信息
//    private func baseReadPublished(client:RedisClient, timeoutSeconds:Double, callback:@escaping([String]) -> ()) {
//        var data:Array<String> = Array()
//        client.readPublished(timeoutSeconds: timeoutSeconds) { (resp) in
//            guard case .array(let array) = resp else {
//                callback(data)
//                return
//            }
//            
//            for d in array {
//                if let s = d.toString() {
//                    data.append(s)
//                }
//                
//            }
//            callback(data)
//        }
//    }
//    
//    func doGet(key: String, callback:@escaping (Bool,String?)->()) {
//        self.getClient { (isNewClient, client) in
//            print("[Redis]get -> key:\(key) isNewClient:\(isNewClient)")
//            guard let c = client else {
//                callback(false,nil)
//                return
//            }
//            self.baseGet(client: c, key: key, callback: { (status, value) in
//                self.q.dispatch {
//                    if !isNewClient {
//                        self.isBusy = false
//                    }
//                }
//                callback(status,value)
//            })
//        }
//    }
//    
//    func doSet(key:String, value:String, callback:@escaping (Bool)->()) {
//        self.getClient { (isNewClient, client) in
//            print("[Redis]set -> key:\(key) value:\(value) isNewClient:\(isNewClient)")
//            guard let c = client else {
//                callback(false)
//                return
//            }
//            self.baseSet(client: c, key: key, value: value, callback: { (status) in
//                self.q.dispatch {
//                    if !isNewClient {
//                        self.isBusy = false
//                    }
//                }
//                callback(status)
//            })
//        }
//        
//    }
//
}



