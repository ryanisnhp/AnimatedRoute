//
//  PRouteProvider.swift
//  AnimatedRoute
//
//  Created by Nguyen Phat on 5/31/20.
//  Copyright © 2020 Nguyen Phat. All rights reserved.
//

import Moya
import RxSwift
import CoreLocation


struct GoogleMapsNetworkAgent {
    fileprivate let provider = MoyaProvider<GoogleMapsAPI>(plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))])

    func getRouteFromGoogleMaps(coordinates: [CLLocationCoordinate2D]) -> Observable<PGoogleMapsRouteResponse> {
        return provider.rx.request(.getRoute(coordinates: coordinates))
            .asObservable()
            .retry(2)
            .filterSuccessfulStatusCodes()
            .map(PGoogleMapsRouteResponse.self)
    }
}
