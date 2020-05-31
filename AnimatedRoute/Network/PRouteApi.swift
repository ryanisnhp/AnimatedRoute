//
//  PRouteApi.swift
//  AnimatedRoute
//
//  Created by Nguyen Phat on 5/31/20.
//  Copyright © 2020 Nguyen Phat. All rights reserved.
//

import CoreLocation
import Moya

enum GoogleMapsAPI {
    //MARK: GOOGLE MAPS
    case getRoute(coordinates: [CLLocationCoordinate2D])
}

extension GoogleMapsAPI: TargetType {
    var baseURL: URL {
        let url = "https://maps.googleapis.com/maps/api"
        return URL(string: url)!
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var path: String {
        switch self {
        case .getRoute:
            return "directions/json"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case let .getRoute(coordinates):
            var params = ["key": DGoogleAPIBrowserKey]
            if let origin = coordinates.first {
                params["origin"] = "\(origin.latitude),\(origin.longitude)"
            }
            
            
            if let destination = coordinates.last {
                params["destination"] = "\(destination.latitude),\(destination.longitude)"
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var sampleData: Data {
        return Data()
    }
}
