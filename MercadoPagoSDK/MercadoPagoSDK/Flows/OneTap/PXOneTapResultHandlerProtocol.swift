//
//  PXOneTapResultHandlerProtocol.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 03/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: - Not intended for public use. */
protocol PXOneTapResultHandlerProtocol: NSObjectProtocol {
    func finishOneTap(paymentResult: PaymentResult, instructionsInfo: InstructionsInfo?)
    func finishOneTap(businessResult: PXBusinessResult)
    func finishOneTap(paymentData: PaymentData)
    func cancelOneTap()
    func exitCheckout()
}
