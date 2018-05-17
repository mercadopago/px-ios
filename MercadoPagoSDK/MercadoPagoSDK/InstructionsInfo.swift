//
//  InstructionsInfo.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 29/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers open class InstructionsInfo: NSObject {

    var amountInfo: AmountInfo!
    var instructions: [Instruction]!

    open class func fromJSON(_ json: NSDictionary) -> InstructionsInfo {
        let instructionsInfo: InstructionsInfo = InstructionsInfo()

        if json["amount_info"] != nil && !(json["amount_info"]! is NSNull) {
            instructionsInfo.amountInfo = AmountInfo.fromJSON(json["amount_info"] as! NSDictionary)
        }

        if json["instructions"] != nil && !(json["instructions"]! is NSNull) {

            var instructions = [Instruction]()
            let jsonResultArr = json["instructions"] as! NSArray
            for instuctionJson in jsonResultArr {
                instructions.append(Instruction.fromJSON(instuctionJson as! NSDictionary))
            }
            instructionsInfo.instructions = instructions
        }
        return instructionsInfo
    }

    open func hasSecundaryInformation() -> Bool {
        if instructions.isEmpty {
            return false
        } else {
            return instructions[0].hasSecondaryInformation()
        }
    }

    open func hasSubtitle() -> Bool {
        if instructions.isEmpty {
            return false
        } else {
            return instructions[0].hasSubtitle()
        }
    }

    open func getInstruction() -> Instruction? {
        if instructions.isEmpty {
            return nil
        } else {
            return instructions[0]
        }
    }

    open func toJSONString() -> String {
        var obj: [String: Any] = [
            "amount_info": self.amountInfo.toJSON()
        ]

        if self.instructions != nil && self.instructions.count > 0 {
            let array = NSMutableArray()
            for inst in instructions {
                let instruction = inst.toJSON() as [String: AnyObject]
                array.add(instruction)
            }
            obj["instructions"] = array
        }

        return JSONHandler.jsonCoding(obj)
    }
}
