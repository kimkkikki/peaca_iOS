//
//  ProfileViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 12..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
}
