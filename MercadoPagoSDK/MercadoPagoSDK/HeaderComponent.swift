//
//  HeaderComponent.swift
//  TestAutolayout
//
//  Created by Demian Tejo on 10/18/17.
//  Copyright © 2017 Demian Tejo. All rights reserved.
//

import UIKit

class HeaderComponent: NSObject {
    var title : String
    var subTitle : String
    var backgroundColor : UIColor
    var productImage : UIImage?
    var statusImage : UIImage?
    
    init(data : HeaderData) {
        self.title = data.title
        self.subTitle = data.subTitle
        self.backgroundColor = data.backgroundColor
        self.productImage = data.productImage
        self.statusImage = data.statusImage
    }
}
class HeaderData : NSObject {
    var title : String
    var subTitle : String
    var backgroundColor : UIColor
    var productImage : UIImage?
    var statusImage : UIImage?
    init(title: String, subTitle: String, backgroundColor: UIColor,productImage:UIImage?, statusImage : UIImage? ) {
        self.title = title
        self.subTitle = subTitle
        self.backgroundColor = backgroundColor
        self.productImage = productImage
        self.statusImage = statusImage
    }
}


