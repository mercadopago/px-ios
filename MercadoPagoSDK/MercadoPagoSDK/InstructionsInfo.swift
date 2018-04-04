//
//  InstructionsInfo.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 29/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class InstructionsInfo: NSObject {

    var amountInfo: AmountInfo!
    var instructions: [Instruction]!

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
