//
//  Common.swift
//  peaca
//
//  Created by kimkkikki on 2017. 10. 19..
//  Copyright © 2017년 peaca. All rights reserved.
//

import Foundation
import GooglePlaces

class Common {
    class func getPhotoWithGooglePlaceID(_ id:String, completion:@escaping (UIImage) -> ()) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: id) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("getPhotoWithGooglePlaceID, lookUpPhotos Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: {
                        (photo, error) -> Void in
                        if let error = error {
                            // TODO: handle the error.
                            print("getPhotoWithGooglePlaceID, loadPlacePhoto Error: \(error.localizedDescription)")
                        } else {
                            completion(photo!)
//                            self.locationImage.image = photo;
                        }
                    })
                }
            }
        }
    }
    
    class func getPlaceWithGooglePlaceID(_ id:String, completion:@escaping (GMSPlace) -> (), failure:@escaping (Error?) -> ()) {
        GMSPlacesClient.shared().lookUpPlaceID(id, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                failure(error)
                return
            }
            
            guard let place = place else {
                print("No place details for \(id)")
                failure(nil)
                return
            }
            
            completion(place)
        })
    }
}
