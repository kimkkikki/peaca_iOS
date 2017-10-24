//
//  MainViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 8. 23..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class MainViewController: UIViewController {
    
    @IBOutlet weak var mainTableView:UITableView!
    var partyList:[Party] = []
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(MainViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getDataFromServer {
            refreshControl.endRefreshing()
        }
    }
    
    func getDataFromServer(_ completion: @escaping () -> ()) {
        NetworkManager.getParty { (jsonArray) in
            self.partyList.removeAll()
            for dict in jsonArray {
                let party = Party(dict: dict as! [String:Any])
                self.partyList.append(party)
            }
            self.mainTableView.reloadData()
            // TODO:Stop HUD
            
            completion()
            print(self.partyList)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.addSubview(self.refreshControl)
        getDataFromServer{}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? DetailViewController {
            controller.party = sender as! Party
        } else if let controller = segue.destination as? FilterViewController {
            controller.delegate = self
        } else if let controller = segue.destination as? MenuViewController {
            controller.delegate = self
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peaca_main_cell", for: indexPath) as! PeacaMainTableViewCell
        
        cell.setParty(partyList[indexPath.row])
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partyList.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(partyList[indexPath.row])
        self.performSegue(withIdentifier: "go_detail", sender: partyList[indexPath.row])
    }
}

extension MainViewController: FilterViewControllerDelegate {
    func didSelectFilter(_ filter: Filter) {
        print("filter delegate call")
    }
}

extension MainViewController: MenuViewControllerDelegate {
    func didSelectMenu(_ selectedMenu: String) {
        if selectedMenu == "menu_write" {
            self.performSegue(withIdentifier: "go_write", sender: nil)
        } else if selectedMenu == "menu_list" {
            self.performSegue(withIdentifier: "go_my_list", sender: nil)
        } else if selectedMenu == "menu_profile" {
            print("profile")
        } else {
            self.performSegue(withIdentifier: "go_setting", sender: nil)
        }
    }
}
