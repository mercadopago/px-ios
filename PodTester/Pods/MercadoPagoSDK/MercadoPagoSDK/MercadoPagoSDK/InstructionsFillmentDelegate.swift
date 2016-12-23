//
//  InstructionsFillmentDelegate.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public protocol InstructionsFillmentDelegate {

    func fillCell(_ instruction : Instruction) -> UITableViewCell
    func getCellHeight(_ instruction : Instruction, forFontSize : CGFloat) -> CGFloat
}
