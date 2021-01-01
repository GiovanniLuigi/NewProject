//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Giovanni Luidi Bruno on 31/12/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataManager: DataManager {
        return DataManager.shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        if let region: CoordinateRegion = dataManager.get() {
            mapView.setRegion(region.toMKCoordinateRegion(), animated: false)
        }
    }
}


extension TravelLocationsMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let region = mapView.region.toCoordinateRegion()
        dataManager.save(object: region)
    }
}

extension MKCoordinateRegion {
    func toCoordinateRegion() -> CoordinateRegion {
        return CoordinateRegion(centerLatitude: center.latitude, latitudeDelta: span.latitudeDelta, centerLongitude: center.longitude, longitudeDelta: span.longitudeDelta)
    }
}

struct CoordinateRegion: Codable {
    let centerLatitude: Double
    let latitudeDelta: Double
    let centerLongitude: Double
    let longitudeDelta: Double
    
    func toMKCoordinateRegion() -> MKCoordinateRegion {
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
    }
}
