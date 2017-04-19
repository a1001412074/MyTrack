//
//  RecordViewController.swift
//  MyTrack
//
//  Created by 沈維庭 on 2017/4/4.
//  Copyright © 2017年 WEITING. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var recordArray:[MyTrack] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let image = UIImageView(image: UIImage(named: "background.png"))
        self.tableView.backgroundView = image
        self.tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recordArray = DBManager.shared.getAll()
        return recordArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        let myTrack = recordArray[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.textLabel!.text = myTrack.FileName
        cell.detailTextLabel?.textColor = .white
        cell.detailTextLabel!.text = myTrack.StartTime
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let myTrack = recordArray[indexPath.row]
        
        // 刪除
        let delete = UITableViewRowAction(style: .destructive, title: "刪除") { (uitUITableViewRowActionable, indexPath) in
            let alert = UIAlertController(title: "刪除", message: "確定要刪除？", preferredStyle: .alert)
            let delete = UIAlertAction(title: "刪除", style: .destructive, handler: { (UIAlertAction) in
                self.deleteTheFile(myTrack: myTrack)
            })
            let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
            alert.addAction(cancel)
            alert.addAction(delete)
            self.present(alert, animated: true, completion: nil)
        }
        // 編輯
        let editing = UITableViewRowAction(style: .destructive, title: "詳細") { (UITableViewRowAction, indexPath) in
            
            let message = String(format: "總路程:%@ 公里\n總時間:%@", myTrack.Miles!,myTrack.TotalTimer!)
            
            let alert = UIAlertController(title: "更改名稱", message: message, preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = myTrack.FileName
            })
            let ok = UIAlertAction(title: "確定", style: .default, handler: { (UIAlertAction) in
                guard let newFileName = alert.textFields?[0].text else {
                    return
                }
                self.update(myTrack: myTrack, newFileName: newFileName)
                self.recordArray = DBManager.shared.getAll()
                tableView.reloadData()
            })
            let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        editing.backgroundColor = .gray
        
        return [delete,editing]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordMap" {
            if let indexPath = tableView.indexPathForSelectedRow {

                guard let recordMapVC = segue.destination as? RecordMapViewController else {
                    return
                }
                recordMapVC.myTrack = recordArray[indexPath.row]
            }
        }
    }
    
    func deleteTheFile(myTrack:MyTrack) {

        guard let myTrackID = myTrack.ID else {
            print("找不到ID")
            return
        }
        DBManager.shared.deleteMytarck(mytarckID: myTrackID)
        recordArray = DBManager.shared.getAll()
        tableView.reloadData()
    }
    
    func update(myTrack:MyTrack,newFileName:String){
        DBManager.shared.updateMytrack(myTrack: myTrack, newFileName: newFileName)
        self.recordArray = DBManager.shared.getAll()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
