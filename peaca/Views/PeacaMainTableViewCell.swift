//
//  PeacaMainTableViewCell.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 16..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import GooglePlaces
import SwiftDate

class PeacaMainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var profileName:UILabel!
    @IBOutlet weak var locationLabel:UILabel!
    @IBOutlet weak var personsLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var locationImage:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImage.layer.cornerRadius = self.profileImage.frame.height/2
        self.profileImage.clipsToBounds = true
    }
    
    func setParty(_ party:Party) {
        self.locationImage.image = nil
        self.profileImage.image = nil
        
        self.titleLabel.text = party.title
        
        if party.writer.nickname != nil {
            self.profileName.text = party.writer.nickname
        } else {
            self.profileName.text = party.writer.name
        }
        
        self.profileImage.sd_setImage(with: URL(string:party.writer.pictureUrl), completed: nil)
        
        if party.destinationImage == nil {
            Common.getPhotoWithGooglePlaceID(party.destinationId) { (photo) in
                self.locationImage.image = photo
                party.destinationImage = photo
            }
        } else {
            self.locationImage.image = party.destinationImage
        }
        
        if party.destination == nil {
            Common.getPlaceWithGooglePlaceID(party.destinationId, completion: { (place) in
                self.locationLabel.text = place.name
                party.destination = place
            }) { (error) in
                self.locationLabel.text = party.destinationName
            }
        } else {
            self.locationLabel.text = party.destination?.name
        }
     
        self.dateLabel.text = party.date.string(format: .custom("yyyy.MM.dd (E) hh:mma"))
        
        // TODO: Status check 구현
        self.statusLabel.backgroundColor = UIColor(patternImage: UIImage(named:"ing_label_background")!)
        self.statusLabel.backgroundColor = UIColor(patternImage: UIImage(named:"close_label_background")!)
        
        // TODO: member count 필요함
        self.personsLabel.text = "\(party.persons)명"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
