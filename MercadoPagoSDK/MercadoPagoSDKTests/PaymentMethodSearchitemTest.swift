//
//  PaymentMethodSearchitemTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class PaymentMethodSearchitemTest: BaseTest {

    func testIsOfflinePayment() {
        let offlinePaymentMethodSearchItem = MockBuilder.buildPaymentMethodSearchItem("bank_transfer")

        XCTAssertTrue(offlinePaymentMethodSearchItem.isOfflinePayment())

        let onlinePaymentMethodSearchItem = MockBuilder.buildPaymentMethodSearchItem("credit_card")
        XCTAssertFalse(onlinePaymentMethodSearchItem.isOfflinePayment())

    }

    func testIsBitcoin() {
        let bitcoinPm = MockBuilder.buildPaymentMethodSearchItem("bitcoin")

        XCTAssertTrue(bitcoinPm.isBitcoin())

        let onlinePaymentMethodSearchItem = MockBuilder.buildPaymentMethodSearchItem("credit_card")
        XCTAssertFalse(onlinePaymentMethodSearchItem.isBitcoin())

    }

    func testIsPaymentMethod() {
        let oxxoPm = MockBuilder.buildPaymentMethodSearchItem("oxxo", type: PaymentMethodSearchItemType.PAYMENT_METHOD)

        XCTAssertTrue(oxxoPm.isPaymentMethod())

        let onlinePaymentMethodSearchItem = MockBuilder.buildPaymentMethodSearchItem("visa", type: PaymentMethodSearchItemType.PAYMENT_METHOD)
        XCTAssertTrue(onlinePaymentMethodSearchItem.isPaymentMethod())

        let onlinePaymentType = MockBuilder.buildPaymentMethodSearchItem("debit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        XCTAssertFalse(onlinePaymentType.isPaymentMethod())

    }
}
