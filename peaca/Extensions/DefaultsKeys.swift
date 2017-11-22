//
//  DefaultsKeys.swift
//  peaca
//
//  Created by kimkkikki on 2017. 9. 11..
//  Copyright © 2017년 peaca. All rights reserved.
//

import SwiftyUserDefaults
import Alamofire

extension DefaultsKeys {
    static let id = DefaultsKey<String?>("id")
    static let token = DefaultsKey<String?>("token")
    static let secret = DefaultsKey<String?>("secret")
    static let name = DefaultsKey<String?>("name")
    static let picture_url = DefaultsKey<String?>("picture_url")
    static let header = DefaultsKey<[String:Any]>("header")
}
