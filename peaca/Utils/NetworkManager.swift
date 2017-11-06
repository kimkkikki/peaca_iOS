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
import CDAlertView

enum APP_TARGET {
    case LOCAL
    case PRODUCTION
}

let APP_STATUS = APP_TARGET.PRODUCTION

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
        let alert = CDAlertView(title: "error!", message: String(describing: error), type: .custom(image: UIImage(named:"peacaSymbol")!))
        let doneAction = CDAlertViewAction(title: "OK")
        alert.add(action: doneAction)
        alert.show()
    }
    
    class private func sendToServer(endPoint: String, method: HTTPMethod, params: Parameters?, progress: Bool, completion:@escaping (Any?) -> ()) {
        if progress {
            KRProgressHUD.show()
        }
        Alamofire.request(getUrl() + endPoint, method: method, parameters: params, encoding: JSONEncoding.default, headers:Defaults[.header] as? HTTPHeaders).responseJSON { (response) in
            if response.error == nil {
                if progress {
                    KRProgressHUD.dismiss({
                        completion(response.result.value)
                    })
                } else {
                    completion(response.result.value)
                }
            } else {
                if progress {
                    KRProgressHUD.dismiss({
                        handleError(error: response.error)
                    })
                } else {
                    handleError(error: response.error)
                }
            }
        }
    }
    
    class func getUser(completion:@escaping ([String:Any]) -> ()) {
        sendToServer(endPoint: "/apis/user", method: .get, params: nil, progress: true) { (value) in
            if let json = value as? [String: Any] {
                completion(json)
            }
        }
    }
    
    class func postUser(params:Parameters, completion:@escaping ([String:Any]) -> ()) {
        sendToServer(endPoint: "/apis/user", method: .post, params: params, progress: true) { (value) in
            if let json = value as? [String: Any] {
                completion(json)
            }
        }
    }
    
    class func getParty(page:Int, completion:@escaping (NSArray) -> ()) {
        sendToServer(endPoint: "/apis/party?page=\(page)", method: .get, params: nil, progress: true) { (value) in
            if let jsonArray = value as? NSArray {
                completion(jsonArray)
            }
        }
    }
    
    class func postParty(params:Parameters, completion:@escaping ([String:Any]) -> ()) {
        sendToServer(endPoint: "/apis/party", method: .post, params: params, progress: true) { (value) in
            if let json = value as? [String:Any] {
                completion(json)
            }
        }
    }
    
    class func getPartyMembers(partyId:Int, completion:@escaping (NSArray) -> ()) {
        sendToServer(endPoint: "/apis/party/\(partyId)", method: .get, params: nil, progress: true) { (value) in
            if let jsonArray = value as? NSArray {
                completion(jsonArray)
            }
        }
    }
    
    class func postPartyMember(partyId:Int, completion:@escaping ([String:Any]) -> ()) {
        sendToServer(endPoint: "/apis/party/\(partyId)", method: .post, params: nil, progress: true) { (value) in
            if let json = value as? [String:Any] {
                completion(json)
            }
        }
    }
    
    class func getMyList(completion:@escaping (NSArray) -> ()) {
        sendToServer(endPoint: "/apis/user/party", method: .get, params: nil, progress: true) { (value) in
            if let jsonArray = value as? NSArray {
                completion(jsonArray)
            }
        }
    }
    
    class func sendPushToPartyMembers(partyId:Int, params:Parameters, completion:(() -> ())?) {
        sendToServer(endPoint: "/apis/party/\(partyId)/push", method: .post, params: params, progress: false) { (value) in
            completion?()
        }
    }
}
