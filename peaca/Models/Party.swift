//
//  Party.swift
//  peaca
//
//  Created by kimkkikki on 2017. 8. 30..
//  Copyright © 2017년 peaca. All rights reserved.
//

import Foundation
import GooglePlaces
import SwiftDate

class Party {
    var id:Int
    var title:String
    var contents:String
    var writer:Profile
    var persons:Int
    var count:Int
    var gender:String
    var date:Date
    var destinationId:String
    var destinationName:String
    var destinationPoint:CLLocation
    var destinationAddress:String
    var sourceId:String?
    var sourcePoint:String?
    var sourceAddress:String?
    var created:DateInRegion
    
    var destinationImage:UIImage?
    var destination:GMSPlace?
    
    init(dict:[String:Any]) {
        self.id = dict["id"] as! Int
        self.title = dict["title"] as! String
        self.contents = dict["contents"] as! String
        self.persons = dict["persons"] as! Int
        if let count = dict["count"] as? Int {
            self.count = count
        } else {
            self.count = 0
        }
        self.gender = dict["gender"] as! String
        let dateInRegion = DateInRegion(string: dict["date"] as! String, format: .iso8601(options: [.withInternetDateTime]))!
        self.date = dateInRegion.absoluteDate
        self.destinationId = dict["destination_id"] as! String
        self.destinationName = dict["destination_name"] as! String
        let point = dict["destination_point"] as! String
        let split = point.components(separatedBy: ",")
        self.destinationPoint = CLLocation(latitude: Double(split[1])!, longitude: Double(split[0])!)
        self.destinationAddress = dict["destination_address"] as! String
        self.created = DateInRegion(string: dict["created"] as! String, format: .iso8601(options: [.withInternetDateTime]))!.toRegion(Region.Local())
        
        self.sourceId = dict["source_id"] as? String
        self.sourcePoint = dict["source_point"] as? String
        self.sourceAddress = dict["source_address"] as? String
        
        let userDict = dict["writer"] as! [String:Any]
        self.writer = Profile(dict:userDict)
    }
}

extension Party: CustomStringConvertible {
    public var description: String {
        return "{'id':'\(self.id)', 'title':'\(self.title)', 'contents':'\(self.contents)', 'persons': \(self.persons), 'count': \(self.count), 'gender':'\(self.gender)', 'date':'\(self.date)', 'created':'\(self.created)', 'writer':\(self.writer)}"
    }
}
