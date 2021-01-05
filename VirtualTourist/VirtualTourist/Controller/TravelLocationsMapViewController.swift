//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Giovanni Luidi Bruno on 31/12/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pins = [Pin]()
    
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
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataManager.viewContext.fetch(fetchRequest) {
            pins = result
            for (i, pin) in pins.enumerated() {
                let annotation = MyAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                annotation.index = i
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    @objc private func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else {
            return
        }
        let point = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        let pin = Pin(context: dataManager.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        dataManager.saveContext()
       
        pins.append(pin)
        let annotation = MyAnnotation()
        annotation.coordinate = coordinate
        annotation.index = pins.count-1
        mapView.addAnnotation(annotation)
    }
}

extension TravelLocationsMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let region = mapView.region.toCoordinateRegion()
        dataManager.save(object: region)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MyAnnotation,
            let index = annotation.index,
            let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: PhotoAlbumViewController.self)) as? PhotoAlbumViewController {
            let pin = pins[index]
            vc.pin = pin
            vc.annotation = annotation
            navigationController?.pushViewController(vc, animated: true)
            mapView.selectedAnnotations = []
        }
    }
}
