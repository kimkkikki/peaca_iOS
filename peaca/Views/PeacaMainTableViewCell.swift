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
    var party:Party?
    
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
        self.party = party
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
            Common.getPhotoWithGooglePlaceID(party.destinationId, completion: { (photo) in
                self.locationImage.image = photo
                party.destinationImage = photo
            }, failure: {
                self.locationImage.image = UIImage(named: "defaultLocationImage")
                party.destinationImage = UIImage(named: "defaultLocationImage")
            })
        } else {
            self.locationImage.image = party.destinationImage
        }
        
        if party.destination == nil {
            Common.getPlaceWithGooglePlaceID(party.destinationId, completion: { (place) in
                self.locationLabel.text = self.getLocationName(name: place.name, distance: party.distance)
                self.party!.destination = place
            }) { (error) in
                self.locationLabel.text = self.getLocationName(name: party.destinationName, distance: party.distance)
            }
        } else {
            self.locationLabel.text = self.getLocationName(name: (party.destination?.name)!, distance: party.distance)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func getLocationName(name:String, distance:Double) -> String {
        if distance == 0 {
            return name
        } else {
            let _round = Double(round(distance * 10) / 10)
            return name + " (\(_round)km)"
        }
    }
}
