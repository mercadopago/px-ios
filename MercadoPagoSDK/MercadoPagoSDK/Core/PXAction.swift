//
//  PXComponentAction.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/2/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

/**
 This is for custom actions. Label + clousure action. We need this object in certain scenarios. For example in `PXBusinessResult` custom button actions.
 */
@objcMembers
open class PXAction: NSObject {
    var label: String
    var action : (() -> Void)
    // MARK: Initialization
    /**
     Mandatory init.
     - parameter label: The label for your custom action.
     - parameter action: Clousure custom block.
     */
    public init(label: String, action:  @escaping (() -> Void)) {
        self.label = label
        self.action = action
    }
}
