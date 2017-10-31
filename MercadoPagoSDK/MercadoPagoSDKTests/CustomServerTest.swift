//
//  CustomServerTest.swift
//  MercadoPagoSDK
//
//  Created by Mauro Reverter on 6/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import XCTest

class CustomServerTest: BaseTest {

    func testWhenPaymentsResponseStatusIsProcessingThenMapResponseToPaymentInProcess() {
        let payerDict: NSMutableDictionary = NSMutableDictionary()
        payerDict.setValue("android-was-here@gmail.com", forKey: "email")
        let paymentBodyDict: NSMutableDictionary = NSMutableDictionary()
        paymentBodyDict.setValue(payerDict, forKey: "payer")
        let mercadoPagoServicesAdapter = MercadoPagoServicesAdapter()
        mercadoPagoServicesAdapter.createPayment(url: "http://api.mercadopago.com", uri: "/v1/checkout/payments?public_key=PK-PROCESSING-TEST&payment_method_id=visa", transactionId: nil, paymentData: paymentBodyDict, callback: { (payment: Payment) -> Void in
            XCTAssertEqual(payment.status, PaymentStatus.IN_PROCESS)
        }, failure: { (_: NSError) -> Void in
            XCTFail()
        })
    }
}
