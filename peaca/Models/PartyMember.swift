//
//  PartyMember.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 12..
//  Copyright © 2017년 peaca. All rights reserved.
//

import Foundation

class PartyMember {
    var id:Int
    var partyId:Int
    var status:String
    var userId:String
    var userPictureUrl:String
    
    init(_ dict:[String:Any]) {
        self.id = dict["id"] as! Int
        self.partyId = dict["party"] as! Int
        self.status = dict["status"] as! String
        self.userId = dict["user"] as! String
        self.userPictureUrl = dict["user_picture_url"] as! String
    }
}

extension PartyMember: CustomStringConvertible {
    public var description: String {
        return "{'id':'\(self.id)', 'partyId':'\(self.partyId)', 'status':'\(self.status)', 'userId':'\(self.userId)', 'userPictureUrl':'\(self.userPictureUrl)'}"
    }
}
