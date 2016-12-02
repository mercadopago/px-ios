//
//  PaymentTypeTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class PaymentTypeTest: BaseTest {
    
    func testInit(){
        let paymentType = PaymentType(paymentTypeId: PaymentTypeId.CREDIT_CARD)
        XCTAssertEqual(paymentType.paymentTypeId, PaymentTypeId.CREDIT_CARD)
        
    }
    
    
    

    
}
