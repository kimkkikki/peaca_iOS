//
//  AlertManager.swift
//  peaca
//
//  Created by kimkkikki on 2017. 12. 1..
//  Copyright © 2017년 peaca. All rights reserved.
//

import Foundation
import CDAlertView

class AlertManager {
    class func showDefaultOKAlert(title: String, message: String) {
        let alert = CDAlertView(title: title, message: message, type: .custom(image: UIImage(named:"peacaSymbol")!))
        let doneAction = CDAlertViewAction(title: "OK")
        alert.add(action: doneAction)
        alert.show()
    }
}
