//
//  WriteFormViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 9. 6..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import Eureka
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import NotificationBannerSwift
import SwiftDate
import Alamofire
import SwiftyUserDefaults
import TimeZoneLocate
import Firebase

class WriteFormViewController: FormViewController {
    
    var destinationPlace:GMSPlace?
    var sourcePlace:GMSPlace?
    var ref: DatabaseReference!
    
    enum selectMap {
        case destination
        case source
    }
    
    var curruentMap = selectMap.destination

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        form +++ Section()
            <<< TextRow("title"){ row in
                row.placeholder = "모임 제목을 입력하세요"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            <<< DateTimeInlineRow("date"){
                $0.title = "모임 시간"
                $0.value = Date()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd a hh:mm"
                $0.dateFormatter = formatter
                
                $0.minimumDate = Date()
                $0.minuteInterval = 5
                
                $0.cellSetup({ (cell, row) in
                    cell.imageView?.image = UIImage(named: "dateIcon")
                })
            }
            <<< StepperRow("persons"){
                $0.cellSetup({ (cell, row) in
                    row.title = "모임 인원"
                    row.value = 2.0
                    cell.valueLabel?.text = "\(Int(row.value!))"
                    cell.imageView?.image = UIImage(named: "personIcon")
                })
                $0.cellUpdate({ (cell, row) in
                    if(row.value != nil) {
                        if row.value! > 9.0 {
                            row.cell.valueLabel?.text = "10+"
                        } else {
                            row.cell.valueLabel?.text = "\(Int(row.value!))"
                        }
                    }
                })
                $0.onChange({ (row) in
                    if(row.value != nil) {
                        if row.value! > 9.0 {
                            row.cell.valueLabel?.text = "10+"
                        } else {
                            row.cell.valueLabel?.text = "\(Int(row.value!))"
                        }
                    }
                })
            }
            
            <<< ButtonRow("destination_button") {
                $0.cellSetup({ (cell, row) in
                    cell.imageView?.image = UIImage(named: "mapIcon")
                })
                
                $0.title = "목적지 선택"
                $0.cellStyle = .value1
                $0.updateCell()
                }.onCellSelection({ (cell, row) in
                    let config = GMSPlacePickerConfig(viewport: nil)
                    let placePicker = GMSPlacePickerViewController(config: config)
                    placePicker.delegate = self
                    self.present(placePicker, animated: true, completion: nil)
                    
                    self.curruentMap = selectMap.destination
                })
            <<< GMSMapFormRow("destination_map") {
                $0.hidden = "$destination_map == false"
                
                $0.value = false
                $0.cell.height = { 150 }
            }
            <<< SwitchRow("is_different_source") {
                $0.hidden = "$destination_map == false"
                
                $0.title = "집결지가 목적지와 같습니까?"
                $0.value = true
            }
            <<< ButtonRow("source_button") {
                $0.cellSetup({ (cell, row) in
                    cell.imageView?.image = UIImage(named: "mapIcon")
                })
                
                $0.hidden = "$is_different_source == true"
                
                $0.title = "집결지 선택"
                $0.cellStyle = .value1
                $0.updateCell()
                }.onCellSelection({ (cell, row) in
                    let config = GMSPlacePickerConfig(viewport: nil)
                    let placePicker = GMSPlacePickerViewController(config: config)
                    placePicker.delegate = self
                    self.present(placePicker, animated: true, completion: nil)
                    
                    self.curruentMap = selectMap.source
                })
            <<< GMSMapFormRow("source_map") {
                $0.hidden = "$source_map == false or $is_different_source == true"
                
                $0.value = false
                $0.cell.height = { 150 }
            }
            <<< TextAreaRow("contents") {
                $0.placeholder = "내용을 입력하세요"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
        
        self.tableView.backgroundColor = UIColor.white
    }
    
    @IBAction func close() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save() {
        if self.checkValidation() {
            self.sendToServer()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkValidation() -> Bool {
        let valueDict = form.values()
        print(valueDict)
        
        if (valueDict["title"] as? String) == nil {
            NotificationBanner(title:"제목을 입력하세요", style:.danger).show()
            return false
        }
        
//        let date = valueDict["date"] as! Date
//        if date < Date() + 1.hour {
//            NotificationBanner(title:"최소 한시간 이후는 등록해야 합니다", style:.danger).show()
//            return false
//        }
        
        if destinationPlace == nil {
            NotificationBanner(title:"목적지를 설정해야 합니다", style:.danger).show()
            return false
        }
        
        return true
    }
    
    func getAddressWithPlace(place:GMSPlace) -> (String?, String?, String?) {
        var country:String?, state:String?, city:String?
        if let addressComponents = place.addressComponents {
            let arrays : NSArray = addressComponents as NSArray;
            for i in 0..<arrays.count {
                
                let dics : GMSAddressComponent = arrays[i] as! GMSAddressComponent
                let str : NSString = dics.type as NSString
                
                if (str == "country") {
                    country = dics.name
                }
                else if (str == "administrative_area_level_1") {
                    state = dics.name
                }
                else if (str == "administrative_area_level_2") {
                    city = dics.name
                }
            }
        }
    
        return (country, state, city)
    }

    
    func GMSPlaceToDict(_ place:GMSPlace) -> [String:Any] {
        var dict = [String:Any]()
        dict["placeId"] = place.placeID
        dict["name"] = place.name
        dict["coordinate"] = ["latitude": place.coordinate.latitude, "longitude": place.coordinate.longitude]
        let (country, state, city) = getAddressWithPlace(place: place)
        
        if city != nil {
            dict["address"] = "\(country!),\(state!),\(city!)"
        } else if state != nil {
            dict["address"] = "\(country!),\(state!)"
        } else if country != nil {
            dict["address"] = "\(country!)"
        }
        
        return dict
    }
    
    func sendToServer() {
        let valueDict = form.values()
        
        var params: Parameters = ["title": valueDict["title"] as! String,
                                  "contents": valueDict["contents"] as! String,
                                  "persons": Int((valueDict["persons"] as? Double)!),
                                  "date": (valueDict["date"] as! Date).string(format: .iso8601(options: [.withInternetDateTime])),
                                  "destination": GMSPlaceToDict(self.destinationPlace!)]
        
        if  valueDict["is_different_source"] as! Bool == false {
            if let source = self.sourcePlace {
                params["source"] = GMSPlaceToDict(source)
            }
        }
        
        let location = CLLocation(latitude: self.destinationPlace!.coordinate.latitude, longitude: self.destinationPlace!.coordinate.longitude)
        params["timezone"] = location.timeZone.identifier
        
        print(params)
        
        NetworkManager.postParty(params: params) { (json) in
            let id = json["id"] as! Int
            
            let memberData = ["id": Defaults[.id] as String!,
                              "picture_url": Defaults[.picture_url] as String!,
                              "master": true] as [String : Any]
            
            self.ref.child("members").child("\(id)").child(Defaults[.id] as String!).setValue(memberData)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension WriteFormViewController: GMSPlacePickerViewControllerDelegate {
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        viewController.dismiss(animated: true, completion: nil)
        print("Place : \(place)")
        
        if curruentMap == selectMap.destination {
            let mapRow = form.rowBy(tag: "destination_map") as! GMSMapFormRow
            mapRow.cell.setMapPoint(place: place)
            
            let mapButton = form.rowBy(tag: "destination_button") as! ButtonRow
            mapButton.cell.detailTextLabel?.text = place.name
            
            destinationPlace = place
        } else {
            let mapRow = form.rowBy(tag: "source_map") as! GMSMapFormRow
            mapRow.cell.setMapPoint(place: place)
            
            let mapButton = form.rowBy(tag: "source_button") as! ButtonRow
            mapButton.cell.detailTextLabel?.text = place.name
            
            sourcePlace = place
        }
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
        print("No place selected")
    }
}
