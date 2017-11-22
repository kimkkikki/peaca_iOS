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
import MapKit
import SystemConfiguration

enum APP_TARGET {
    case LOCAL
    case PRODUCTION
}

typealias DictCompletion = ([String:Any]) -> ()
typealias ArrayCompletion = (NSArray) -> ()
typealias VoidCompletion = () -> ()

let APP_STATUS = APP_TARGET.PRODUCTION

class NetworkManager {
    
    class private func getUrl() -> String {
        switch APP_STATUS {
        case .LOCAL:
            return "http://localhost:8000"
        case .PRODUCTION:
            return "https://peaca.me"
        }
    }
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
    class private func handleError(error:Error?) {
        let alert = CDAlertView(title: "error!", message: String(describing: error), type: .custom(image: UIImage(named:"peacaSymbol")!))
        let doneAction = CDAlertViewAction(title: "OK")
        alert.add(action: doneAction)
        alert.show()
    }
    
    class private func isNotConnectToNetwork() {
        let alert = CDAlertView(title: "네트워크에 연결되어 있지 않습니다.", message: "앱 사용을 위해 네트워크 접속이 필요합니다.", type: .custom(image: UIImage(named:"peacaSymbol")!))
        let doneAction = CDAlertViewAction(title: "OK")
        alert.add(action: doneAction)
        alert.show()
    }
    
    class private func sendToServer(endPoint: String, method: HTTPMethod, params: Parameters?, progress: Bool, completion:@escaping (Any?) -> ()) {
        if progress {
            KRProgressHUD.show()
        }
        if isConnectedToNetwork() {
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
        } else {
            isNotConnectToNetwork()
        }
    }
    
    class func getUser(completion: @escaping DictCompletion) {
        sendToServer(endPoint: "/apis/user", method: .get, params: nil, progress: true) { (value) in
            if let json = value as? [String: Any] {
                completion(json)
            }
        }
    }
    
    class func postUser(params:Parameters, completion: DictCompletion?) {
        sendToServer(endPoint: "/apis/user", method: .post, params: params, progress: true) { (value) in
            if let json = value as? [String: Any] {
                completion?(json)
            }
        }
    }
    
    class func getParty(page:Int, location:CLLocationCoordinate2D?, filter: Filter, completion: @escaping ArrayCompletion) {
        var endPoint = "/apis/party?page=\(page)"
        
        if let mLocation = location {
            endPoint = endPoint + "&latitude=\(mLocation.latitude)&longitude=\(mLocation.longitude)"
        }
        
        if let keyword = filter.searchString {
            if let urlEncodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                endPoint = endPoint + "&keyword=\(urlEncodedKeyword)"
            }
        }
        
        if let cityName = filter.searchCity {
            if let urlEncodedKeyword = cityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                endPoint = endPoint + "&keyword=\(urlEncodedKeyword)"
            }
        }
        
        if let order = filter.order {
            switch order {
            case "거리순":
                endPoint = endPoint + "&order=distance"
                break
            case "최신순":
                endPoint = endPoint + "&order=time"
                break
            default:
                break
            }
        }
        
        sendToServer(endPoint: endPoint, method: .get, params: nil, progress: true) { (value) in
            if let jsonArray = value as? NSArray {
                completion(jsonArray)
            }
        }
    }
    
    class func postParty(params:Parameters, completion:@escaping DictCompletion) {
        sendToServer(endPoint: "/apis/party", method: .post, params: params, progress: true) { (value) in
            if let json = value as? [String:Any] {
                completion(json)
            }
        }
    }
    
    class func getPartyMembers(partyId:Int, completion:@escaping ArrayCompletion) {
        sendToServer(endPoint: "/apis/party/\(partyId)", method: .get, params: nil, progress: true) { (value) in
            if let jsonArray = value as? NSArray {
                completion(jsonArray)
            }
        }
    }
    
    class func postPartyMember(partyId:Int, completion:@escaping DictCompletion) {
        sendToServer(endPoint: "/apis/party/\(partyId)", method: .post, params: nil, progress: true) { (value) in
            if let json = value as? [String:Any] {
                completion(json)
            }
        }
    }
    
    class func getMyList(completion:@escaping ArrayCompletion) {
        sendToServer(endPoint: "/apis/user/party", method: .get, params: nil, progress: true) { (value) in
            if let jsonArray = value as? NSArray {
                completion(jsonArray)
            }
        }
    }
    
    class func sendPushToPartyMembers(partyId:Int, params:Parameters, completion:VoidCompletion?) {
        sendToServer(endPoint: "/apis/party/\(partyId)/push", method: .post, params: params, progress: false) { (value) in
            completion?()
        }
    }
}
