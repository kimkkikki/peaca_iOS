//
//  MyListViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 23..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import SwipeCellKit
import CDAlertView

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? DetailViewController {
            controller.party = sender as! Party
        }
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
        print(myList[indexPath.row].party!)
        //TODO: Go to Detail
        self.performSegue(withIdentifier: "go_detail", sender: myList[indexPath.row].party!)
    }
}

extension MyListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            // handle action by updating model with deletion
            print("delete!")
            let alert = CDAlertView(title: "모임 그만할라구?", message: "채팅방에서도 나가진당", type: .custom(image: UIImage(named:"peacaSymbol")!))
            let doneAction = CDAlertViewAction(title: "OK")
            alert.add(action: doneAction)
            let cancelAction = CDAlertViewAction(title: "Cancel")
            alert.add(action: cancelAction)
            alert.show()
        }
        
        // customize the action appearance
        deleteAction.backgroundColor = UIColor.pumpkin
        deleteAction.image = UIImage(named: "delete_white")
        
        return [deleteAction]
    }
}

