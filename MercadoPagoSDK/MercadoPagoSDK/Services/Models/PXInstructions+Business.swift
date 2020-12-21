//
//  PXInstructions+Business.swift
//  MercadoPagoSDKV4
//
//  Created by Eden Torres on 27/08/2018.
//

import Foundation

/// :nodoc:
extension PXInstructions {
    open func hasSubtitle() -> Bool {
        if instructions.isEmpty {
            return false
        } else {
            return !Array.isNullOrEmpty(instructions.first?.secondaryInfo)
        }
    }

    internal func getInstruction() -> PXInstruction? {
        if instructions.isEmpty {
            return nil
        } else {
            return instructions[0]
        }
    }
}
