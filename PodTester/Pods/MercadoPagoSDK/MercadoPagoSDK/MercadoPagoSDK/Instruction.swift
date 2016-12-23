//
//  Instruction.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class Instruction: NSObject {
    
    open var title : String = ""
    open var accreditationMessage : String = ""
    open var references : [InstructionReference]!
    open var info : [String]!
    open var secondaryInfo : [String]?
    open var tertiaryInfo : [String]?
    open var actions : [InstructionAction]?


    open class func fromJSON(_ json : NSDictionary) -> Instruction {
        let instruction = Instruction()
        
        
        if json["title"] != nil && !(json["title"]! is NSNull) {
            instruction.title = (json["title"]! as? String)!
        }
        
        if json["accreditation_message"] != nil && !(json["accreditation_message"]! is NSNull) {
            instruction.accreditationMessage = (json["accreditation_message"]! as? String)!
        }
        
        if json["references"] != nil && !(json["references"]! is NSNull) {
            instruction.references = (json["references"] as! Array).map({InstructionReference.fromJSON($0)})
        }
        
        if json["info"] != nil && !(json["info"]! is NSNull) {
            var info = [String]()
            for value in (json["info"] as! NSArray) {
                info.append(value as! String)
            }
            instruction.info = info
        }
        
        if json["secondary_info"] != nil && !(json["secondary_info"]! is NSNull) {
            var info = [String]()
            for value in (json["secondary_info"] as! NSArray) {
                info.append(value as! String)
            }
            instruction.secondaryInfo = info
        }
        
        if json["tertiary_info"] != nil && !(json["tertiary_info"]! is NSNull) {
            var info = [String]()
            for value in (json["tertiary_info"] as! NSArray) {
                info.append(value as! String)
            }
            instruction.tertiaryInfo = info
        }
        
        if json["actions"] != nil && !(json["actions"]! is NSNull) {
            instruction.actions = (json["actions"] as! Array).map({InstructionAction.fromJSON($0)})
        }
        
        return instruction
    }
    
    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }
    
    open func toJSON() -> [String:Any] {
        let obj:[String:Any] = [
            "title": self.title,
            "accreditationMessage" : self.accreditationMessage
        ]
        return obj
    }
}



public func ==(obj1: Instruction, obj2: Instruction) -> Bool {
    let areEqual =
    obj1.title == obj2.title &&
    obj1.accreditationMessage == obj2.accreditationMessage &&
    obj1.references == obj2.references &&
    obj1.info == obj2.info &&
    obj1.secondaryInfo! == obj2.secondaryInfo! &&
    obj1.tertiaryInfo! == obj2.tertiaryInfo!
  
    
    return areEqual
}
