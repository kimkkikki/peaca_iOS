//
//  MyListTableViewCell.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 23..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import SwipeCellKit

class MyListTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var statusLabel:UILabel!
    @IBOutlet weak var locationImageView:UIImageView!
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nicknameLabel:UILabel!
    @IBOutlet weak var personsLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var enterButton:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
