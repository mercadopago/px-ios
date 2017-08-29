//
//  SecurityCodeViewModelTest.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 7/17/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class SecurityCodeViewModelTest: BaseTest {

    var securityCodeViewModel: SecurityCodeViewModel!
    var paymentMethod: PaymentMethod!
    var cardInfo: Token!

    override func setUp() {
        super.setUp()
        paymentMethod = MockBuilder.buildPaymentMethod("master", name: "MasterCard", paymentTypeId: "credit_card", multipleSettings: false)
        cardInfo = MockBuilder.buildToken()

        let reason = SecurityCodeViewModel.Reason.SAVED_CARD

        securityCodeViewModel = SecurityCodeViewModel(paymentMethod: paymentMethod, cardInfo: cardInfo, reason: reason)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testPaymentMethodSecurityCodeSettings() {
        let securityCodeInBack = securityCodeViewModel.secCodeInBack()
        XCTAssertEqual(securityCodeInBack, paymentMethod.secCodeInBack())

        let securityCodeLenght = securityCodeViewModel.secCodeLenght()
        XCTAssertEqual(securityCodeLenght, paymentMethod.secCodeLenght())

    }

    func testGetPaymentMethodColors() {
        let pmColor = securityCodeViewModel.getPaymentMethodColor()
        XCTAssertEqual(pmColor, paymentMethod.getColor(bin: cardInfo.getCardBin()))
        let pmFontColor = securityCodeViewModel.getPaymentMethodFontColor()
        XCTAssertEqual(pmFontColor, paymentMethod.getFontColor(bin: cardInfo.getCardBin()))
    }
}
