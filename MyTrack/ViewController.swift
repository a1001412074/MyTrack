//
//  ViewController.swift
//  MyTrack
//
//  Created by 沈維庭 on 2017/4/2.
//  Copyright © 2017年 WEITING. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    var locationManager:CLLocationManager!
    var saveUserLocation = [CLLocation]()
    var isStar:Bool = false
    var isRecording = false
    var startTime:String!
    var stopTime:String!
    
    var miles:Double = 0
    
    var timer:Timer? = nil
    var sec:Int = 0
    var min:Int = 0
    var hour:Int = 0
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var milesLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var speadLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 10.0
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        
//        locationManager.startUpdatingLocation()
        
        guard let location = locationManager.location?.coordinate else {
            return
        }
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
        
        let db = DBManager()
        
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation:CLLocation = locations.last else {
            print("currentLocation錯誤")
            return
        }
        
        let coordinate:CLLocationCoordinate2D = currentLocation.coordinate
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
        map.setRegion(region, animated: true)
        // 寫入暫存Array
        if saveUserLocation.isEmpty {
            saveUserLocation = [CLLocation]()
        }
        saveUserLocation.append(currentLocation)

        drawPolyline(locationArray: saveUserLocation,map: map)
        
        putStarAnnotation()

        calculateDistance()
        
        speadLabel.text = String(format: "%.2f km/hr", currentLocation.speed)
        
    }
    
    func drawPolyline(locationArray:[CLLocation],map:MKMapView) {
        var coordinates:[CLLocationCoordinate2D] = []
        
        for i in 0...locationArray.count - 1 {
            
            let location:CLLocation = locationArray[i]
            let coordinate = location.coordinate
            coordinates.append(coordinate)
            
        }
        let polyline:MKPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        map.add(polyline)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer:MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.lineWidth = 5
        polylineRenderer.strokeColor = .blue
        return polylineRenderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            print("no")
            return nil
        }
        
        let storeID = "Store"
        
        var mapView = mapView.dequeueReusableAnnotationView(withIdentifier: storeID) as? MKPinAnnotationView
        if mapView == nil {
            mapView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: storeID)
            
        } else {
            mapView?.annotation = annotation
        }
        mapView?.canShowCallout = true
        
        let customAnn = annotation as! CustomAnnotation
        mapView?.pinTintColor = customAnn.color

        
        
        return mapView
    }
    // 開始
    @IBAction func starRecordUserLocation(_ sender: Any) {
        
        
        guard let button = sender as? UIButton else {
            return
        }
        if CLLocationManager.authorizationStatus() == .denied || !CLLocationManager.locationServicesEnabled(){
            check()
        } else {
            
            if !isRecording {
                isRecording = true
                button.setImage(UIImage(named: "Stop.png"), for: .normal)
                map.removeOverlays(map.overlays)
                map.removeAnnotations(map.annotations)
                locationManager.startUpdatingLocation()
                startTime = getTime()
                startTimer()
            } else if isRecording {
                self.locationManager.stopUpdatingLocation()
                let alert = UIAlertController(title: nil, message: "要儲存記錄還是繼續記錄", preferredStyle: .alert)
                let save = UIAlertAction(title: "儲存", style: .default, handler: { (UIAlertAction) in
                    self.isRecording = false
                    self.stopRecordUserLocatiom()
                    self.stopTimer()
                    self.miles = 0
                    self.milesLabel.text = String(format: "%@", "0.00公里")
                    button.setImage(UIImage(named: "Start.png"), for: .normal)
                })
                let keepgoin = UIAlertAction(title: "繼續", style: .default, handler: { (UIAlertAction) in
                    self.locationManager.startUpdatingLocation()
                })
                alert.addAction(keepgoin)
                alert.addAction(save)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    @IBAction func gobackToUserLocation(_ sender: Any) {
        
        guard let location = locationManager.location?.coordinate else {
            return
        }
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
        
    }
    
    // 停止
    func stopRecordUserLocatiom() {
        // 停止時間
        stopTime = getTime()
        // 停止更新
        locationManager.stopUpdatingLocation()
        // 放停止大頭針
        putStopAnnotation()
        // 將array轉成Data
        let data:NSData = NSKeyedArchiver.archivedData(withRootObject: saveUserLocation) as NSData
        // 寫入db
        DBManager.shared.saveDataToDatabase(fileName: startTime, data: data, startTime: startTime, stopTime: stopTime,miles: String(format: "%.2f", miles), totalTimer: String(format: "%02d:%02d:%02d", hour,min,sec))
        // 清空陣列
        saveUserLocation.removeAll()
        
        isStar = false
    }
        // 開始大頭針
    func putStarAnnotation() {
        if isStar {
            return
        }
        isStar = true
        
        guard let coordinate = saveUserLocation.first else {
            return
        }

        let customAnn = CustomAnnotation(cllocation: coordinate.coordinate, title: "起點", subTitle: startTime)
        
        customAnn.color = .green
        map.addAnnotation(customAnn)
   
    }
    // 結束大頭針
    func putStopAnnotation() {
        
        guard let coordinate = saveUserLocation.last else {
            return
        }
        
        let customAnn = CustomAnnotation(cllocation: coordinate.coordinate, title: "終點", subTitle: stopTime)
        
        customAnn.color = .red
        map.addAnnotation(customAnn)
        
    }
    // 取得時間
    func getTime() -> (String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time = dateFormatter.string(from: Date())
        return time
        
    }
    
    func calculateDistance() {
        var meter:Double = 0
        
        if saveUserLocation.count > 1 {
            let startLocation:CLLocation = saveUserLocation[saveUserLocation.count - 2]
            let startLocationLat = startLocation.coordinate.latitude
            let startLocationLon = startLocation.coordinate.longitude
        
            let stopLocation:CLLocation = saveUserLocation[saveUserLocation.count - 1]
            let stopLocationLat = stopLocation.coordinate.latitude
            let stopLocationLon = stopLocation.coordinate.longitude
        
            // 開始座標
            let startLat = startLocationLat * M_PI / 180.0
            let startLon = startLocationLon * M_PI / 180.0
            // 結束座標
            let stopLat = stopLocationLat * M_PI / 180.0
            let stopLon = stopLocationLon * M_PI / 180.0
        
            let start = fabs(startLat - stopLat)
            let stop = fabs(startLon - stopLon)
        
            var total = 2 * asin(sqrt(pow(sin(start/2), 2) + cos(startLat) * cos(stopLat) * pow(sin(stop/2), 2)))
            total = total * 6378137
            meter = round(total * 10000) / 10000
            miles = miles + meter / 1000
            
            milesLabel.text = String(format: "%.2f%@", miles,"公里")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerTrack), userInfo: nil, repeats: true)
        guard let timer = timer else {
            return
        }
        let runLoop = RunLoop.main
        runLoop.add(timer, forMode: .defaultRunLoopMode)
    }
    
    func timerTrack(timer:Timer) {
        sec += 1
        if sec == 60 {
            sec = 0
            min += 1
        }
        if min == 60 {
            min = 0
            hour += 1
        }
        
        timerLabel.text = String(format: "%02d:%02d:%02d", hour,min,sec)
        
    }
    
    func stopTimer() {
        timer?.invalidate()
        sec = 0
        min = 0
        hour = 0
        timerLabel.text = String(format: "%02d:%02d:%02d", hour,min,sec)
    }
    
    func check() {
        
        let alert = UIAlertController(title: "定位尚未開啟", message: "需開啟定位功能才能記錄", preferredStyle: .alert)
        let setting = UIAlertAction(title: "Setting", style: .destructive, handler: { (UIAlertAction) in
            guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            UIApplication.shared.openURL(url)
        })
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        alert.addAction(cancel)
        alert.addAction(setting)
        self.present(alert, animated: true, completion: nil)
    }
    
}

