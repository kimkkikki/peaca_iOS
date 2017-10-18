//
//  UIColor+Peaca.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 16..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit

extension UIColor {
    func as5ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 5))
        let ctx = UIGraphicsGetCurrentContext()
        self.setFill()
        ctx!.fill(CGRect(x: 0, y: 0, width: 1, height: 5))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    @nonobjc class var uglyYellow: UIColor {
        return UIColor(red: 218.0 / 255.0, green: 224.0 / 255.0, blue: 0.0, alpha: 1.0)
    }
}
