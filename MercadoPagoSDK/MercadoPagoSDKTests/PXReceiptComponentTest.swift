//
//  PXReceiptComponentTest.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import XCTest

class PXReceiptComponentTest: BaseTest {

    // MARK: APPROVED - CARD
    func testReceiptView_approvedCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel()

        // When:
        let receiptView = ResultMockComponentHelper.buildReceiptView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNotNil(receiptView?.dateLabel)
        XCTAssertNotNil(receiptView?.detailLabel)
    }

    func testReceiptView_approvedCardPaymentPreference_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModelWithPreference()

        // When:
        let receiptView = ResultMockComponentHelper.buildReceiptView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(receiptView?.dateLabel)
        XCTAssertNil(receiptView?.detailLabel)
    }

    // MARK: APPROVED - ACCOUNT MONEY
    func testReceiptView_approvedAccountMoney_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(paymentMethodId: "account_money", paymentTypeId: "account_money")

        // When:
        let receiptView = ResultMockComponentHelper.buildReceiptView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNotNil(receiptView?.dateLabel)
        XCTAssertNotNil(receiptView?.detailLabel)
    }

    // MARK: REJECTED - CARD
    func testReceiptView_rejectedCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "rejected")

        // When:
        let receiptView = ResultMockComponentHelper.buildReceiptView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(receiptView?.dateLabel)
        XCTAssertNil(receiptView?.detailLabel)
    }

    func testReceiptView_rejectedC4AuthCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "rejected", statusDetail: RejectedStatusDetail.CALL_FOR_AUTH)

        // When:
        let receiptView = ResultMockComponentHelper.buildReceiptView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(receiptView?.dateLabel)
        XCTAssertNil(receiptView?.detailLabel)
    }

    // MARK: PENDING - CARD
    func testReceiptView_pendingCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "in_process")

        // When:
        let receiptView = ResultMockComponentHelper.buildReceiptView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(receiptView?.dateLabel)
        XCTAssertNil(receiptView?.detailLabel)
    }

    // MARK: Instructions
    func testReceiptView_instructionsPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModelWithInstructionInfo()

        // When:
        let receiptView = ResultMockComponentHelper.buildReceiptView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(receiptView?.dateLabel)
        XCTAssertNil(receiptView?.detailLabel)
    }
}
