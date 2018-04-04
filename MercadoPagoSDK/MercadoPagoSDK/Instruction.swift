//
//  Instruction.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class Instruction: NSObject {

    open var title: String = ""
    open var subtitle: String?
    open var accreditationMessage: String = ""
    open var accreditationComment: [String]?
    open var references: [InstructionReference]!
    open var info: [String]!
    open var secondaryInfo: [String]?
    open var tertiaryInfo: [String]?
    open var actions: [InstructionAction]?
    open var type: String = ""

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String: Any] {
        let obj: [String: Any] = [
            "title": self.title,
            "accreditationMessage": self.accreditationMessage
        ]
        return obj
    }

    open func hasSubtitle() -> Bool {
        return !String.isNullOrEmpty(subtitle)
    }

    open func hasTitle() -> Bool {
        return !String.isNullOrEmpty(title)
    }

    open func hasAccreditationMessage() -> Bool {
        return !String.isNullOrEmpty(accreditationMessage)
    }

    open func hasSecondaryInformation() -> Bool {
        return !Array.isNullOrEmpty(secondaryInfo)
    }

    open func hasAccreditationComment() -> Bool {
        return !Array.isNullOrEmpty(accreditationComment)
    }

    open func hasActions() -> Bool {
        return !Array.isNullOrEmpty(actions)
    }
}
