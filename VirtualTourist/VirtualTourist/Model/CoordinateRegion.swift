//
//  CoordinateRegion.swift
//  VirtualTourist
//
//  Created by Giovanni Luidi Bruno on 01/01/21.
//  Copyright © 2021 Giovanni Luigi Bruno. All rights reserved.
//

import Foundation
import MapKit

struct CoordinateRegion: Codable {
    let centerLatitude: Double
    let latitudeDelta: Double
    let centerLongitude: Double
    let longitudeDelta: Double
    
    func toMKCoordinateRegion() -> MKCoordinateRegion {
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
    }
}
