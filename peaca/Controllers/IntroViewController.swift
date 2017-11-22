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
import FBSDKLoginKit
import Firebase
import Alamofire
import SwiftyUserDefaults
import MapKit

class IntroViewController: UIViewController {
    
    var firebaseUser: User!
    var isLogined = false
    
    let locationManager = CLLocationManager()
    var myLocation:CLLocationCoordinate2D?
    
    func goMain() {
        self.performSegue(withIdentifier: "go_main", sender: nil)
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
    
    func facebookLoginSuccess() {
        if isLogined {
            print("is Logined ")
            NetworkManager.getUser(completion: { (json) in
                self.handleResponse(json)
            })
            
        } else {
            FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"email,name,birthday,gender, picture.type(large)"]).start(completionHandler: { (connection:FBSDKGraphRequestConnection?, result:Any?, error:Error?) in
                if (error == nil) {
                    if let result1 = result as? Dictionary<String, AnyObject> {
                        print(result1)
                        var params: Parameters = ["id": self.firebaseUser.uid,
                                                  "name": result1["name"] as! String,
                                                  "email": result1["email"] as! String,
                                                  "birthday": result1["birthday"] as! String,
                                                  "gender": result1["gender"] as! String]
                        
                        if let picture = result1["picture"] as? [String: Any] {
                            if let pictureData = picture["data"] as? [String: Any] {
                                params["picture_url"] = pictureData["url"] as! String
                            }
                        }
                        
                        if let pushToken = Messaging.messaging().fcmToken {
                            params["push_token"] = pushToken
                        }
                        
                        print("params : \(params)")
                        
                        NetworkManager.postUser(params: params, completion: { (json) in
                            self.handleResponse(json)
                        })
                    }
                } else {
                    print("Facebook Graph Get Error")
                }
            })
        }
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
        
        if Defaults[.id] != nil && Defaults[.token] != nil {
            isLogined = true
        } else {
            print("need save id & token")
        }
        
        if (FBSDKAccessToken.current() != nil && Auth.auth().currentUser != nil) {
            // User is logged in, do work such as go to next view controller.
            print("user is logged")
            firebaseUser = Auth.auth().currentUser
            facebookLoginSuccess()
            
        } else {
            print("need Login")
        }
    }
    
    @IBAction func loginButtonClick() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions:[.publicProfile, .email, .userBirthday], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                
                if !grantedPermissions.contains("email") || !grantedPermissions.contains("public_profile") || !grantedPermissions.contains("user_birthday") {
                    // Do work
                    print("need permission")
                    
                } else {
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    Firebase.Auth.auth().signIn(with: credential, completion: { (user, error) in
                        if error != nil {
                            print(error!)
                        }
                        else {
                            print("facebook login success")
                            
                            self.firebaseUser = Auth.auth().currentUser
                            self.facebookLoginSuccess()
                        }
                    })
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

//extension IntroViewController: FBSDKLoginButtonDelegate {
//    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
//
//        print("User Logged In")
//
//        if ((error) != nil) {
//            // Process error
//        } else if result.isCancelled {
//            // Handle cancellations
//        } else {
//            if !result.grantedPermissions.contains("email") || !result.grantedPermissions.contains("public_profile") || !result.grantedPermissions.contains("user_birthday") {
//                // Do work
//                print("need permission")
//            }
//
//            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//            Firebase.Auth.auth().signIn(with: credential, completion: { (user, error) in
//                if error != nil {
//                    print(error!)
//                }
//                else {
//                    print("facebook login success")
//
//                    self.firebaseUser = Auth.auth().currentUser
//                    self.facebookLoginSuccess()
//                }
//            })
//        }
//    }
//
//    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
//        print("User Logged Out")
//    }
//}

