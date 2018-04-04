//
//  PayerCostTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class PayerCostTest: BaseTest {

    let labels = ["label1", "label2"]

    func testPayerCost() {

        let payerCost = PayerCost(installments: 6, installmentRate: 1.2, labels: labels, minAllowedAmount: 5, maxAllowedAmount: 500, recommendedMessage: "message", installmentAmount: 5.0, totalAmount: 30.0)

        XCTAssertEqual(payerCost.installments, 6)
        XCTAssertEqual(payerCost.installmentRate, 1.2)
        XCTAssertEqual(payerCost.labels, labels)
        XCTAssertEqual(payerCost.minAllowedAmount, 5)
        XCTAssertEqual(payerCost.maxAllowedAmount, 500)
        XCTAssertEqual(payerCost.recommendedMessage, "message")
        XCTAssertEqual(payerCost.installmentAmount, 5.0)
        XCTAssertEqual(payerCost.totalAmount, 30.0)
    }

    func testGetCFT() {
    let payerCost = PayerCost(installments: 6, installmentRate: 1.2, labels: labels, minAllowedAmount: 5, maxAllowedAmount: 500, recommendedMessage: "message", installmentAmount: 5.0, totalAmount: 30.0)
        payerCost.labels = ["CFT_89,38%|TEA_71,14%"]
        XCTAssertEqual(payerCost.getCFTValue(), "89,38%")
        XCTAssertEqual(payerCost.getTEAValue(), "71,14%")
        payerCost.labels = ["CFT_89,23%|TEA_70,74%"]
        XCTAssertEqual(payerCost.getCFTValue(), "89,23%")
        XCTAssertEqual(payerCost.getTEAValue(), "70,74%")
        payerCost.labels = ["CFT_88,33%|TEA_69,73%", "recommended_interest_installment_with_some_banks"]
        XCTAssertEqual(payerCost.getCFTValue(), "88,33%")
        XCTAssertEqual(payerCost.getTEAValue(), "69,73%")
        payerCost.labels = []
        XCTAssertEqual(payerCost.getCFTValue(), nil)
        XCTAssertEqual(payerCost.getTEAValue(), nil)
    }

}
