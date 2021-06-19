//
//  Place.swift
//  MapAnnotation
//
//  Created by Alexander Bonney on 6/14/21.
//

import Foundation
import MapKit

struct Place: Identifiable, Codable, Comparable {
    var id = UUID()
    var name: String
    var description: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name < rhs.name
    }
} 

