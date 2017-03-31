//
//  PaymentMethodSearchTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class PaymentMethodSearchTest: BaseTest {
    

    func testPaymentOptionsCount() {
        let customOption = MockBuilder.buildCustomerPaymentMethod("id", paymentMethodId: "paymentMethodId")
        let anotherCustomOption = MockBuilder.buildCustomerPaymentMethod("anotherId", paymentMethodId: "paymentMethodId")
        
        let customOptions = [customOption, anotherCustomOption]
        
        let paymentOption = MockBuilder.buildPaymentMethodSearchItem("id")
        let anotherPaymentOption = MockBuilder.buildPaymentMethodSearchItem("anotherId")
        let anotherMorePaymentOption = MockBuilder.buildPaymentMethodSearchItem("anotherId")
        
        let paymentOptions = [paymentOption, anotherPaymentOption, anotherMorePaymentOption]
        
        let paymentMethodSearch = PaymentMethodSearch()
        paymentMethodSearch.groups = paymentOptions
        paymentMethodSearch.customerPaymentMethods = customOptions
        
        XCTAssertEqual(paymentMethodSearch.getPaymentOptionsCount(), 5)
        
    }
    
    
    func testOnlyCustomOptions() {
        let customOption = MockBuilder.buildCustomerPaymentMethod("id", paymentMethodId: "paymentMethodId")
        let anotherCustomOption = MockBuilder.buildCustomerPaymentMethod("anotherId", paymentMethodId: "paymentMethodId")
        
        let customOptions = [customOption, anotherCustomOption]
        let paymentMethodSearch = PaymentMethodSearch()
        paymentMethodSearch.customerPaymentMethods = customOptions
        
        XCTAssertEqual(paymentMethodSearch.getPaymentOptionsCount(), 2)
        
    }
    
    func testOnlyPaymentOptionsCount() {

        
        
        let paymentOption = MockBuilder.buildPaymentMethodSearchItem("id")
        let anotherPaymentOption = MockBuilder.buildPaymentMethodSearchItem("anotherId")
        let anotherMorePaymentOption = MockBuilder.buildPaymentMethodSearchItem("anotherId")
        
        let paymentOptions = [paymentOption, anotherPaymentOption,anotherMorePaymentOption]
        
        let paymentMethodSearch = PaymentMethodSearch()
        paymentMethodSearch.groups = paymentOptions
        
        XCTAssertEqual(paymentMethodSearch.getPaymentOptionsCount(), 3)
        
    }

}
