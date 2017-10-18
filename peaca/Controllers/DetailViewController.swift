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
    
    var party:Party!
    var ref: DatabaseReference = Database.database().reference()
    var partyMembers = [PartyMember]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Created
        self.createLabel.text = "작성일 \(party.created.string(format: .custom("yyyy.mm.dd")))"
        
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
        
        // Title
        self.titleLabel.text = party.title
        
        self.locationNameLabel.text = party.destinationName
        self.contentsTextView.text = party.contents
        self.dateLabel.text = party.date.string(format: .custom("yyyy.mm.dd (E) hh:MMa"))
        
        let camera = GMSCameraPosition.camera(withTarget: party.destinationPoint.coordinate, zoom: 11.0)
        self.mapView.camera = camera
        
        let marker = GMSMarker(position: party.destinationPoint.coordinate)
        marker.title = party.destinationName
        marker.map = self.mapView
        
        
        let contentSize = self.contentsTextView.sizeThatFits(self.contentsTextView.bounds.size)
        var frame = self.contentsTextView.frame
        frame.size.height = contentSize.height
        self.contentsTextView.frame = frame
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: frame.height + contentsTextView.frame.origin.y + 10)
        
//        aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.myTextViewTitle, attribute: .Height, relatedBy: .Equal, toItem: self.myTextViewTitle, attribute: .Width, multiplier: myTextViewTitle.bounds.height/myTextViewTitle.bounds.width, constant: 1)
//        self.myTextViewTitle.addConstraint(aspectRatioTextViewConstraint!)
        
        if party.writer.id == Defaults[.id] {
            print("내글")
        } else {
            print("다른사람 글")
        }
        
        Alamofire.request("http://localhost:8000/apis/party/\(party.id)", method: .get, encoding: JSONEncoding.default, headers: Defaults[.header] as? HTTPHeaders).responseJSON { (response:DataResponse<Any>) in
            print(response)
            
            if response.error == nil, let jsonArray = response.result.value as? NSArray {
                for dict in jsonArray {
                    let dict2 = dict as! [String:Any]
                    let member = PartyMember(dict2)
                    self.partyMembers.append(member)
                    
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                    imageView.sd_setImage(with:  URL(string:dict2["user_picture_url"] as! String), completed: nil)
                    imageView.layer.cornerRadius = imageView.frame.height/2
                    imageView.clipsToBounds = true
//                    self.stackView.addSubview(imageView)
                }
                
                print("partymembers : \(self.partyMembers)")
                
            } else {
                //TODO: Error Handling
                print("ERROR! \(response.error)")
            }
        }
        
        ref.child("members").child("\(party.id)").observeSingleEvent(of: DataEventType.value) { (snapshot:DataSnapshot) in
            if let members = snapshot.value as? [String:Any] {
                for member in members.values {
//                    let dict = member as! [String:Any]
//                    let id = dict["id"] as! String
                    
                    self.setMemberImages()
                }
            }
        }
    }
    
    func setMemberImages() {
        //TODO: 참여자들 이미지 셋팅 필요함
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
            print("prepare chatview")
        }
    }
    
    @IBAction func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
}
