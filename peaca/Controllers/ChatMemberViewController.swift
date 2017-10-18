//
//  ChatMemberViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 13..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit

class ChatMemberViewController: UITableViewController {
    var partyMembers:[PartyMember]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("chatMemberController : \(self.partyMembers)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partyMembers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "chat_member_cell")
        cell.textLabel?.text = partyMembers[indexPath.row].userId
        cell.imageView?.sd_setImage(with: URL(string:partyMembers[indexPath.row].userPictureUrl), completed: nil)
        
        return cell
    }
}
