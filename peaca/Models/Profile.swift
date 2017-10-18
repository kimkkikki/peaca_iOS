//
//  User.swift
//  peaca
//
//  Created by kimkkikki on 2017. 9. 20..
//  Copyright © 2017년 peaca. All rights reserved.
//

import Foundation
import SwiftDate

class Profile {
    var id:String
    var name:String
    var nickname:String?
    var gender:String
    var pictureUrl:String
    var created:DateInRegion
    
    init(dict:[String:Any]) {
        self.id = dict["id"] as! String
        self.name = dict["name"] as! String
        self.pictureUrl = dict["picture_url"] as! String
        self.gender = dict["gender"] as! String
        self.created = DateInRegion(string: dict["created"] as! String, format: .iso8601(options: [.withInternetDateTime]))!.toRegion(Region.Local())
        
        self.nickname = dict["nickname"] as? String
    }
}

extension Profile: CustomStringConvertible {
    public var description: String {
        return "{'id':'\(self.id)', 'name':'\(self.name)', 'nickname':'\(String(describing: self.nickname))', 'pictureUrl':'\(self.pictureUrl)', 'gender':'\(gender)', 'created':'\(self.created)'}"
    }
}
