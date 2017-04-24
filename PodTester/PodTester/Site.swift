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
    open var pk_sandbox : String
    open var pk_produ : String
    open var defaultColor : UIColor
    
    init(ID: String, name: String, prefID: String, pk_sandbox: String, pk_produ: String, defaultColor: UIColor) {
        self.ID = ID
        self.name = name
        self.pref_ID = prefID
        self.pk_sandbox = pk_sandbox
        self.pk_produ = pk_produ
        self.defaultColor = defaultColor
    }
    
    open func getName() -> String{
        return self.name
    }
    
    open func getPrefID() -> String {
        return self.pref_ID
    }
    
    open func getSandboxPK() -> String {
        return self.pk_sandbox
    }
    
    open func getProduPK() -> String {
        return self.pk_produ
    }
    
    open func getColor() -> UIColor {
        return self.defaultColor
    }
    
}
