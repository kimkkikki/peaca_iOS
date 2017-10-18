//
//  MainViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 8. 23..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import FanMenu
import Macaw
import Alamofire
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
        Alamofire.request("http://localhost:8000/apis/party", method: .get, encoding: JSONEncoding.default, headers: Defaults[.header] as? HTTPHeaders).responseJSON { (response:DataResponse<Any>) in
            //            print(response)
            if response.error == nil {
                if let jsonArray = response.result.value as? NSArray {
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
            } else {
                //TODO: Error Handling
                print("ERROR! \(String(describing: response.error))")
                completion()
            }
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
        //TODO: Go to Detail
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
            print("list")
        } else if selectedMenu == "menu_profile" {
            print("profile")
        } else {
            print("setting")
        }
    }
}
