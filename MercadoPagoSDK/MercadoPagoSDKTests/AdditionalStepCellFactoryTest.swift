//
//  AdditionalStepCellFactoryTest.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 6/30/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class AdditionalStepCellFactoryTest: BaseTest {
    func testNeedsCFTPayerCost_payerCostNoCFT_withReviewAndConfirm() {
        let payerCost = MockBuilder.buildPayerCost()
        XCTAssertFalse(AdditionalStepCellFactory.needsCFTPayerCostCell(payerCost: payerCost))
    }

    func testNeedsCFTPayerCost_payerCostWithCFT_withReviewAndConfirm() {
        let payerCost = MockBuilder.buildPayerCost(hasCFT: true)
        XCTAssertFalse(AdditionalStepCellFactory.needsCFTPayerCostCell(payerCost: payerCost))
    }

    func testNeedsCFTPayerCost_payerCostWithCFT_noReviewAndConfirm() {
        let flowPreference = FlowPreference()
        flowPreference.disableReviewAndConfirmScreen()
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        let payerCost = MockBuilder.buildPayerCost(hasCFT: true)
        XCTAssertTrue(AdditionalStepCellFactory.needsCFTPayerCostCell(payerCost: payerCost))
    }

    func testNeedsCFTPayerCost_payerCostWithNOCFT_noReviewAndConfirm() {
        let flowPreference = FlowPreference()
        flowPreference.disableReviewAndConfirmScreen()
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        let payerCost = MockBuilder.buildPayerCost()
        XCTAssertFalse(AdditionalStepCellFactory.needsCFTPayerCostCell(payerCost: payerCost))
    }

    func testNeedsCFTPayerCost_payerCostWithCFT_noReviewAndConfirm_noConfirm() {
        let flowPreference = FlowPreference()
        flowPreference.disableReviewAndConfirmScreen()
        flowPreference.disableInstallmentsReviewScreen()
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        let payerCost = MockBuilder.buildPayerCost(hasCFT: true)
        XCTAssertFalse(AdditionalStepCellFactory.needsCFTPayerCostCell(payerCost: payerCost))
    }

    func testNeedsCFTPayerCost_payerCostWithNOCFT_noReviewAndConfirm_noConfirm() {
        let flowPreference = FlowPreference()
        flowPreference.disableReviewAndConfirmScreen()
        flowPreference.disableInstallmentsReviewScreen()
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        let payerCost = MockBuilder.buildPayerCost()
        XCTAssertFalse(AdditionalStepCellFactory.needsCFTPayerCostCell(payerCost: payerCost))
    }

}
