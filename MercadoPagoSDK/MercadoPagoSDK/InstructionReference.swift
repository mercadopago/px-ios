//
//  InstructionReference.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class InstructionReference: Equatable {

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
            referenceFullValue = String(referenceFullValue.characters.dropFirst())
        }
        return referenceFullValue
    }

    open class func fromJSON(_ json: NSDictionary) -> InstructionReference {
        let reference = InstructionReference()
        if json["label"] != nil && !(json["label"]! is NSNull) {
            reference.label = json["label"] as! String
        }

        if json["field_value"] != nil && !(json["field_value"]! is NSNull) {
            reference.value = [String]()
            if let values = json["field_value"] as? NSArray {
                for val in values {
                    reference.value.append(String(describing: val))
                }
            }

        }

        if json["separator"] !=  nil && !(json["separator"]! is NSNull) {
            reference.separator = json["separator"] as! String
        }

        if json["comment"] !=  nil && !(json["comment"]! is NSNull) {
            reference.comment = json["comment"] as? String
        }

        return reference
    }
}

public func ==(obj1: InstructionReference, obj2: InstructionReference) -> Bool {
    let areEqual =
    obj1.label == obj2.label &&
    obj1.value == obj2.value &&
    obj1.separator == obj2.separator &&
    obj1.comment == obj2.comment

    return areEqual
}
