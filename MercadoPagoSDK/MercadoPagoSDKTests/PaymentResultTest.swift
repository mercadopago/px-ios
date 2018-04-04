//
//  PaymentResultTest.swift
//  MercadoPagoSDK
//
//  Created by Mauro Reverter on 6/15/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK
class PaymentResultTest: BaseTest {
    override func setUp() {
        super.setUp()
    }

    func testPayerEmailObtainedFromPaymentData() {
        let payment = Payment()
        payment.paymentId = "1"
        payment.status = "approved"
        payment.statusDetail = "accredited"
        let payer = Payer()
        payer.email = "unemail@gmail.com"
        let paymentData = PaymentData()
        paymentData.payer = payer
        let paymentResult = PaymentResult(payment: payment, paymentData: paymentData)
        XCTAssertEqual(paymentResult.payerEmail, "unemail@gmail.com")
    }
}
