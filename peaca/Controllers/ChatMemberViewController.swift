//
//  ChatMemberViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 13..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import SwipeCellKit

class ChatMemberViewController: UIViewController {
    var masterMember:PartyMember?
    var members = [PartyMember]()
    var partyMembers:[PartyMember]! {
        didSet {
            for member in partyMembers {
                if member.status == "master" {
                    masterMember = member
                } else {
                    members.append(member)
                }
            }
        }
    }
    
    @IBOutlet weak var alarmButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func exitClick() {
        //TODO: 방나가기 구현
    }
    
    @IBAction func alarmClick() {
        //TODO: Alarm 변경 구현
    }
}

extension ChatMemberViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            print("delete")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableCell(withIdentifier: "chat_master_header")
            return header
        } else {
            let header = tableView.dequeueReusableCell(withIdentifier: "chat_member_header")
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if masterMember == nil {
                return 0
            } else {
                return 1
            }
        } else {
            return self.members.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat_member_cell") as! ChatMemberTableViewCell
        cell.delegate = self
        if indexPath.section == 0 {
            if masterMember!.user.nickname != nil {
                cell.profileName.text = masterMember!.user.nickname
            } else {
                cell.profileName.text = masterMember!.user.name
            }
            cell.profileImage.sd_setImage(with: URL(string:masterMember!.userPictureUrl), completed: nil)
        } else {
            if members[indexPath.row].user.nickname != nil {
                cell.profileName.text = members[indexPath.row].user.nickname
            } else {
                cell.profileName.text = members[indexPath.row].user.name
            }
            cell.profileImage.sd_setImage(with: URL(string:members[indexPath.row].userPictureUrl), completed: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}

extension ChatMemberViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            // handle action by updating model with deletion
            print("delete!")
        }
        
        // customize the action appearance
        deleteAction.backgroundColor = UIColor.pumpkin
        deleteAction.image = UIImage(named: "close_white")
        
        return [deleteAction]
    }
}
