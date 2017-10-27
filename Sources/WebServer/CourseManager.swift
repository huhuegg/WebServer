//
//  RoomManager.swift
//  WebServerPackageDescription
//
//  Created by huhuegg on 2017/10/26.
//

import Foundation

class CourseManager {
    static var _courseManager = CourseManager()
    
    static var shared:CourseManager {
        return _courseManager
    }
    
    var courseDict:Dictionary<String,Course> = Dictionary()
    var waitingCourse:Array<Course> = Array()
    var ingCourse:Array<Course> = Array()
    var completedCourse:Array<Course> = Array()
    
    func newCourse(course:Course) {
        courseDict[course.sid] = course
    }
    
    func findCourse(courseId:String)->Course? {
        if let course = courseDict[courseId] {
            return course
        }
        return nil
    }
    
    func findCourseWithStatus(courseId:String, status:CourseStatus)->Course? {
        if let course = courseDict[courseId] {
            if course.status == status {
                return course
            }
        }
        return nil
    }
    
    func changeStatus(course:Course) {
        if course.status == .waiting {
            waitingCourse.append(course)
        } else if course.status == .ing {
            removeFromWaiting(course: course)
            ingCourse.append(course)
        } else if course.status == .end {
            removeFromIng(course: course)
            completedCourse.append(course)
        }
    }
    
    private func removeFromWaiting(course:Course) {
        var index = -1
        for idx in 0..<waitingCourse.count {
            if let c = waitingCourse[idx] as? Course {
                if c.sid == course.sid {
                    index = idx
                    break
                }
            }
            
        }
        if index >= 0 {
            waitingCourse.remove(at: index)
        }
    }
    
    private func removeFromIng(course:Course) {
        var index = -1
        for idx in 0..<ingCourse.count {
            if let c = ingCourse[idx] as? Course  {
                if c.sid == course.sid {
                    index = idx
                    break
                }
            }
        }
        if index >= 0 {
            ingCourse.remove(at: index)
        }
    }
}
