//
//  Site.swift
//  PodTester
//
//  Created by AUGUSTO COLLERONE ALFONSO on 4/24/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import Foundation
import UIKit

open class Site: NSObject {
    open var ID : String
    open var name : String
    open var pref_ID : String
    open var pk : String
    open var defaultColor : UIColor
    
    init(ID: String, name: String, prefID: String, publicKey: String, defaultColor: UIColor) {
        self.ID = ID
        self.name = name
        self.pref_ID = prefID
        self.pk = publicKey
        self.defaultColor = defaultColor
    }
    
    open func getName() -> String{
        return self.name
    }
    
    open func getPrefID() -> String {
        return self.pref_ID
    }
    
    open func getPublicKey() -> String {
        return self.pk
    }
    
    open func getColor() -> UIColor {
        return self.defaultColor
    }
    
}
