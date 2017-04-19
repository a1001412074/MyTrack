//
//  MyTarck.swift
//  MyTrack
//
//  Created by 沈維庭 on 2017/4/3.
//  Copyright © 2017年 WEITING. All rights reserved.
//

import UIKit

class MyTrack: NSObject {
    var ID:String?
    var FileName:String?
    var Data:NSData?
    var StartTime:String?
    var StopTime:String?
    var Miles:String?
    var TotalTimer:String?
    
    
    init(ID:String,FileName:String,Data:NSData,StartTime:String,StopTime:String,Miles:String,TotalTimer:String) {
        self.ID = ID
        self.FileName = FileName
        self.Data = Data
        self.StartTime = StartTime
        self.StopTime = StopTime
        self.Miles = Miles
        self.TotalTimer = TotalTimer
    }
    
    
}
