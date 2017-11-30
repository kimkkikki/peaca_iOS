//
//  SelectImageForm.swift
//  peaca
//
//  Created by kimkkikki on 2017. 11. 27..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import Eureka
import GooglePlaces
import SDWebImage

public class SelectImageFormCell: Cell<Bool>, CellType {
    @IBOutlet weak var scrollView:UIScrollView!
    var imageViews:[UIImageView] = [UIImageView]()
    
    func resizeByImageSize() {
        var offset:CGFloat = 10.0
        for _imageView in self.imageViews {
            _imageView.frame.origin.x = offset
            offset = offset + _imageView.frame.size.width + 10
        }
        
        self.scrollView.contentSize = CGSize(width: offset, height: self.scrollView.frame.size.height)
    }
    
    func setPlacePhotos(_ placePhotos:[PlacePhoto]) {
        for _imageView in self.imageViews {
            _imageView.removeFromSuperview()
        }
        self.imageViews.removeAll()
        
        let height = self.contentView.frame.size.height - 20
        
        for (index, placePhoto) in placePhotos.enumerated() {
            if let url = URL(string: placePhoto.imageUrl) {
                let _imageView = UIImageView()
                _imageView.sd_setShowActivityIndicatorView(true)
                _imageView.sd_setIndicatorStyle(.gray)
                _imageView.sd_setImage(with: url, completed: { (image, error, cacheType, url) in
                    if let _image = image {
                        _imageView.frame.size.width = _image.size.width / ( _image.size.height / height )
                        self.resizeByImageSize()
                    }
                })
                
                _imageView.frame.origin = CGPoint(x: 5 + 110 * index, y: 10)
                _imageView.frame.size = CGSize(width: height, height: height)
                
                self.scrollView.addSubview(_imageView)
                self.imageViews.append(_imageView)
                
                let width = 120.0 + 110.0 * CGFloat(index)
                self.scrollView.contentSize = CGSize(width: width, height: self.scrollView.frame.size.height)
                print("add images : \(placePhoto)")
            }
        }
    }
}

public final class SelectImageFormRow: Row<SelectImageFormCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<SelectImageFormCell>(nibName: "SelectImageForm")
    }
}
