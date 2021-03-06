//
//  FilterViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 9. 18..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import Eureka
import GooglePlaces
import GooglePlacePicker

protocol FilterViewControllerDelegate {
    func didSelectFilter(_ filter:Filter)
}

class FilterViewController: FormViewController {
    
    var delegate:FilterViewControllerDelegate?
    var filter:Filter!
    
    var dateChange = false
    var selectMyLocation:GMSPlace?
    
    @IBOutlet weak var clearButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section()
            <<< TextRow("search"){ row in
                row.placeholder = "키워드(제목) 검색"
                row.cellSetup({ cell, row in
                    cell.imageView?.image = UIImage(named: "searchIcon")
                })
            }
            
            <<< LabelRow("city") {
                $0.title = "여행지역(나라, 도시) 검색"
                }.cellSetup({ cell, row in
                    cell.imageView?.image = UIImage(named: "searchIcon")
                }).onCellSelection({ cell, row in
                    let acController = GMSAutocompleteViewController()
                    let filter = GMSAutocompleteFilter()
                    filter.type = GMSPlacesAutocompleteTypeFilter.city
                    acController.autocompleteFilter = filter
                    acController.delegate = self
                    self.present(acController, animated: true, completion: nil)
                })
            
            <<< DateInlineRow("date") {
                $0.title = "일정"
                $0.value = Date()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd"
                $0.dateFormatter = formatter
                $0.minimumDate = Date()
            }.cellSetup({ cell, row in
                    cell.imageView?.image = UIImage(named: "dateIcon")
            }).onChange({ (row) in
                self.dateChange = true
            })
            
            <<< LabelRow("location") {
                $0.title = "내 위치"
                }.cellSetup({ cell, row in
                    cell.imageView?.image = UIImage(named: "mapIcon")
                }).onCellSelection({ (cell, row) in
                    let config = GMSPlacePickerConfig(viewport: nil)
                    let placePicker = GMSPlacePickerViewController(config: config)
                    placePicker.delegate = self
                    self.present(placePicker, animated: true, completion: nil)
                })
            
            <<< ActionSheetRow<String>("range") {
                $0.title = "인원수"
                $0.selectorTitle = "인원수를 정해주세요"
                $0.options = ["전체", "2명", "3~4명", "5~6명", "7~8명", "9명이상"]
                $0.value = "전체"
                }.cellSetup({ cell, row in
                    cell.imageView?.image = UIImage(named: "personIcon")
                }).onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
            
            <<< ActionSheetRow<String>("order") {
                $0.title = "정렬"
                $0.selectorTitle = "정렬 순서를 정해주세요"
                $0.options = ["최신순", "거리순", "???"]
                $0.value = "최신순"
                }.cellSetup({ cell, row in
                    cell.imageView?.image = UIImage(named: "filterIcon")
                }).onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
        
        self.tableView.backgroundColor = UIColor.white
        self.view.bringSubview(toFront: clearButton)
        
        self.form.setValues(self.filter.getDictionary())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didSelectCompeleteButton() {
        let valueDict = form.values()
        print("complete \(valueDict)")
        
        if let search = valueDict["search"] as? String {
            self.filter.searchString = search
        }
        
        if let city = valueDict["city"] as? String {
            self.filter.searchCity = city
        }
        
        if let location = self.selectMyLocation {
            self.filter.location = location
        }
        
        if self.dateChange, let date = valueDict["date"] as? Date {
            self.filter.date = date
        }
        
        if let selectRange = valueDict["range"] as? String {
            self.filter.personRange = selectRange
        }
        
        if let order = valueDict["order"] as? String {
            self.filter.order = order
        }
        
        self.navigationController?.popViewController(animated: true)
        self.delegate?.didSelectFilter(filter)
    }
    
    @IBAction func close() {
        self.filter.clear()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clear() {
        self.filter.clear()
        self.form.setValues(self.filter.getDictionary())
        self.tableView.reloadData()
    }
}

extension FilterViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place: \(place)")
        dismiss(animated: true, completion: nil)
        
        let labelRow = form.rowBy(tag: "city") as! LabelRow
        labelRow.value = place.name
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: \(error)")
        dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        dismiss(animated: true, completion: nil)
    }
}

extension FilterViewController: GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        viewController.dismiss(animated: true, completion: nil)
        print("Place : \(place)")
        
        let labelRow = form.rowBy(tag: "location") as! LabelRow
        labelRow.value = place.name
        
        self.selectMyLocation = place
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
        print("No place selected")
    }
}
