//
//  PXPaymentResultHandlerProtocol.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 03/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
protocol PXPaymentResultHandlerProtocol: NSObjectProtocol {
    func finishPaymentFlow(paymentResult: PaymentResult, instructionsInfo: InstructionsInfo?)
    func finishPaymentFlow(businessResult: PXBusinessResult)
    func finishPaymentFlow(error: MPSDKError)
}
