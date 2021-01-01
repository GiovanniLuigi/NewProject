//
//  MKCoordinateRegion+Extensions.swift
//  VirtualTourist
//
//  Created by Giovanni Luidi Bruno on 01/01/21.
//  Copyright © 2021 Giovanni Luigi Bruno. All rights reserved.
//

import MapKit

extension MKCoordinateRegion {
    func toCoordinateRegion() -> CoordinateRegion {
        return CoordinateRegion(centerLatitude: center.latitude, latitudeDelta: span.latitudeDelta, centerLongitude: center.longitude, longitudeDelta: span.longitudeDelta)
    }
}

