//
//  PXPaymentErrorHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 26/06/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
@objc protocol PXPaymentErrorHandlerProtocol: NSObjectProtocol {
    func escError()
    func exitCheckout()
    @objc optional func identificationError()
}
