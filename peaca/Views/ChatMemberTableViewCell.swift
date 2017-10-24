//
//  ChatMemberTableViewCell.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 19..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import SwipeCellKit

class ChatMemberTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var profileImage:UIImageView! {
        didSet {
            self.profileImage.layer.cornerRadius = self.profileImage.frame.height/2
            self.profileImage.clipsToBounds = true
        }
    }
    @IBOutlet weak var profileName:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
