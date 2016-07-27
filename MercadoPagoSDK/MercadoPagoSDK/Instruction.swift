//
//  Instruction.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class Instruction: NSObject {
    
    public var title : String = ""
    public var accreditationMessage : String = ""
    public var references : [InstructionReference]!
    public var info : [String]!
    public var secondaryInfo : [String]?
    public var tertiaryInfo : [String]?
    public var actions : [InstructionAction]?


    public class func fromJSON(json : NSDictionary) -> Instruction {
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
    
    public func toJSONString() -> String {
        var obj:[String:AnyObject] = [
            "title": self.title,
            "accreditationMessage" : self.accreditationMessage
            ]
        
        var referencesJson = ""
        for reference in references {
            referencesJson = referencesJson + reference.toJSONString()
        }
        obj["references"] = referencesJson
        
        var infoJson = ""
        for infoItem in info {
            infoJson = infoJson + infoItem + ","
        }
        obj["info"] = infoJson.characters.count > 0 ? (infoJson as NSString).substringToIndex(infoJson.characters.count-1) : ""
        
        var secondaryInfoJson = ""
        if secondaryInfo != nil {
            for secondaryInfoItem in secondaryInfo! {
                secondaryInfoJson = secondaryInfoJson + secondaryInfoItem + ","
            }
            obj["secondaryInfo"] = (secondaryInfoJson as NSString).substringToIndex(secondaryInfoJson.characters.count-1)
        }
        
        var tertiaryInfoJson = ""
        if tertiaryInfo != nil {
            for tertiaryInfoItem in tertiaryInfo! {
                tertiaryInfoJson = tertiaryInfoJson + tertiaryInfoItem + ","
            }
            obj["tertiaryInfo"] = (tertiaryInfoJson as NSString).substringToIndex(tertiaryInfoJson.characters.count-1)
        }
        
        var actionsJson = ""
        if self.actions != nil {
            for actionItem in self.actions! {
                actionsJson = actionsJson + actionItem.toJSONString()
            }
            obj["actions"] = actionsJson
        }
        
        return JSON(obj).toString()
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
