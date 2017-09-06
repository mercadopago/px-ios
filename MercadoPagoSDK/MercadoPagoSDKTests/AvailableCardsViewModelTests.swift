//
//  AvailableCardsViewModelTests.swift
//  MercadoPagoSDK
//
//  Created by Angie Arlanti on 9/6/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class AvailableCardsViewModelTests: BaseTest {
    
    func testGetAvailableCardsViewTotalHeight(){
        var paymentMethodsCount:CGFloat = 3.0
        let headerHeight:CGFloat = 105.0
        let paymentMethodsHeight:CGFloat = 40.0
        let viewModel = AvailableCardsViewModel(paymentMethods: [PaymentMethod]())
        
        var expectedTotalHeight = headerHeight + paymentMethodsHeight * paymentMethodsCount
        XCTAssertEqual(viewModel.getAvailableCardsViewTotalHeight(headerHeight: headerHeight, paymentMethodsHeight: paymentMethodsHeight, paymentMethodsCount: paymentMethodsCount), expectedTotalHeight)
        
        paymentMethodsCount = 100
        expectedTotalHeight = headerHeight + paymentMethodsHeight * paymentMethodsCount
        XCTAssertNotEqual(viewModel.getAvailableCardsViewTotalHeight(headerHeight: headerHeight, paymentMethodsHeight: paymentMethodsHeight, paymentMethodsCount: paymentMethodsCount), expectedTotalHeight)
        
        let maxTotalHeight = viewModel.screenHeight * viewModel.MIN_HEIGHT_PERCENT
            
        XCTAssertEqual(viewModel.getAvailableCardsViewTotalHeight(headerHeight: headerHeight, paymentMethodsHeight: paymentMethodsHeight, paymentMethodsCount: paymentMethodsCount), maxTotalHeight)
    }
}
