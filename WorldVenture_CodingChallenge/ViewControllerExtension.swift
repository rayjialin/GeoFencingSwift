//
//  CoreLocationManager.swift
//  WorldVenture_CodingChallenge
//
//  Created by ruijia lin on 3/20/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

import Foundation
import MapKit

extension ViewController {
    
    // MARK: setup searchResultSearchBar
    func setupSearchResultSearchBar() {
        guard let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "LocationSearchTable") as? LocationSearchTable else { return }
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Type in an address"
        navigationItem.titleView = searchBar
        
        let editBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleSettings))
        navigationItem.setRightBarButton(editBarButton, animated: true)
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    // MARK: get all the annotations
    func fetchAnnotations() -> [WVAnnotation] {
        var annotations = [WVAnnotation]()
        let managedContext = CoreDataManager.fetchContext()
        
        for context in managedContext {
            let annotation = WVAnnotation()
            annotation.title = context.value(forKey: "name") as? String
            
            if let city = context.value(forKey: "city") as? String, let state = context.value(forKey: "state") as? String {
                annotation.subtitle = "\(city) \(state)"
            }
            if let latitude = context.value(forKey: "latitude") as? Double, let longitude = context.value(forKey: "longitude") as? Double {
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            annotations.append(annotation)
        }
        return annotations
    }
    
    
    // MARK: geofencing region
    func regionWith(annotation: WVAnnotation) -> CLCircularRegion {
        let distanceInMeter = convertToMeterFrom(mile: minimumDistanceForAlert)
        let radius = CLLocationDistance(distanceInMeter)
        let region = CLCircularRegion(center: annotation.coordinate, radius: radius, identifier: annotation.identifier)
        region.notifyOnEntry = true
        return region
    }
    
    // MARK: start monitoring
    func startMonitoringFor(annotation: WVAnnotation) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = """
      Your geotification is saved but will only be activated once you grant
      Geotify permission to access the device location.
      """
            showAlert(withTitle:"Warning", message: message)
        }
        
        let fenceRegion = regionWith(annotation: annotation)
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    func stopMonitoringFor(annotation: WVAnnotation) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == annotation.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    // MARK: remove overlay
    func removeRadiusOverlayFor(annotation: WVAnnotation) {
        let overlays = mapView.overlays
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == annotation.coordinate.latitude && coord.longitude == annotation.coordinate.longitude {
                mapView.removeOverlay(circleOverlay)
                break
            }
        }
    }
    
    // MARK: add overlay
    func addCircleOverlayFor(annotation: WVAnnotation) {
        let coordinate = annotation.coordinate
        let distanceInMeter = convertToMeterFrom(mile: minimumDistanceForAlert)
        let radius = CLLocationDistance(distanceInMeter)
        mapView.addOverlay(MKCircle(center: coordinate, radius: radius))
    }
    
    // MARK: update overlay
    func updateOverlayDistance() {
        var newOverlays = [MKCircle]()
        let distanceInMeter = convertToMeterFrom(mile: minimumDistanceForAlert)
        let radius = CLLocationDistance(distanceInMeter)
        
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            let ol = MKCircle(center: overlay.coordinate, radius: radius)
            newOverlays.append(ol)
        }
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlays(newOverlays)
    }
    
    // MARK: Convert mile to meter
    func convertToMeterFrom(mile: Int) -> Int{
        return mile * 1609
    }
}

// MARK: Helper Extensions
extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension MKMapView {
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        setRegion(region, animated: true)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
