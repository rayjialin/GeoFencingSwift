//
//  WVAnnotation.swift
//  WorldVenture_CodingChallenge
//
//  Created by ruijia lin on 3/20/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

import MapKit

class WVAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var identifier: String
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = ""
        self.subtitle = ""
        self.identifier = NSUUID().uuidString
    }
}
