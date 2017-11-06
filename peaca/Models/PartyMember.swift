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
    var user:Profile
    var userPictureUrl:String
    
    var party:Party?
    
    init(_ dict:[String:Any]) {
        self.id = dict["id"] as! Int
        if let partyId = dict["party"] as? Int {
            self.partyId = partyId
        } else {
            let party = Party(dict: dict["party"] as! [String : Any])
            self.partyId = party.id
            self.party = party
        }
        self.status = dict["status"] as! String
        let userDict = dict["user"] as! [String : Any]
        self.user = Profile(dict:userDict)
        self.userPictureUrl = dict["user_picture_url"] as! String
    }
}

extension PartyMember: CustomStringConvertible {
    public var description: String {
        return "{'id':'\(self.id)', 'partyId':'\(self.partyId)', 'status':'\(self.status)', 'user':'\(self.user)', 'userPictureUrl':'\(self.userPictureUrl)'}"
    }
}
