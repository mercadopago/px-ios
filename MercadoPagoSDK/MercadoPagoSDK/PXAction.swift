//
//  PXAction.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

open class PXAction: NSObject {
    var label: String
    var action : (() -> Void)
    public init(label: String, action:  @escaping (() -> Void)) {
        self.label = label
        self.action = action
    }
}
