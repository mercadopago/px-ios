//
//  Instruction.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers open class Instruction: NSObject {

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

    open class func fromJSON(_ json: NSDictionary) -> Instruction {
                let instruction = Instruction()

                if json["title"] != nil && !(json["title"]! is NSNull) {
                        instruction.title = (json["title"]! as? String)!
                    }

                if json["subtitle"] != nil && !(json["subtitle"]! is NSNull) {
                        instruction.subtitle = (json["subtitle"]! as? String)!
                    }

                if json["accreditation_message"] != nil && !(json["accreditation_message"]! is NSNull) {
                        instruction.accreditationMessage = (json["accreditation_message"]! as? String)!
                    }

                if json["type"] != nil && !(json["type"]! is NSNull) {
                        if let type = json["type"]! as? String {
                                instruction.type = type
                           }
                   }

                if json["accreditation_comments"] != nil && !(json["accreditation_comments"]! is NSNull) {
                        var info = [String]()

                        if let arrayValues = json["accreditation_comments"] as? NSArray {
                                for value in arrayValues {
                                        if let value = value as? String {
                                                info.append(value)
                                            }
                                    }
                            }
                        instruction.accreditationComment = !info.isEmpty ? info : nil
                    }

            if json["references"] != nil && !(json["references"]! is NSNull) {
                        instruction.references = (json["references"] as! Array).map({InstructionReference.fromJSON($0)})
                    }

                if json["info"] != nil && !(json["info"]! is NSNull) {
                        var info = [String]()

                        if let arrayValues = json["info"] as? NSArray {
                                for value in arrayValues {
                                        if let value = value as? String {
                                            info.append(value)
                                           }
                                    }
                            }

                       instruction.info = info
                    }

                if json["secondary_info"] != nil && !(json["secondary_info"]! is NSNull) {
                        var info = [String]()

                        if let arrayValues = json["secondary_info"] as? NSArray {
                                for value in arrayValues {
                                        if let value = value as? String {
                                                info.append(value)
                                            }
                                    }
                            }
                        instruction.secondaryInfo = !info.isEmpty ? info : nil
                    }

                if json["tertiary_info"] != nil && !(json["tertiary_info"]! is NSNull) {
                        var info = [String]()

                        if let arrayValues = json["tertiary_info"] as? NSArray {
                                for value in arrayValues {
                                        if let value = value as? String {
                                                info.append(value)
                                            }
                                    }

                            }
                        instruction.tertiaryInfo = !info.isEmpty ? info : nil
                    }

                if json["actions"] != nil && !(json["actions"]! is NSNull) {
                        instruction.actions = (json["actions"] as! Array).map({InstructionAction.fromJSON($0)})
                    }

                return instruction
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
