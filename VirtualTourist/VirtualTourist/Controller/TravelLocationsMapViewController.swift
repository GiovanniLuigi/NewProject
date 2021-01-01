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
        setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupMapView() {
        mapView.delegate = self
        
        if let region: CoordinateRegion = dataManager.get() {
            mapView.setRegion(region.toMKCoordinateRegion(), animated: false)
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else {
            return
        }
        let point = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}


extension TravelLocationsMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let region = mapView.region.toCoordinateRegion()
        dataManager.save(object: region)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let coordinate = view.annotation?.coordinate, let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: PhotoAlbumViewController.self)) as? PhotoAlbumViewController {
            vc.coordinate = coordinate
            navigationController?.pushViewController(vc, animated: true)
            view.setSelected(false, animated: false)
        }
    }
}
