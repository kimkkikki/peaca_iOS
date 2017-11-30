//
//  Place.swift
//  peaca
//
//  Created by kimkkikki on 2017. 11. 30..
//  Copyright © 2017년 peaca. All rights reserved.
//

import Foundation
import SwiftDate
import MapKit

class Place {
    var id:String
    var name:String
    var point:CLLocation
    var utcOffset:Int
    var address:String
    var created:DateInRegion
    
    init(dict:[String:Any]) {
        self.id = dict["id"] as! String
        self.name = dict["name"] as! String
        self.utcOffset = dict["utc_offset"] as! Int
        self.address = dict["address"] as! String
        self.created = DateInRegion(string: dict["created"] as! String, format: .iso8601(options: [.withInternetDateTime]))!.toRegion(Region.Local())
        let _point = dict["point"] as! String
        let split = _point.components(separatedBy: ",")
        self.point = CLLocation(latitude: Double(split[1])!, longitude: Double(split[0])!)
    }
}

extension Place: CustomStringConvertible {
    public var description: String {
        return "{'id':'\(self.id)', 'name':'\(self.name)', 'utcOffset':'\(self.utcOffset)', 'address': \(self.address), 'point': \(self.point), 'created':'\(self.created)'}"
    }
}
