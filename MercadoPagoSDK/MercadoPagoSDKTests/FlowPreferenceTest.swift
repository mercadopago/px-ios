//
//  FlowPreferenceTest.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/24/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class FlowPreferenceTest: BaseTest {

    let flowPreference = FlowPreference()

    func testDisableReviewAndConfirmScreen() {
        flowPreference.disableReviewAndConfirmScreen()
        XCTAssertFalse(flowPreference.isReviewAndConfirmScreenEnable())
    }

    func testDisablePaymentResultScreen() {
        flowPreference.disablePaymentResultScreen()
        XCTAssertFalse(flowPreference.isPaymentResultScreenEnable())
    }

    func testDisablePaymentApprovedScreen() {
        flowPreference.disablePaymentApprovedScreen()
        XCTAssertFalse(flowPreference.isPaymentApprovedScreenEnable())
    }

    func testDisablePaymentRejectedScreen() {
        flowPreference.disablePaymentRejectedScreen()
        XCTAssertFalse(flowPreference.isPaymentRejectedScreenEnable())
    }
    func testDisableDefaultSelection() {
        flowPreference.disableDefaultSelection()
        XCTAssertFalse(flowPreference.isPaymentSearchScreenEnable())
    }

    func testDisableBankDeals() {
        flowPreference.disableBankDeals()
        XCTAssertFalse(CardFormViewController.showBankDeals)
    }

    func testEnablePaymentPendingScreen() {
        flowPreference.disablePaymentPendingScreen()
        XCTAssertFalse(flowPreference.isPaymentPendingScreenEnable())
    }
    func testEnableReviewAndConfirmScreen() {
        XCTAssert(flowPreference.isReviewAndConfirmScreenEnable())
        flowPreference.disableReviewAndConfirmScreen()
        flowPreference.enableReviewAndConfirmScreen()
        XCTAssert(flowPreference.isReviewAndConfirmScreenEnable())
    }

    func testEnablePaymentResultScreen() {
        XCTAssert(flowPreference.isPaymentResultScreenEnable())
        flowPreference.disablePaymentResultScreen()
        flowPreference.enablePaymentResultScreen()
        XCTAssert(flowPreference.isPaymentResultScreenEnable())
    }

    func testEnablePaymentApprovedScreen() {
        XCTAssert(flowPreference.isPaymentApprovedScreenEnable())
        flowPreference.disablePaymentApprovedScreen()
        flowPreference.enablePaymentApprovedScreen()
        XCTAssert(flowPreference.isPaymentApprovedScreenEnable())
    }

    func testEnablePaymentRejectedScreen() {
        XCTAssert(flowPreference.isPaymentRejectedScreenEnable())
        flowPreference.disablePaymentRejectedScreen()
        flowPreference.enablePaymentRejectedScreen()
        XCTAssert(flowPreference.isPaymentRejectedScreenEnable())
    }

    func testEnablePaymentPendingdScreen() {
        XCTAssert(flowPreference.isPaymentPendingScreenEnable())
        flowPreference.disablePaymentPendingScreen()
        flowPreference.enablePaymentPendingScreen()
        XCTAssert(flowPreference.isPaymentPendingScreenEnable())
    }

    func testEnableDefaultSelection() {
        XCTAssert(flowPreference.isPaymentSearchScreenEnable())
        flowPreference.disableDefaultSelection()
        flowPreference.enableDefaultSelection()
        XCTAssert(flowPreference.isPaymentSearchScreenEnable())
    }

    func testEnableBankDeals() {
        flowPreference.enableBankDeals()
        XCTAssert(CardFormViewController.showBankDeals)
    }

    func testDefaultMaxSavedCards() {
        XCTAssertEqual(3, flowPreference.getMaxSavedCardsToShow())
        XCTAssertFalse(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCards() {
        flowPreference.setMaxSavedCardsToShow(fromInt: 5)
        XCTAssertEqual(5, flowPreference.getMaxSavedCardsToShow())
        XCTAssertFalse(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCardsWithInvalidInt() {
        flowPreference.setMaxSavedCardsToShow(fromInt: 0)
        XCTAssertEqual(3, flowPreference.getMaxSavedCardsToShow())
        XCTAssertFalse(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCardsWithNegativeInt() {
        flowPreference.setMaxSavedCardsToShow(fromInt: -1)
        XCTAssertEqual(3, flowPreference.getMaxSavedCardsToShow())
        XCTAssertFalse(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCardsWithEmptyString() {
        flowPreference.setMaxSavedCardsToShow(fromString: "")
        XCTAssertEqual(3, flowPreference.getMaxSavedCardsToShow())
        XCTAssertFalse(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCardsWithInvalidString() {
        flowPreference.setMaxSavedCardsToShow(fromString: "invalid")
        XCTAssertEqual(3, flowPreference.getMaxSavedCardsToShow())
        XCTAssertFalse(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCardsToShowAll() {
        flowPreference.setMaxSavedCardsToShow(fromString: FlowPreference.SHOW_ALL_SAVED_CARDS_CODE)
        XCTAssertTrue(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testDisableInstallmentsReviewScreen() {
        flowPreference.disableInstallmentsReviewScreen()
        XCTAssertFalse(flowPreference.isInstallmentsReviewScreenEnable())
    }

    func testEnableInstallmentsReviewScreen() {
        XCTAssert(flowPreference.isInstallmentsReviewScreenEnable())
        flowPreference.disableInstallmentsReviewScreen()
        flowPreference.enableInstallmentsReviewScreen()
        XCTAssert(flowPreference.isInstallmentsReviewScreenEnable())
    }

}
