//
//  NetworkManager.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 23..
//  Copyright © 2017년 peaca. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyUserDefaults
import KRProgressHUD

enum APP_TARGET {
    case LOCAL
    case PRODUCTION
}

let APP_STATUS = APP_TARGET.LOCAL

class NetworkManager {
    
    class private func getUrl() -> String {
        if APP_STATUS == APP_TARGET.LOCAL {
            return "http://localhost:8000"
        } else if APP_STATUS == APP_TARGET.PRODUCTION {
            return "https://peaca.me"
        } else {
            return "https://peaca.me"
        }
    }
    
    class private func handleError(error:Error?) {
        print("error : \(String(describing: error))")
    }
    
    class private func sendToServer(endPoint: String, method: HTTPMethod, params: Parameters?, completion:@escaping (Any?) -> ()) {
        KRProgressHUD.show()
        Alamofire.request(getUrl() + endPoint, method: method, parameters: params, encoding: JSONEncoding.default, headers:Defaults[.header] as? HTTPHeaders).responseJSON { (response) in
            if response.error == nil {
                completion(response.result.value)
                KRProgressHUD.dismiss()
            } else {
                handleError(error: response.error)
                KRProgressHUD.dismiss()
            }
        }
    }
    
    class func getUser(completion:@escaping ([String:Any]) -> ()) {
        sendToServer(endPoint: "/apis/user", method: .get, params: nil) { (value) in
            if let json = value as? [String: Any] {
                completion(json)
            }
        }
    }
    
    class func postUser(params:Parameters, completion:@escaping ([String:Any]) -> ()) {
        sendToServer(endPoint: "/apis/user", method: .post, params: params) { (value) in
            if let json = value as? [String: Any] {
                completion(json)
            }
        }
    }
    
    class func getParty(completion:@escaping (NSArray) -> ()) {
        sendToServer(endPoint: "/apis/party", method: .get, params: nil) { (value) in
            if let jsonArray = value as? NSArray {
                completion(jsonArray)
            }
        }
    }
    
    class func postParty(params:Parameters, completion:@escaping ([String:Any]) -> ()) {
        sendToServer(endPoint: "/apis/party", method: .post, params: params) { (value) in
            if let json = value as? [String:Any] {
                completion(json)
            }
        }
    }
    
    class func getPartyMembers(partyId:Int, completion:@escaping (NSArray) -> ()) {
        sendToServer(endPoint: "/apis/party/\(partyId)", method: .get, params: nil) { (value) in
            if let jsonArray = value as? NSArray {
                completion(jsonArray)
            }
        }
    }
    
    class func postPartyMember(partyId:Int, completion:@escaping ([String:Any]) -> ()) {
        sendToServer(endPoint: "/apis/party/\(partyId)", method: .post, params: nil) { (value) in
            if let json = value as? [String:Any] {
                completion(json)
            }
        }
    }
    
    class func getMyList(completion:@escaping (NSArray) -> ()) {
        sendToServer(endPoint: "/apis/user/party", method: .get, params: nil) { (value) in
            if let jsonArray = value as? NSArray {
                completion(jsonArray)
            }
        }
    }
}
