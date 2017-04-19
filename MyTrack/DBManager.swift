//
//  DBManager.swift
//  MyTrack
//
//  Created by 沈維庭 on 2017/4/3.
//  Copyright © 2017年 WEITING. All rights reserved.
//

import UIKit

class DBManager: NSObject {
    static let shared:DBManager = DBManager()
    var databaseName = "MyTrack.sqlite"
    var path:String!
    var database:FMDatabase!
    
    let createMyTrackTable = "create table mytrack (ID integer primary key autoincrement not null, FileName text not null, Data none not null, StartTime text not null, StopTime text not null, Miles text not null, TotalTimer text not null);"
    let insert = "insert into mytrack(FileName,Data,StartTime,StopTime,Miles,TotalTimer) values(?,?,?,?,?,?)"
    let select = "select * from mytrack"
    let delect = "delete from mytrack where ID = ?"
    let update = "update mytrack set FileName = ? where ID = ?"
    override init() {
        super.init()
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String)
        path = documentsDirectory.appending("/\(databaseName)")
        database = FMDatabase(path: path)
        print("path:\(path)")
        if FileManager.default.fileExists(atPath: path) {
            
        } else {

            if database.open() {
                do {
                    try database.executeUpdate(createMyTrackTable, values: nil)
                    database.close()
                } catch {
                    print("創造失敗")
                }
                
            }
        }
       
    }
    
    func saveDataToDatabase(fileName:String,data:NSData,startTime:String,stopTime:String,miles:String,totalTimer:String) {
        if database.open() {
            do {
                try database.executeUpdate(insert, values: [fileName,data,startTime,stopTime,miles,totalTimer])
                
            } catch {
                print("寫入失敗")
            }
            database.close()
        }
    }
    
    func getAll() -> [MyTrack]! {
        var myTracks:[MyTrack]!
        if myTracks == nil {
            myTracks = [MyTrack]()
        }
        if database.open() {
            do {
                let result = try database.executeQuery(select, values: nil)
                
                while result.next() {
                    let mytarck = MyTrack(ID: (result.string(forColumn: "ID")),FileName: (result.string(forColumn: "FileName")), Data: (result.data(forColumn: "Data") as NSData), StartTime: (result.string(forColumn: "StartTime")), StopTime: (result.string(forColumn: "StopTime")),Miles: (result.string(forColumn: "Miles")), TotalTimer: (result.string(forColumn: "TotalTimer")))
                    
                    myTracks.append(mytarck)
                }
                
            } catch {
                print("搜尋失敗")
            }
            database.close()
        }
        return myTracks
    }
    
    func deleteMytarck(mytarckID:String) {
        if database.open() {
            do {
                try database.executeUpdate(delect, values: [mytarckID])
            } catch {
                print("delete fail")
            }
            database.close()
        }
    }
    
    func updateMytrack(myTrack:MyTrack,newFileName:String) {
        guard let id = myTrack.ID else {
            return
        }
        if database.open() {
            do {
                try database.executeUpdate(update, values: [newFileName,id])
            } catch {
                print("更新失敗")
            }
            database.close()
        }
    }
}








