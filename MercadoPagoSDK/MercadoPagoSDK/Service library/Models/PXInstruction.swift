//
//  PXInstruction.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXInstruction: NSObject {
    open var title: String!
    open var subtitle: String!
    open var accreditationMessage: String!
    open var acceditationComments: [String]!
    open var action: [PXInstructionActionInfo]!
    open var type: String!
    open var references: [InstructionReference]!
    open var secondaryInfo: [String]!
    open var tertiaryInfo: [String]!
    open var info: [String]!

}
