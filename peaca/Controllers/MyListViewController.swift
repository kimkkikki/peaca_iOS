//
//  MyListViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 23..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import SwipeCellKit

class MyListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var myList = [PartyMember]()
    
    @IBAction func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.getMyList { (jsonArray) in
            print("getMyList : \(jsonArray)")
            
            for dict in jsonArray {
                let partyMember = PartyMember(dict as! [String : Any])
                print("partyMember : \(partyMember)")
                self.myList.append(partyMember)
            }
            
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MyListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "my_list_cell", for: indexPath) as! MyListTableViewCell
        cell.delegate = self
        
        cell.setParty(myList[indexPath.row].party!)
//        cell.titleLabel.text = myList[indexPath.row].party!.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(myList[indexPath.row])
        //TODO: Go to Detail
//        self.performSegue(withIdentifier: "go_detail", sender: partyList[indexPath.row])
    }
}

extension MyListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            // handle action by updating model with deletion
            print("delete!")
        }
        
        // customize the action appearance
        deleteAction.backgroundColor = UIColor.pumpkin
        deleteAction.image = UIImage(named: "delete_white")
        
        return [deleteAction]
    }
}

