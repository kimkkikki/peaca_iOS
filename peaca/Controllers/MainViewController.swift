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
    var page = 1
    var isLoading = false
    var hasNext = true
    
    @IBOutlet weak var mainTableView:UITableView!
    var partyList:[Party] = []
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(MainViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.page = 1
        self.hasNext = true
        getDataFromServer(isRefresh: true) {
            refreshControl.endRefreshing()
        }
    }
    
    func getDataFromServer(isRefresh:Bool, completion: (() -> ())?) {
        NetworkManager.getParty(page: self.page) { (jsonArray) in
            if isRefresh {
                self.partyList.removeAll()
            }
            
            self.page = self.page + 1
            
            if jsonArray.count == 0 {
                self.hasNext = false
            } else {
                for dict in jsonArray {
                    let party = Party(dict: dict as! [String:Any])
                    self.partyList.append(party)
                }
                self.mainTableView.reloadData()
            }
            
            completion?()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.addSubview(self.refreshControl)
        getDataFromServer(isRefresh: false, completion: nil)
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
    
    @IBAction func logoClick() {
        self.mainTableView.setContentOffset(CGPoint.zero, animated: true)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if !self.isLoading && self.hasNext && offsetY > contentHeight - scrollView.frame.size.height {
            print("loadmore")
            self.isLoading = true
            getDataFromServer(isRefresh: false, completion: {
                self.isLoading = false
            })
        }
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
