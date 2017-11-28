//
//  PXHookStep.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

@objc public enum HookStep: Int {
    case AFTER_PAYMENT_TYPE_SELECTED = 1
    case AFTER_PAYMENT_METHOD_SELECTED
    case BEFORE_PAYMENT
}
