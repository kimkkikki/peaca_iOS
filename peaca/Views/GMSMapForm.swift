//
//  GMSMapForm.swift
//  peaca
//
//  Created by kimkkikki on 2017. 9. 6..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Eureka

public class GMSMapFormCell: Cell<Bool>, CellType {
    @IBOutlet weak var mapView:GMSMapView!
    
    public override func setup() {
        super.setup()
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        self.mapView.camera = camera
        self.mapView.isMyLocationEnabled = true
        
        row.value = false
    }
    
    public func setMapPoint(place:GMSPlace) {
        self.mapView.clear()
        self.mapView.camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 12.0)
        
        let position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        let marker = GMSMarker(position: position)
        marker.title = place.name
        marker.icon = UIImage(named: "location_pin_1")
        marker.map = mapView
        
        row.value = true
    }
}

public final class GMSMapFormRow: Row<GMSMapFormCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<GMSMapFormCell>(nibName: "GMSMapForm")
    }
}
