//
//  PGoogleMapsRouteResponse.swift
//  AnimatedRoute
//
//  Created by Nguyen Phat on 5/31/20.
//  Copyright © 2020 Nguyen Phat. All rights reserved.
//

import Foundation

// MARK: - DGoogleMapsRouteResponse
class PGoogleMapsRouteResponse: Codable {
    let geocodedWaypoints: [PGeocodedWaypoint]?
    let routes: [PGoogleMapRoute]?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case geocodedWaypoints = "geocoded_waypoints"
        case routes, status
    }
    
    init(geocodedWaypoints: [PGeocodedWaypoint]?, routes: [PGoogleMapRoute]?, status: String?) {
        self.geocodedWaypoints = geocodedWaypoints
        self.routes = routes
        self.status = status
    }
}

// MARK: - DGeocodedWaypoint
class PGeocodedWaypoint: Codable {
    let geocoderStatus, placeID: String?
    let types: [String]?
    
    enum CodingKeys: String, CodingKey {
        case geocoderStatus = "geocoder_status"
        case placeID = "place_id"
        case types
    }
    
    init(geocoderStatus: String?, placeID: String?, types: [String]?) {
        self.geocoderStatus = geocoderStatus
        self.placeID = placeID
        self.types = types
    }
}

// MARK: - Route
class PGoogleMapRoute: Codable {
    let bounds: PGoogleMapBounds?
    let copyrights: String?
    let overviewPolyline: PGoogleMapPolyline?
    let summary: String?
    let waypointOrder: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case bounds, copyrights
        case overviewPolyline = "overview_polyline"
        case summary
        case waypointOrder = "waypoint_order"
    }
    
    init(bounds: PGoogleMapBounds?, copyrights: String?, overviewPolyline: PGoogleMapPolyline?, summary: String?, waypointOrder: [Int]?) {
        self.bounds = bounds
        self.copyrights = copyrights
        self.overviewPolyline = overviewPolyline
        self.summary = summary
        self.waypointOrder = waypointOrder
    }
}

// MARK: - Bounds
class PGoogleMapBounds: Codable {
    let northeast, southwest: Northeast?
    
    init(northeast: Northeast?, southwest: Northeast?) {
        self.northeast = northeast
        self.southwest = southwest
    }
}

// MARK: - Northeast
class Northeast: Codable {
    let lat, lng: Double?
    
    init(lat: Double?, lng: Double?) {
        self.lat = lat
        self.lng = lng
    }
}

// MARK: - Distance
class Distance: Codable {
    let text: String?
    let value: Int?
    
    init(text: String?, value: Int?) {
        self.text = text
        self.value = value
    }
}

// MARK: - Polyline
class PGoogleMapPolyline: Codable {
    let points: String?
    
    init(points: String?) {
        self.points = points
    }
}
