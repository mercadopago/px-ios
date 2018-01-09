//
//  PXCustomComponentTest.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import XCTest

class PXCustomComponentTest: BaseTest {

    // MARK: APPROVED - CARD
    func testCustomView_approvedCardPaymentNoPreference_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel()

        // When:
        let topCustomComponent = ResultMockComponentHelper.buildTopCustomComponent(resultViewModel: resultViewModel)
        let bottomCustomComponent = ResultMockComponentHelper.buildBottomCustomComponent(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
    }
    func testCustomView_approvedCardPaymentPreference_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModelWithPreference()

        // When:
        let topCustomComponent = ResultMockComponentHelper.buildTopCustomComponent(resultViewModel: resultViewModel)
        let bottomCustomComponent = ResultMockComponentHelper.buildBottomCustomComponent(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNotNil(topCustomComponent)
        XCTAssertNotNil(bottomCustomComponent)
    }

    // MARK: APPROVED - ACCOUNT MONEY
    func testCustomView_approvedAccountMoney_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(paymentMethodId: "account_money", paymentTypeId: "account_money")

        // When:
        let topCustomComponent = ResultMockComponentHelper.buildTopCustomComponent(resultViewModel: resultViewModel)
        let bottomCustomComponent = ResultMockComponentHelper.buildBottomCustomComponent(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
    }

    // MARK: REJECTED - CARD
    func testCustomView_rejectedCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "rejected")

        // When:
        let topCustomComponent = ResultMockComponentHelper.buildTopCustomComponent(resultViewModel: resultViewModel)
        let bottomCustomComponent = ResultMockComponentHelper.buildBottomCustomComponent(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
    }

    // MARK: PENDING - CARD
    func testCustomView_pendingCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "in_process")

        // When:
        let topCustomComponent = ResultMockComponentHelper.buildTopCustomComponent(resultViewModel: resultViewModel)
        let bottomCustomComponent = ResultMockComponentHelper.buildBottomCustomComponent(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
    }
}
