//
//  MenuViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 16..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate {
    func didSelectMenu(_ selectedMenu:String)
}

class MenuViewController: UIViewController {
    var delegate:MenuViewControllerDelegate?
    
    @IBAction func menuClick(sender:UIButton) {
        self.delegate?.didSelectMenu(sender.restorationIdentifier!)
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func close() {
        self.dismiss(animated: false, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
