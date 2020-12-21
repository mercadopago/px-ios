//
//  MercadoPagoCheckout+PaymentErrorHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 03/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
extension MercadoPagoCheckout: PXPaymentErrorHandlerProtocol {
    func escError(reason: PXESCDeleteReason) {
        viewModel.invalidESCReason = reason
        viewModel.prepareForInvalidPaymentWithESC(reason: reason)
        executeNextStep()
    }
}
