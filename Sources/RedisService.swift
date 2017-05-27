//
//  RedisService.swift
//  SwiftServer
//
//  Created by admin on 2016/11/21.
//
//
import PerfectRedis

class RedisService {

    class func createClient(callback:@escaping(RedisClient?) ->()) {
        RedisClient.getClient(withIdentifier: RedisClientIdentifier()) {
            c in
            do {
                let client = try c()
                callback(client)
            } catch {
                print("❌ Connect redis server failed")
                callback(nil)
            }
        }
    }
    
    class func redisSet(key:String, value:String, callback:@escaping (Bool)->()) {
        print("testRedisSet -> key:\(key) value:\(value)")
        self.createClient { client in
            if let c = client {
                c.set(key: key, value: .string(value)) { response in
                    switch response {
                    case let .simpleString(s):
                        //print("resp: \(s)")
                        if s == "OK" {
                            callback(true)
                        } else {
                            callback(false)
                        }
                        break
                    default:
                        print("default")
                        callback(false)
                        break
                    }
                    RedisClient.releaseClient(c)
                }
            } else {
                print("testRedisSet failed")
                callback(false)
            }
        }
        
    }
    
    class func redisGet(key: String, callback:@escaping (Bool,String?)->()) {
        print("testRedisGet -> key:\(key)")
        self.createClient { client in
            if let c = client{
                c.get(key: key) { response in
                    
                    guard case .bulkString = response else {
                        print("get \"\(key)\" : nil")
                        callback(false,nil)
                        return
                    }
                    let value = response.toString()
                    print("get key:\(key) -> value:\(String(describing: value))");
                    callback(true,value)
                    RedisClient.releaseClient(c)
                }
            } else {
                print("testRedisGet failed")
                callback(false,nil)
            }
        }

        
    }
}
