//
//  CheckType.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/26.
//
//

enum DataType {
    case string
    case dictStringAny
    case arryAny
    case arrayString
    case int
    case double
    case bool
    
    func desc()->String {
        switch self {
        case .string:
            return "String"
        case .dictStringAny:
            return "Dictionary<String,Any>"
        case .arryAny:
            return "Array<Any>"
        case .arrayString:
            return "Array<String>"
        case .int:
            return "Int"
        case .double:
            return "Double"
        case .bool:
            return "Bool"

        }
    }
}

class DataTypeCheck {
    class func dataCheck(_ data:[String:Any]?, types:[String:DataType])->Bool {
        guard let d = data else {
            print("需要检测的数据不存在")
            return false
        }

        for key in types.keys {
            if let value = d[key] {
                let type = types[key]!
                let isSuccess = check(value, type: type)
                
                if !isSuccess {
                    print("key:\(key) isSuccess:\(isSuccess.description) needType:\(type.desc())")
                    return false
                }
            } else {
                print("需要检测的key:\(key)在数据中不存在")
                return false
            }
        }
        return true
    }
    
    class func check(_ value:Any, type:DataType)->Bool {
        var status:Bool = false
        switch type {
        case .string:
            if value is String {
                status = true
            }
            break
        case .dictStringAny:
            if value is Dictionary<String,Any> {
                status = true
            }
            break
        case .arryAny:
            if value is Array<Any> {
                status = true
            }
            break
        case .arrayString:
            if value is Array<String> {
                status = true
            }
            break
        case .int:
            if value is Int {
                status = true
            }
            break
        case .double:
            if value is Double {
                status = true
            }
            break
        case .bool:
            if value is Bool {
                status = true
            }
            break
        }
        return status
    }
}
//
//var data:[String:Any] = Dictionary()
//
//data["str"] = "str"
//let dict1:Dictionary<String,AnyObject> = Dictionary()
//data["dict1"] = dict1
//let dict2:Dictionary<String,Any> = Dictionary()
//data["dict2"] = dict2
//let arr1:Array<AnyObject> = Array()
//data["arr1"] = arr1
//let arr2:Array<Any> = Array()
//data["arr2"] = arr2
//data["int"] = 1
//data["double"] = 1.1
//data["bool"] = true
//
//let status = DataTypeCheck.dataCheck(data, types: ["str":.string, "dict1":.dictStringAny, "dict2":.dictStringAny, "arr1":.arryAny, "arr2":.arryAny, "int":.int, "float":.double, "bool":.bool])
//print("status:\(status.description)")
