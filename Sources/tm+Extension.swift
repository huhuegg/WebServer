//
//  tm+Extension.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/27.
//
//

#if os(Linux)
    import GlibC
#else
    import Darwin
#endif

extension tm{
    
    var year:Int32 { return tm_year + 1900 }
    
    var month:Int32 { return tm_mon + 1 }
    
    var day:Int32 { return tm_mday }
    
    var time:(hour:Int32, mins:Int32, secs:Int32){
        return (hour: tm_hour, mins: tm_min, secs:tm_sec)
    }
    
    init(year:Int32, month:Int32, day:Int32, hour:Int32 = 0, mins:Int32 = 0, secs:Int32 = 0){
        self.init()
        self.tm_year = year - 1900
        self.tm_mon = month - 1
        self.tm_mday = day
        self.tm_hour = hour
        self.tm_min = mins
        self.tm_sec = secs
        
    }
    
    mutating func dateByAddingSeconds(seconds:Int) -> tm {
        var d1 = timegm(&self) + seconds
        return gmtime(&d1).pointee
    }
    
}
