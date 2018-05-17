//
//  PXFooterComponentTest.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import XCTest

class PXFooterComponentTest: BaseTest {

    // MARK: APPROVED - CARD
    func testFooterView_approvedCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel()

        // When:
        let footerView = ResultMockComponentHelper.buildFooterView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(footerView.principalButton)
        XCTAssertEqual(footerView.linkButton?.buttonTitle, PXFooterResultConstants.APPROVED_LINK_TEXT.localized_beta)
    }

    // MARK: APPROVED - ACCOUNT MONEY
    func testFooterView_approvedAccountMoney_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(paymentMethodId: "account_money", paymentTypeId: "account_money")

        // When:
        let footerView = ResultMockComponentHelper.buildFooterView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(footerView.principalButton)
        XCTAssertEqual(footerView.linkButton?.buttonTitle, PXFooterResultConstants.APPROVED_LINK_TEXT.localized_beta)
    }

    // MARK: REJECTED - CARD
    func testFooterView_rejectedCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "rejected")

        // When:
        let footerView = ResultMockComponentHelper.buildFooterView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(footerView.principalButton?.buttonTitle, PXFooterResultConstants.ERROR_BUTTON_TEXT.localized)
        XCTAssertEqual(footerView.linkButton?.buttonTitle, PXFooterResultConstants.ERROR_LINK_TEXT.localized)
    }

    func testFooterView_rejectedC4AuthCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "rejected", statusDetail: RejectedStatusDetail.CALL_FOR_AUTH)

        // When:
        let footerView = ResultMockComponentHelper.buildFooterView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(footerView.principalButton?.buttonTitle, PXFooterResultConstants.C4AUTH_BUTTON_TEXT.localized)
        XCTAssertEqual(footerView.linkButton?.buttonTitle, PXFooterResultConstants.C4AUTH_LINK_TEXT.localized)
    }

    // MARK: PENDING - CARD
    func testFooterView_pendingCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "in_process")

        // When:
        let footerView = ResultMockComponentHelper.buildFooterView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(footerView.principalButton)
        XCTAssertEqual(footerView.linkButton?.buttonTitle, PXFooterResultConstants.APPROVED_LINK_TEXT.localized_beta)
    }

    // MARK: Instructions
    func testFootertView_instructionsPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModelWithInstructionInfo()

        // When:
        let footerView = ResultMockComponentHelper.buildFooterView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertNil(footerView.principalButton)
        XCTAssertEqual(footerView.linkButton?.buttonTitle, PXFooterResultConstants.APPROVED_LINK_TEXT.localized_beta)
    }

}
