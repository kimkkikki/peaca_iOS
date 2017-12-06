//
//  ProfilePhoto.swift
//  peaca
//
//  Created by kimkkikki on 2017. 12. 5..
//  Copyright © 2017년 peaca. All rights reserved.
//

import Foundation
import SwiftDate

class ProfilePhoto {
    var id: String
    var source: String
    var created: DateInRegion
    
    init(_ dict: [String:Any]) {
        self.id = dict["id"] as! String
        self.source = dict["source"] as! String
        self.created = DateInRegion(string: dict["created_time"] as! String, format: .iso8601Auto)!
    }
}

extension ProfilePhoto: CustomStringConvertible {
    public var description: String {
        return "{'id':'\(self.id)', 'source':'\(self.source)', 'created':'\(self.created)'}"
    }
}
