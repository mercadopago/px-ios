//
//  InstructionAction.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers open class InstructionAction: NSObject {

    var label: String!
    var url: String!
    var tag: String!
    open class func fromJSON(_ json: NSDictionary) -> InstructionAction {
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
}

public enum ActionTag: String {
    case LINK = "link"
    case PRINT = "print"
}
