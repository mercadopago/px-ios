//
//  PaymentMethodSearchServiceTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 14/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class PaymentMethodSearchServiceTest: BaseTest {
    
    override func setUp() {
        super.setUp()
        MercadoPagoContext.setPublicKey(MockBuilder.MLA_PK)
    }
    
    
    func testMPServicePaymentMethodSearch() {
     /*   let expectation = expectationWithDescription("paymentMethodSearchService")
        MPServicesBuilder.searchPaymentMethods(nil, excludedPaymentMethods: nil, success: { (PaymentMethodSearch) -> Void in
            expectation.fulfill()
            }) { (error) -> Void in
        }
        waitForExpectationsWithTimeout(10.0, handler: nil)*/
    }
    
    func testMPServicePaymentMethodSearchWithExcludedPaymentTypes() {
    /*     let expectation = expectationWithDescription("paymentMethodSearchService")
       MPServicesBuilder.searchPaymentMethods(MockBuilder.getMockPaymentTypeIds(), excludedPaymentMethods: nil, success: { (PaymentMethodSearch) -> Void in
            expectation.fulfill()
            }) { (error) -> Void in
        }
        waitForExpectationsWithTimeout(10.0, handler: nil)*/
    }
    
       
}
