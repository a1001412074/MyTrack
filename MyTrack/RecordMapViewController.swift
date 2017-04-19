//
//  RecordMapViewController.swift
//  MyTrack
//
//  Created by 沈維庭 on 2017/4/4.
//  Copyright © 2017年 WEITING. All rights reserved.
//

import UIKit
import MapKit
class RecordMapViewController: UIViewController,MKMapViewDelegate {
    
    let vc = ViewController()
    var myTrack:MyTrack! = nil
    var myTrackLocation:[CLLocation]? = []

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var milesLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        myTrackLocation = NSKeyedUnarchiver.unarchiveObject(with: myTrack.Data as! Data) as? [CLLocation]
        guard let location = myTrackLocation else {
            print("轉型失敗")
            return
        }
        
        setRegion(locationArray: location)
        vc.drawPolyline(locationArray: location, map: mapView)
        putAnnotation(locationArray: location)
        
        milesLabel.text = String(format: "%@%@", myTrack.Miles!,"公里")
        timerLabel.text = String(format: "%@", myTrack.TotalTimer!)
    }
    
    func setRegion(locationArray:[CLLocation]) {
        guard let location = locationArray.first else {
            return
        }
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

    func putAnnotation(locationArray:[CLLocation]) {
        guard let firstLocation = locationArray.first else {
            return
        }
        let starAnnotation = CustomAnnotation(cllocation: firstLocation.coordinate, title: "起點", subTitle: myTrack.StartTime!)
        
        starAnnotation.color = .green
        mapView.addAnnotation(starAnnotation)
        
        guard let lasstLocation = locationArray.last else {
            return
        }
        let stopAnnotation = CustomAnnotation(cllocation: lasstLocation.coordinate, title: "終點", subTitle: myTrack.StartTime!)
        
        stopAnnotation.color = .red
        mapView.addAnnotation(stopAnnotation)
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer:MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.lineWidth = 5
        polylineRenderer.strokeColor = .blue
        return polylineRenderer
    }

    override func viewDidDisappear(_ animated: Bool) {
        myTrack = nil
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
