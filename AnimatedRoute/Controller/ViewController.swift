//
//  ViewController.swift
//  AnimatedRoute
//
//  Created by Nguyen Phat on 5/30/20.
//  Copyright © 2020 Nguyen Phat. All rights reserved.
//

import UIKit
import RxSwift
import GoogleMaps

class ViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    private let googleMapsNetworkAgent = GoogleMapsNetworkAgent()
    private let disposeBag = DisposeBag()
    
    private let oldTraffordStadium = CLLocationCoordinate2D(latitude: 53.46305889999999, longitude: -2.2913401)
    private let etihadStadium = CLLocationCoordinate2D(latitude: 53.48313810000001, longitude: -2.2003953)
    private let stamfordBridgeStadium = CLLocationCoordinate2D(latitude: 51.4822656, longitude: -0.1933769)
    private let anfieldStadium = CLLocationCoordinate2D(latitude: 53.4308326, longitude: -2.9630187)

    private let a = CLLocationCoordinate2D(latitude: 50.2231664, longitude: -5.1659557)
    private let b = CLLocationCoordinate2D(latitude: 51.9326222, longitude: -5.0301721)

    
    private lazy var timer = Timer()
    
    var i : UInt = 0
    private lazy var path = GMSPath()
    private lazy var polyline = GMSPolyline()
    private lazy var newPolyline = GMSPolyline()
    private lazy var newPath = GMSMutablePath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.mapStyle = GMSMapStyle.myTheme
        
        addMarkersOnMap(locations: [a, b])
        getRoute(coordinates: [a, b])
    }
    
    //STEP 1: - GET ROUTES
    func getRoute(coordinates: [CLLocationCoordinate2D]) {
        googleMapsNetworkAgent.getRouteFromGoogleMaps(coordinates: coordinates)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let this = self else {return}
                if let status = response.status, status == "OK" {
                    let overviewPolyline = response.routes?.first?.overviewPolyline?.points
                    this.drawRouteOnMap(route: overviewPolyline)
                } else {
                    debugPrint("API request successfully, but get no result!")
                }
            }, onError: { error in
                debugPrint(error)
            }).disposed(by: disposeBag)
    }
    
    //STEP 2: - DRAW A ROUTE ON THE MAP
    func drawRouteOnMap(route: String?) {
        guard let route = route else {return}
        guard let path = GMSPath(fromEncodedPath: route) else {return}
        self.path = path
        
        polyline = GMSPolyline(path: path)
        polyline.strokeColor = .gray
        polyline.strokeWidth = 2
        polyline.map = mapView
        
        // (Optional) Add bounds and insets to let the route is at the center of the map
        let bounds = GMSCoordinateBounds(path: path)
        let insets = UIEdgeInsets(top: 20, left: 40, bottom: 20, right: 40)
        let camera = GMSCameraUpdate.fit(bounds, with: insets)
        mapView.animate(with: camera)
        
        //STEP 3: - ANIMATIONS
        startAnimationTimer()
    }
    
    //STEP 3: - ANIMATIONS
    @objc func animatePolylinePath() {
        //Iterate each valid coordinate on the path
        if i < path.count() {
            newPath.add(path.coordinate(at: i))
            newPolyline.path = newPath
            newPolyline.strokeColor = UIColor.black
            newPolyline.strokeWidth = 4
            newPolyline.map = mapView
            i += 1
        } else {
            resetTimer()
            startAnimationTimer()
        }
    }
    
    @objc func animatePolylineWithGradient() {
        //Iterate each valid coordinate on the path
        if i < path.count() {
            newPath.add(path.coordinate(at: i))
            newPolyline.path = newPath
            newPolyline.strokeWidth = 4
            newPolyline.spans = [GMSStyleSpan(style: .gradient(from: UIColor(rgb: 0x38726E), to: UIColor(rgb: 0x404969)))]
            newPolyline.map = mapView
            i += 1
        } else {
            resetTimer()
            startAnimationTimer()
        }
    }
    
    @objc func animatePolylineDashAnimation() {
        //Iterate each valid coordinate on the path
        if i < path.count() {
            newPath.add(path.coordinate(at: i))
            newPolyline.path = newPath
            newPolyline.strokeWidth = 4

            let dashLength = calculateDashLength(zoomLevel: mapView.camera.zoom)
            let clearDashLength = Int(Double(dashLength) * 0.5)
            let lengths = [dashLength, clearDashLength] // Play with this for dotted line
            let greenSpan = GMSStrokeStyle.solidColor(UIColor(rgb: 0x38726E))
            let clearSpan = GMSStrokeStyle.solidColor(UIColor.clear)
            newPolyline.spans = GMSStyleSpans(newPolyline.path!, [greenSpan, clearSpan], lengths as [NSNumber], .rhumb)
            newPolyline.map = mapView
            i += 1
        } else {
            resetTimer()
            startAnimationTimer()
        }
    }
    
    func calculateDashLength(zoomLevel: Float) -> Int {
        let maxDashLength : Float = 750000.0
        let a = zoomLevel < 18.0 ? powf(2.0, zoomLevel - 1) : powf(2.0, zoomLevel - 2)
        return Int(maxDashLength / a) > 50 ? Int(maxDashLength / a) : 50
    }
    
    func resetTimer() {
        timer.invalidate()
        i = 0
        newPath.removeAllCoordinates()
    }
    
    func startAnimationTimer() {
        polyline.map = nil
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.animatePolylineDashAnimation), userInfo: nil, repeats: true)
    }
    
    func addMarkersOnMap(locations: [CLLocationCoordinate2D]){
        for location in locations {
            let marker = GMSMarker(position: location)
            marker.icon = UIImage(named: "ic_ball_pin")
            marker.map = mapView
        }
    }
}

extension GMSMapStyle {
    static var myTheme: GMSMapStyle! {
        do {
            let filePath = Bundle.main.path(forResource: "mapStyle", ofType: "json")
            let fileContent = try String(contentsOfFile: filePath!, encoding: String.Encoding.utf8)
            return try! GMSMapStyle(jsonString: fileContent)
        } catch let error {
            print("json serialization error: \(error)")
            return nil
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    convenience init(hex string: String) {
        var hex = string.hasPrefix("#")
            ? String(string.dropFirst())
            : string
        guard hex.count == 3 || hex.count == 6
            else {
                self.init(white: 1.0, alpha: 0.0)
                return
        }
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }
        
        self.init(
            red:   CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0,
            green: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0,
            blue:  CGFloat((Int(hex, radix: 16)!) & 0xFF) / 255.0, alpha: 1.0)
    }
}
