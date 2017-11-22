//
//  Filter.swift
//  peaca
//
//  Created by kimkkikki on 2017. 9. 18..
//  Copyright © 2017년 peaca. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces

class Filter {
    var searchString:String?
    var searchCity:String?
    var date:Date?
    var location:GMSPlace?
    var personRange:String?
    var order:String?
    
    func clear() {
        self.searchString = nil
        self.searchCity = nil
        self.date = nil
        self.location = nil
        self.personRange = nil
        self.order = nil
    }
    
    func getDictionary() -> [String:Any?] {
        return ["search": self.searchString, "city": self.searchCity, "date": self.date, "location": self.location?.name, "range": self.personRange, "order": self.order]
    }
    
    func getFilterCount() -> Int {
        var count = 0
        
        if self.searchString != nil {
            count += 1
        }
        if self.searchCity != nil {
            count += 1
        }
        if self.date != nil {
            count += 1
        }
        if self.location != nil {
            count += 1
        }
        if self.personRange != nil {
            count += 1
        }
        if self.order != nil {
            count += 1
        }
        
        return count
    }
}

extension Filter: CustomStringConvertible {
    public var description: String {
        return "{'searchString':'\(String(describing: self.searchString))', 'searchCity':'\(String(describing: self.searchCity))', 'date':'\(String(describing: self.date))', 'location': \(String(describing: self.location)), 'personRange': \(String(describing: self.personRange)), 'order':'\(String(describing: self.order))'}"
    }
}
