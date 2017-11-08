//
//  DetailViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 9. 14..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import SDWebImage
import Firebase
import Alamofire
import GoogleMaps
import GooglePlaces
import CDAlertView

enum PartyMemberStatus {
    case Member
    case Master
    case Ban
    case Exit
    case NotMember
}

class DetailViewController: UIViewController {
    
    @IBOutlet weak var createLabel:UILabel!
    @IBOutlet weak var locationImage:UIImageView!
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var nicknameLabel:UILabel!
    @IBOutlet weak var personsLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var locationNameLabel:UILabel!
    @IBOutlet weak var mapView:GMSMapView!
    @IBOutlet weak var contentsTextView:UITextView!
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var goChatButton:UIButton!
    
    var party:Party!
    var ref: DatabaseReference = Database.database().reference()
    var partyMembers = [PartyMember]()
    var imageViews = [UIImageView]()
    var myStatus = PartyMemberStatus.NotMember

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Created
        self.createLabel.text = "작성일 \(party.created.string(format: .custom("yyyy.MM.dd hh:mma")))"
        
        // Writer Profile 이미지
        profileImage.sd_setImage(with: URL(string:party.writer.pictureUrl), completed: nil)
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        // Writer nickname
        if party.writer.nickname != nil {
            self.nicknameLabel.text = party.writer.nickname
        } else {
            self.nicknameLabel.text = party.writer.name
        }
        
        self.profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileClick)))
        self.nicknameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileClick)))
        
        // Title
        self.titleLabel.text = party.title
        
        self.contentsTextView.text = party.contents
        self.dateLabel.text = party.date.string(format: .custom("yyyy.MM.dd (E) hh:mma"))
        
        let camera = GMSCameraPosition.camera(withTarget: party.destinationPoint.coordinate, zoom: 11.0)
        self.mapView.camera = camera
        
        let marker = GMSMarker(position: party.destinationPoint.coordinate)
        marker.title = party.destinationName
        marker.map = self.mapView
        
        self.locationImage.image = self.party.destinationImage
        if let locationName = self.party.destination?.name {
            self.locationNameLabel.text = locationName
        } else {
            self.locationNameLabel.text = self.party.destinationName
        }
        
        self.personsLabel.text = "\(party.count)/\(party.persons)"
        
        NetworkManager.getPartyMembers(partyId: party.id) { (jsonArray) in
            for dict in jsonArray {
                let dict2 = dict as! [String:Any]
                let member = PartyMember(dict2)
                self.partyMembers.append(member)
            }
            
            self.setMemberImages()
            self.setMyStatus()
        }
        
//        ref.child("members").child("\(party.id)").observeSingleEvent(of: DataEventType.value) { (snapshot:DataSnapshot) in
//            if let members = snapshot.value as? [String:Any] {
//                for member in members.values {
////                    let dict = member as! [String:Any]
////                    let id = dict["id"] as! String
//
//                    self.setMemberImages()
//                }
//            }
//        }
    }
    
    func setMyStatus() {
        let myId = Defaults[.id]
        for member in partyMembers {
            if member.user.id == myId {
                if member.status == "master" {
                    myStatus = PartyMemberStatus.Master
                } else if member.status == "member" {
                    myStatus = PartyMemberStatus.Member
                } else if member.status == "ban" {
                    myStatus = PartyMemberStatus.Ban
                } else if member.status == "exit" {
                    myStatus = PartyMemberStatus.Exit
                }
            }
        }
    }
    
    func setMemberImages() {
        for imageView in imageViews {
            imageView.removeFromSuperview()
        }
        imageViews.removeAll()
        
        let yPosition = self.goChatButton.frame.origin.y - 41.0
        let xCenter = self.view.center.x
        let xStart = xCenter - 43.0 * CGFloat(partyMembers.count) / 2.0
        
        for (index, member) in partyMembers.enumerated() {
            let xPosition = xStart + CGFloat(index) * 43.0
            
            let imageView = UIImageView(frame: CGRect(x: xPosition, y: yPosition, width: 33, height: 33))
            imageView.sd_setImage(with:  URL(string:member.userPictureUrl), completed: nil)
            imageView.layer.cornerRadius = imageView.frame.height/2
            imageView.clipsToBounds = true
            self.contentView.addSubview(imageView)
            imageViews.append(imageView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ChatViewController {
            controller.senderDisplayName = Defaults[.name]
            controller.senderId = Defaults[.id]
            controller.chatroom = String(party.id)
            
            controller.partyMembers = self.partyMembers
            controller.party = self.party
            print("prepare chatview")
        }
    }
    
    @IBAction func joinClick() {
        switch myStatus {
        case PartyMemberStatus.NotMember, PartyMemberStatus.Exit:
            NetworkManager.postPartyMember(partyId: party.id, completion: { (json) in
                print("join party member success : \(json)")
                if (json["success"] as? Bool)! {
                    let imMember = PartyMember(json)
                    self.partyMembers.append(imMember)
                    
                    self.setMyStatus()
                    self.setMemberImages()
                    
                    self.performSegue(withIdentifier: "go_chat", sender: nil)
                } else {
                    let alert = CDAlertView(title: "채팅방 인원이 꽉찼습니다", message: "채팅방 인원이 꽉찼습니다", type: .custom(image: UIImage(named:"peacaSymbol")!))
                    let doneAction = CDAlertViewAction(title: "OK")
                    alert.add(action: doneAction)
                    alert.show()
                }
            })
            break
        case PartyMemberStatus.Master, PartyMemberStatus.Member, PartyMemberStatus.Ban:
            self.performSegue(withIdentifier: "go_chat", sender: nil)
            break
        }
    }
    
    @IBAction func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func profileClick(sender:AnyObject) {
        print("go profile")
        self.performSegue(withIdentifier: "go_profile", sender: nil)
    }
}
