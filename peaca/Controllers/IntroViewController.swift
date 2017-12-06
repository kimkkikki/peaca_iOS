//
//  IntroViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 8. 22..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import Firebase
import Alamofire
import SwiftyUserDefaults
import MapKit

class IntroViewController: UIViewController {
    
    var firebaseUser: User!
    
    let locationManager = CLLocationManager()
    var myLocation:CLLocationCoordinate2D?
    
    let readPermissions:[ReadPermission] = [.publicProfile, .email, .userBirthday, .userPhotos, .userAboutMe, .userLikes]
    
    func goMain() {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "go_main", sender: nil)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let naviController = segue.destination as? UINavigationController {
            if let controller = naviController.topViewController as? MainViewController {
                controller.myLocation = self.myLocation
            }
        }
    }
    
    func handleResponse(_ json:[String:Any]) {
        Defaults[.id] = json["id"] as? String
        Defaults[.token] = json["token"] as? String
        Defaults[.secret] = json["secret"] as? String
        Defaults[.name] = json["name"] as? String
        Defaults[.picture_url] = json["picture_url"] as? String
        let header: HTTPHeaders = ["id": Defaults[.id]!, "token": Defaults[.token]!]
        Defaults[.header] = header
        
        if let serverPushToken = json["push_token"] as? String {
            if serverPushToken != Messaging.messaging().fcmToken, let token = Messaging.messaging().fcmToken {
                var params = json
                params["push_token"] = token
                NetworkManager.postUser(params: params, completion: nil)
            }
            
        } else {
            if let token = Messaging.messaging().fcmToken {
                var params = json
                params["push_token"] = token
                NetworkManager.postUser(params: params, completion: nil)
            }
        }
        
        self.goMain()
    }
    
    func checkFacebookPermission(_ token:AccessToken) -> Bool {
        guard let grantedPermissions = token.grantedPermissions else {
            return false
        }
        
        if !grantedPermissions.contains("user_photos") {
            print("no granted user_photos")
            return false
        } else if !grantedPermissions.contains("user_birthday") {
            print("no granted user_birthday")
            return false
        } else if !grantedPermissions.contains("user_about_me") {
            print("no granted user_about_me")
            return false
        } else if !grantedPermissions.contains("user_likes") {
            print("no granted user_likes")
            return false
        }
        
        return true
    }
    
    func checkFacebookPermission() -> Bool {
        guard let token = AccessToken.current else {
            return false
        }
        
        return self.checkFacebookPermission(token)
    }
    
    func checkUserDefaults() -> Bool {
        if Defaults[.id] != nil && Defaults[.token] != nil {
            return true
        }
        
        return false
    }
    
    func checkFirebaseAuth() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        }
        
        return false
    }
    
    var callCount = 0
    var postBody = [String:Any]()
    
    func Login(photos: [ProfilePhoto]?, profile: [String:Any]?) {
        if let _photos = photos {
            var dictArray = [[String:String]]()
            
            for item in _photos {
                var dict = [String:String]()
                dict["id"] = item.id
                dict["source"] = item.source
                dict["created"] = item.created.string(format: .iso8601Auto)
                dictArray.append(dict)
            }
            
            self.postBody["photos"] = dictArray
        }
        
        if let _profile = profile {
            self.postBody["id"] = self.firebaseUser.uid
            self.postBody["name"] = _profile["name"] as! String
            self.postBody["email"] = _profile["email"] as! String
            self.postBody["birthday"] = _profile["birthday"] as! String
            self.postBody["gender"] = _profile["gender"] as! String
            
            if let languages = _profile["languages"] as? NSArray {
                for language in languages {
                    self.postBody["language"] = language
                }
            }
            
            if let picture = _profile["picture"] as? [String: Any] {
                if let pictureData = picture["data"] as? [String: Any] {
                    self.postBody["picture_url"] = pictureData["url"] as! String
                }
            }
            
            if let pushToken = Messaging.messaging().fcmToken {
                self.postBody["push_token"] = pushToken
            }
        }
        
        if self.callCount != 0 {
            NetworkManager.stopProgress()
            print("post body : \(self.postBody)")
            NetworkManager.postUser(params: self.postBody, completion: { (json) in
                self.handleResponse(json)
            })
        } else {
            callCount += 1
        }
    }
    
    func getProfilePicturesGraph(_ albumId: String) {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "\(albumId)/photos", parameters: ["fields": "source,created_time"])) { httpResponse, result in
            
            switch result {
            case .success(let response):
                if let album = response.dictionaryValue {
                    if let profiles = album["data"] as? NSArray {
                        var photos = [ProfilePhoto]()
                        
                        for item in profiles {
                            if let profile = item as? [String:Any] {
                                let _profile = ProfilePhoto(profile)
                                photos.append(_profile)
                            }
                        }
                        
                        self.Login(photos: photos, profile: nil)
                        return
                    }
                }
                
                print("No Data")
                self.Login(photos: nil, profile: nil)
                
            case .failed(let error):
                print("Graph Request Failed: \(error)")
                NetworkManager.stopProgress()
            }
        }
        connection.start()
    }
    
    func getFacebookData() {
        NetworkManager.showProgress()
        self.callCount = 0
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "me/albums", parameters: ["fields": "created_time,name"])) { httpResponse, result in
            switch result {
            case .success(let response):
                guard let dict = response.dictionaryValue else {
                    print("No albums")
                    self.Login(photos: nil, profile: nil)
                    return
                }
                
                guard let array = dict["data"] as? NSArray else {
                    print("No albums")
                    self.Login(photos: nil, profile: nil)
                    return
                }
                
                for item in array {
                    if let album = item as? [String:Any] {
                        let name = album["name"] as! String
                        if name.contains("Profile Pictures") {
                            let id = album["id"] as! String
                            self.getProfilePicturesGraph(id)
                            print("profile find!! \(id)")
                            return
                        }
                    }
                }
                
                print("No albums")
                self.Login(photos: nil, profile: nil)
                
            case .failed(let error):
                print("Graph Request Failed: \(error)")
                NetworkManager.stopProgress()
            }
        }
        connection.add(GraphRequest(graphPath: "me", parameters: ["fields":"email,name,birthday,gender, picture.type(large),languages,location"])) { httpResponse, result in
            switch result {
            case .success(let response):
                if let dict = response.dictionaryValue {
                    self.Login(photos: nil, profile: dict)
                    return
                }
                
                self.Login(photos: nil, profile: nil)
                
            case .failed(let error):
                print("Graph Request Failed: \(error)")
                NetworkManager.stopProgress()
            }
        }
        connection.start()
    }
    
    @IBAction func termsClick() {
        print("click terms")
    }
    
    @IBAction func policyClick() {
        print("click policy")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            self.locationManager.startUpdatingLocation()
        }
        
        if self.checkFacebookPermission() && self.checkUserDefaults() && self.checkFirebaseAuth() {
            self.firebaseUser = Auth.auth().currentUser
            // TODO: 데이터는 로그인 할때만?
//            self.getFacebookData()
            self.goMain()
        } else {
            print("need LogIn")
        }
    }
    
    @IBAction func loginButtonClick() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions:readPermissions, viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
                AlertManager.showDefaultOKAlert(title: "로그인 실패", message: "Facebook 로그인에 실패하였습니다.")
                
            case .cancelled:
                print("User cancelled login.")
                
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                
                print("grantedPermissions : \(grantedPermissions)")
                print("declinedPermissions : \(declinedPermissions)")
                print("accessToken : \(accessToken)")
                
                if self.checkFacebookPermission(accessToken) {
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                    Firebase.Auth.auth().signIn(with: credential, completion: { (user, error) in
                        if error != nil {
                            print(error!)
                        }
                        else {
                            print("facebook login success")
                            
                            self.firebaseUser = Auth.auth().currentUser
                            self.getFacebookData()
                        }
                    })
                } else {
                    AlertManager.showDefaultOKAlert(title: "권한 부족", message: "필수 권한이 누락되어있습니다.")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension IntroViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = manager.location?.coordinate
        self.myLocation = location
        manager.stopUpdatingLocation()
    }
}
