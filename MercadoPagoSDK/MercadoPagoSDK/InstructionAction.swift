//
//  InstructionAction.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class InstructionAction : Equatable {
    
    var label: String!
    var url : String!
    var tag : String!
    
    public class func fromJSON(json : NSDictionary) -> InstructionAction {
        let action = InstructionAction()
            if json["label"] != nil && !(json["label"]! is NSNull) {
            action.label = json["label"] as! String
        }
        
        if json["url"] != nil && !(json["url"]! is NSNull) {
            action.url = json["url"] as! String
        }
        
        if json["tag"] !=  nil && !(json["tag"]! is NSNull) {
            action.tag = json["tag"] as! String
        }
        return action
    }
    
    public func toJSONString() -> String {
        
        let obj:[String:AnyObject] = [
            "label": self.label,
            "url": self.url,
            "tag" : self.tag
        ]
        
        return JSON(obj).toString()
    }
}

public enum ActionTag : String {
    case LINK = "link"
    case PRINT = "print"
}


public func ==(obj1: InstructionAction, obj2: InstructionAction) -> Bool {
    let areEqual =
    obj1.label == obj2.label &&
        obj1.url == obj2.url &&
        obj1.tag == obj2.tag
    
    return areEqual
}