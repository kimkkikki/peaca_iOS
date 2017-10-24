//
//  PeacaIndicator.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 18..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit

class PeacaIndicator:UIView {
    
    var viewController:UIViewController
    
    init(on viewController:UIViewController) {
        self.viewController = viewController
        
        let screenSize: CGRect = UIScreen.main.bounds
        let frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        let backgroundView = UIView(frame: frame)
        backgroundView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
        self.addSubview(backgroundView)
        
        let imageView = UIImageView.init(image: UIImage(named: "peacaSymbol"))
        imageView.center = self.center
        self.addSubview(imageView)
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = 1.0
        rotateAnimation.repeatCount = Float.infinity
        
        imageView.layer.add(rotateAnimation, forKey: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation() {
        viewController.view.addSubview(self)
    }
    
    func stopAnimation() {
        self.removeFromSuperview()
    }
}
