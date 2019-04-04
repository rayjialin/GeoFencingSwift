//
//  ViewControllerDelegates.swift
//  WorldVenture_CodingChallenge
//
//  Created by ruijia lin on 3/20/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

import Foundation
import MapKit

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // save search result location to core data
        let uuid = NSUUID().uuidString
        CoreDataManager.saveContext(name: placemark.name, street: placemark.thoroughfare, city: placemark.locality, state: placemark.administrativeArea, zipCode: placemark.postalCode, latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude, identifier: uuid)
        
        selectedPin = placemark
        let annotation = WVAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        annotation.identifier = uuid
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        addCircleOverlayFor(annotation: annotation)
        startMonitoringFor(annotation: annotation)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "favLocationId"
        if annotation is MKUserLocation {
            return nil
        }
        
        if annotation is WVAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                removeButton.setImage(UIImage(named: "delete")!, for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            let randomColor = UIColor.green
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = randomColor
            circleRenderer.fillColor = UIColor.green.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? WVAnnotation {
            remove(annotation: annotation)
            
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let minimumDistance = (row + 1) * 10
        return "\(minimumDistance) miles"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let minimumDistance = (row + 1) * 10
        minimumDistanceForAlert = minimumDistance
    }
}
