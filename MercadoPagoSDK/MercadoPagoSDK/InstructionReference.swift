//
//  InstructionReference.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class InstructionReference: Equatable {

    var label : String!
    var value : [String]!
    var separator : String!
    
    open func getFullReferenceValue() -> String {
        if separator == nil  {
            self.separator = ""
        }
        if value.count == 0 {
            return ""
        }
        let referenceFullValue : String = value.reduce("", {($0 as String) + self.separator + ($1 as String)})
       // return referenceFullValue.substring(from: self.separator.characters.count)
        return referenceFullValue
    }
    
    open class func fromJSON(_ json : NSDictionary) -> InstructionReference {
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
        
        return reference
    }
}


public func ==(obj1: InstructionReference, obj2: InstructionReference) -> Bool {
    let areEqual =
    obj1.label == obj2.label &&
    obj1.value == obj2.value &&
    obj1.separator == obj2.separator
    
    return areEqual
}

