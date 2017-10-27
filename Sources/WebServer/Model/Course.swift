//
//  Course.swift
//  WebServer
//
//  Created by huhuegg on 2017/10/26.
//

import Foundation

enum CourseStatus:Int {
    case unknown = -1
    case all = 0
    case ing = 1
    case waiting = 2
    case end = 3
}

class Course {
    
    /// 课程ID
    var sid:String = ""
    
    /// 创建人
    var ownerUserSid:String = ""
    
    /// 课程标题
    var title:String = ""
    
    /// 课程描述
    var desc:String = ""
    
    /// 开始时间
    var starttime:TimeInterval = Date().timeIntervalSince1970
    
    /// 课程时长
    var duration:Int = 0
    
    /// 封面图片
    var imageUrl:String = ""
    
    /// 课程状态
    var status:CourseStatus = .unknown

    var createtime:TimeInterval = Date().timeIntervalSince1970
    
    init(ownerUserSid:String, title:String, desc:String, starttime:TimeInterval, duration:Int, imageUrl:String) {
        self.sid = UUID().uuidString.md5
        self.ownerUserSid = ownerUserSid
        self.title = title
        self.desc = desc
        self.starttime = starttime
        self.duration = duration
        self.imageUrl = imageUrl
        self.status = .waiting
        
    }
    
    func toDict() -> Dictionary<String,Any> {
        var data:Dictionary<String,Any> = Dictionary()
        data["course_id"] = self.sid
        data["owner_uid"] = self.ownerUserSid
        data["title"] = self.title
        data["desc"] = self.desc
        data["start_time"] = self.starttime
        data["duration"] = self.duration
        data["pic"] = self.imageUrl
        data["status"] = self.status.rawValue
        return data
    }
}

