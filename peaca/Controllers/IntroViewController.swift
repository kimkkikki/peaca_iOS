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

class IntroViewController: UIViewController {
    
    var firebaseUser: User!
    var isLogined = false
    
    func goMain() {
        self.performSegue(withIdentifier: "go_main", sender: nil)
    }
    
    func handleResponse(_ response:DataResponse<Any>) {
        if response.error == nil {
            if let json = response.result.value as? [String: Any] {
                print(json)
                
                Defaults[.id] = json["id"] as? String
                Defaults[.token] = json["token"] as? String
                Defaults[.name] = json["name"] as? String
                Defaults[.picture_url] = json["picture_url"] as? String
                let header: HTTPHeaders = ["id": Defaults[.id]!, "token": Defaults[.token]!]
                Defaults[.header] = header
                
                self.goMain()
            }
        } else {
            // ERROR
        }
    }
    
    func facebookLoginSuccess() {
        if isLogined {
            print("is Logined ")
            Alamofire.request("http://localhost:8000/apis/user", headers:Defaults[.header] as? HTTPHeaders).responseJSON { (response) in
                self.handleResponse(response)
            }
            
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
                        
                        print("params : \(params)")
                        
                        Alamofire.request("http://localhost:8000/apis/user", method: .post, parameters: params, encoding:JSONEncoding.default).responseJSON { (response) in
                            self.handleResponse(response)
                        }
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

