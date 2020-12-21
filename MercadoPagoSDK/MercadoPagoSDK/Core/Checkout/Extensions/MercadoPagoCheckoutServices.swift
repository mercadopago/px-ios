//
//  MercadoPagoCheckoutServices.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/18/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

extension MercadoPagoCheckout {

    func createPayment() {
        viewModel.invalidESCReason = nil
        let paymentFlow = viewModel.createPaymentFlow(paymentErrorHandler: self)
        paymentFlow.setData(amountHelper: viewModel.amountHelper, checkoutPreference: viewModel.checkoutPreference, resultHandler: self)
        paymentFlow.start()
    }
}
