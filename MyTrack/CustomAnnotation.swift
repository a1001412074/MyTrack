//
//  CustomAnnotation.swift
//  MyTrack
//
//  Created by 沈維庭 on 2017/4/2.
//  Copyright © 2017年 WEITING. All rights reserved.
//

import UIKit
import MapKit
class CustomAnnotation: MKPointAnnotation{
    
    var cllocation:CLLocationCoordinate2D!
    var annTitle:String?
    var annSubTitle:String?
    var color:UIColor?
    var image:UIImage?
    
    
    init(cllocation:CLLocationCoordinate2D,title:String,subTitle:String?) {
        super.init()
        self.coordinate = cllocation
        self.title = title
        self.subtitle = subTitle

    }

}
