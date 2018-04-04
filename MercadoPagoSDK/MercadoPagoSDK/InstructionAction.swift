//
//  InstructionAction.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class InstructionAction: NSObject {

    var label: String!
    var url: String!
    var tag: String!
}

public enum ActionTag: String {
    case LINK = "link"
    case PRINT = "print"
}
