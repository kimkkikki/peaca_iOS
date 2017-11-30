//
//  MainViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 8. 23..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import MapKit

class MainViewController: UIViewController {
    var page = 1
    var isLoading = false
    var hasNext = true
    
    var filter:Filter = Filter()
    
    @IBOutlet weak var mainTableView:UITableView!
    @IBOutlet weak var filterBarButton:UIBarButtonItem!
    
    var partyList:[Party] = []
    
    var myLocation:CLLocationCoordinate2D?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(MainViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getDataFromServer(isRefresh: true, myLocation: self.myLocation) {
            refreshControl.endRefreshing()
        }
    }
    
    func getDataFromServer(isRefresh:Bool, myLocation:CLLocationCoordinate2D?, completion: (() -> ())?) {
        if isRefresh {
            self.page = 1
            self.hasNext = true
        }
        
        if !self.isLoading {
            self.isLoading = true
            NetworkManager.getParty(page: self.page, location: myLocation, filter: self.filter) { (jsonArray) in
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
                }
                self.mainTableView.reloadData()
                self.isLoading = false
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.addSubview(self.refreshControl)
        
        getDataFromServer(isRefresh: false, myLocation: self.myLocation, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? DetailViewController {
            controller.party = sender as! Party
        } else if let controller = segue.destination as? FilterViewController {
            controller.delegate = self
            controller.filter = self.filter
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
            // TODO:리프레쉬할때 해야댐
            print("loadmore")
            getDataFromServer(isRefresh: false, myLocation: self.myLocation, completion: nil)
        }
    }
}

extension MainViewController: FilterViewControllerDelegate {
    func didSelectFilter(_ filter: Filter) {
        print("filter delegate call : \(self.filter)")
        
        if filter.getFilterCount() > 0 {
            filterBarButton.setBadge(text: "\(filter.getFilterCount())")
        } else {
            filterBarButton.setBadge(text: "")
        }
        getDataFromServer(isRefresh: true, myLocation: self.myLocation, completion: nil)
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
