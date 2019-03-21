//
//  ViewController.swift
//  WorldVenture_CodingChallenge
//
//  Created by ruijia lin on 3/19/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var minimumDistanceForAlert = 10 // in miles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        
        // setup search bar
        setupSearchResultSearchBar()
        
        // drop a pin using long press gesture
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 2
        mapView.addGestureRecognizer(longPress)
        
        // get all stored data from coredata
        let annotations = fetchAnnotations()
        mapView.addAnnotations(annotations)
        annotations.forEach { addCircleOverlayFor(annotation: $0)}
    }
    
    // Actions
    @objc func handleLongPress(_ recognizer: UIGestureRecognizer) {
        let touchAt = recognizer.location(in: mapView)
        let touchAtCoordinate = mapView.convert(touchAt, toCoordinateFrom: mapView)
        
        confirmLocationAlert(latitude: touchAtCoordinate.latitude, longitude: touchAtCoordinate.longitude) { locationNew in
            
            let newAnnotation = WVAnnotation()
            newAnnotation.coordinate = touchAtCoordinate
            newAnnotation.title = locationNew
            self.mapView.addAnnotation(newAnnotation)
            self.addCircleOverlayFor(annotation: newAnnotation)
        }
    }
    
    
    // Alert Actions
    func confirmLocationAlert(latitude: Double, longitude: Double, completion: @escaping (String) -> ()) {
        let alert = UIAlertController(title: "Location Name", message: "Create a name for this location", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter name here"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0].text else { return }
            
            // save pin dropped location to core data
            CoreDataManager.saveContext(name: textField, street: nil, city: nil, state: nil, zipCode: nil, latitude: latitude, longitude: longitude)
            
            completion(textField)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Define global setting for minimum distance for alert
    @objc func handleSettings() {
        // default minimum distance for alert to 10 miles
        minimumDistanceForAlert = 10
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: self.view.frame.width / 2,height: self.view.frame.height / 4)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: self.view.frame.height / 4))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        let editRadiusAlert = UIAlertController(title: "Minimum Distance for Alert", message: "", preferredStyle: .alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
            print("minimum distance: \(self.minimumDistanceForAlert) miles")
            self.updateOverlayDistance()
        }))
        editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(editRadiusAlert, animated: true)
    }
}

