//
//  PlacePhoto.swift
//  peaca
//
//  Created by kimkkikki on 2017. 11. 30..
//  Copyright © 2017년 peaca. All rights reserved.
//

import Foundation
import SwiftDate

class PlacePhoto {
    var id:String
    var placeId:String
    var imageUrl:String
    var attribution:String?
    var attributionUrl:String?
    var created:DateInRegion
    
    init(dict:[String:Any]) {
        self.id = dict["id"] as! String
        self.placeId = dict["place"] as! String
        self.imageUrl = dict["image"] as! String
        self.imageUrl =  NetworkManager.getUrl() + self.imageUrl
        self.attribution = dict["attribution"] as? String
        self.attributionUrl = dict["attribution_url"] as? String
        self.created = DateInRegion(string: dict["created"] as! String, format: .iso8601(options: [.withInternetDateTime]))!.toRegion(Region.Local())
    }
}

extension PlacePhoto: CustomStringConvertible {
    public var description: String {
        return "{'id':'\(self.id)', 'placeId':'\(self.placeId)', 'imageUrl':'\(self.imageUrl)', 'attribution': \(String(describing: self.attribution)), 'attributionUrl': \(String(describing: self.attributionUrl)), 'created':'\(self.created)'}"
    }
}
