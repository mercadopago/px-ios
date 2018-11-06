//
//  PXOneTapResultHandlerProtocol.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 03/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal protocol PXOneTapResultHandlerProtocol: NSObjectProtocol {
    func finishOneTap(paymentResult: PaymentResult, instructionsInfo: PXInstructions?)
    func finishOneTap(businessResult: PXBusinessResult, paymentData: PXPaymentData)
    func finishOneTap(paymentData: PXPaymentData)
    func cancelOneTap()
    func cancelOneTapForNewPaymentMethodSelection()
    func exitCheckout()
}
