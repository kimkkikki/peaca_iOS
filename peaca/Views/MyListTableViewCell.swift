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
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setParty(_ party:Party) {
        self.locationImageView.image = nil
        self.profileImageView.image = nil
        
        self.titleLabel.text = party.title
        
        if party.writer.nickname != nil {
            self.nicknameLabel.text = party.writer.nickname
        } else {
            self.nicknameLabel.text = party.writer.name
        }
        
        self.profileImageView.sd_setImage(with: URL(string:party.writer.pictureUrl), completed: nil)
        
        if party.destinationImage == nil {
            Common.getPhotoWithGooglePlaceID(party.destinationId, completion: { (photo) in
                self.locationImageView.image = photo
                party.destinationImage = photo
            }, failure: {
                self.locationImageView.image = UIImage(named: "defaultLocationImage")
                party.destinationImage = UIImage(named: "defaultLocationImage")
            })
        } else {
            self.locationImageView.image = party.destinationImage
        }
        
        self.dateLabel.text = party.date.string(format: .custom("yyyy.MM.dd (E) hh:mma"))
        
        if party.status == "I" {
            self.statusLabel.backgroundColor = UIColor(patternImage: UIImage(named:"ing_label_background")!)
            self.statusLabel.text = "모집중"
        } else {
            self.statusLabel.backgroundColor = UIColor(patternImage: UIImage(named:"close_label_background")!)
            self.statusLabel.text = "모집완료"
        }
        
        self.personsLabel.text = "\(party.count)/\(party.persons)"
    }
}
