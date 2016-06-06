//
//  UICellValidator.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 6/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

class MPCellValidator: NSObject {

    class func fillInstructionReference(reference : InstructionReference, label : MPLabel, referenceValueLabel : MPLabel) {
        if reference.value != nil && reference.value.count > 0 && reference.label != nil {
            label.text = reference.label.uppercaseString
            referenceValueLabel.text = reference.getFullReferenceValue()
        } else {
            label.text = ""
            referenceValueLabel.text = ""
        }
    }
}
