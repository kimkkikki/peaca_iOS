//
//  ProfileViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 12..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var profile:Profile?
    var profileId:String?
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var nicknameLabel:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.height/2
        self.profileImage.clipsToBounds = true
        
        if let obj = self.profile {
            self.profileImage.sd_setImage(with: URL(string:obj.pictureUrl), completed: nil)
            self.nicknameLabel.text = obj.name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
}
