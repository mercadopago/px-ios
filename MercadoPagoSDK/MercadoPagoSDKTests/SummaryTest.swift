//
//  SummaryTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/15/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class SummaryTest: BaseTest {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func getSummaryMultipleProductTaxesShipping() -> Summary {
        var preference = ReviewScreenPreference()
        preference.addSummaryProductDetail(amount: 1000)
        preference.addSummaryProductDetail(amount: 20)
        preference.addSummaryTaxesDetail(amount: 190)
        preference.addSummaryShippingDetail(amount: 100)
        return Summary(details: preference.details)
    }
    func getSummaryProductTaxesShipping() -> Summary {
        var preference = ReviewScreenPreference()
        preference.addSummaryProductDetail(amount: 2000)
        preference.addSummaryTaxesDetail(amount: 190)
        preference.addSummaryShippingDetail(amount: 100)
        return Summary(details: preference.details)
    }

    func getSummaryJustProduct() -> Summary {
        var preference = ReviewScreenPreference()
        preference.addSummaryProductDetail(amount: 1000)
        return Summary(details: preference.details)
    }
    func getSummaryProductTaxesCharge() -> Summary {
        var preference = ReviewScreenPreference()
        preference.addSummaryProductDetail(amount: 2000)
        preference.addSummaryTaxesDetail(amount: 190)
        preference.addSummaryChargeDetail(amount: 1000)
        return Summary(details: preference.details)
    }
    func getSummaryProductTaxesShippingChargeDisclaimer() -> Summary {
        var preference = ReviewScreenPreference()
        preference.addSummaryProductDetail(amount: 2000)
        preference.addSummaryTaxesDetail(amount: 190)
        preference.addSummaryShippingDetail(amount: 100)
        preference.addSummaryChargeDetail(amount: 1000)
        var summary = Summary(details: preference.details)
        summary.disclaimer = "disclaimer test"
        return summary
    }

    func testSummaryMultipleProductTaxesShipping() {
        let summary = getSummaryMultipleProductTaxesShipping()
        XCTAssertEqual(summary.details[SummaryType.PRODUCT]?.getTotalAmount(), 1020)
        XCTAssertEqual(summary.details[SummaryType.TAXES]?.getTotalAmount(), 190)
        XCTAssertEqual(summary.details[SummaryType.SHIPPING]?.getTotalAmount(), 100)
    }
    func testSummaryComponentMultipleProductTaxesShipping() {
        let summary = getSummaryMultipleProductTaxesShipping()
        var summaryComponent = SummaryComponent(frame: CGRect(x: 0, y: 0, width: 320.0, height: 0), summary: summary, paymentData: PaymentData(), totalAmount: 1000)
        XCTAssertEqual(summaryComponent.requiredHeight, 179.0)
    }
    func testSummaryComponentProductTaxesShipping() {
        let summary = getSummaryProductTaxesShipping()
        var summaryComponent = SummaryComponent(frame: CGRect(x: 0, y: 0, width: 320.0, height: 0), summary: summary, paymentData: PaymentData(), totalAmount: 1000)
        XCTAssertEqual(summaryComponent.requiredHeight, 179.0)
    }
    func testSummaryComponentJustProduct() {
        let summary = getSummaryJustProduct()
        var summaryComponent = SummaryComponent(frame: CGRect(x: 0, y: 0, width: 320.0, height: 0), summary: summary, paymentData: PaymentData(), totalAmount: 1000)
        XCTAssertEqual(summaryComponent.requiredHeight, 73.5)
    }
    func testSummaryComponentSummaryProductTaxesShippingCharge() {
        let summary = getSummaryProductTaxesCharge()
        var summaryComponent = SummaryComponent(frame: CGRect(x: 0, y: 0, width: 320.0, height: 0), summary: summary, paymentData: PaymentData(), totalAmount: 1000)
        XCTAssertEqual(summaryComponent.requiredHeight, 179.0)
    }
    func testSummaryComponentSummaryProductTaxesShippingChargeDisclaimer() {
        let summary = getSummaryProductTaxesShippingChargeDisclaimer()
        var summaryComponent = SummaryComponent(frame: CGRect(x: 0, y: 0, width: 320.0, height: 0), summary: summary, paymentData: PaymentData(), totalAmount: 1000)
        XCTAssertEqual(summaryComponent.requiredHeight, 259.0)
    }
    func testSummaryComponentSummaryProductTaxesShippingChargeDisclaimerPayerCost() {
        let summary = getSummaryProductTaxesShippingChargeDisclaimer()
        var summaryComponent = SummaryComponent(frame: CGRect(x: 0, y: 0, width: 320.0, height: 0), summary: summary, paymentData: PaymentData(), totalAmount: 1000)
        summaryComponent.addPayerCost(payerCost: PayerCost(installments: 3, installmentRate: 1.0, labels: [], minAllowedAmount: 12, maxAllowedAmount: 123, recommendedMessage: "testes", installmentAmount: 123.0, totalAmount: 234.0))
        XCTAssertEqual(summaryComponent.requiredHeight, 292.0)
    }

}
