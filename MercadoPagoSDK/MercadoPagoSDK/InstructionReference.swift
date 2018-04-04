//
//  InstructionReference.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class InstructionReference: NSObject {

    var label: String!
    var value: [String]!
    var separator: String!
    var comment: String?

    open func getFullReferenceValue() -> String {
        if String.isNullOrEmpty(separator) {
            self.separator = ""
        }
        if value.count == 0 {
            return ""
        }
        var referenceFullValue: String = value.reduce("", {($0 as String) + self.separator + $1})
        if self.separator != "" {
            referenceFullValue = String(referenceFullValue.dropFirst())
        }
        return referenceFullValue
    }
}
