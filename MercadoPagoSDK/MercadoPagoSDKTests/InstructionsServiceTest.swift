//
//  InstructionsServiceTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 17/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class InstructionsServiceTest: BaseTest {

    override func setUp() {
        super.setUp()
     //   MercadoPagoContext.setPublicKey(MockBuilder.MOCK_PUBLIC_KEY)
    }

    func testInstructionService() {
       /* let expectInstructionService = expectationWithDescription("instructionService")
        MercadoPagoServices.getInstructionsByPaymentId(MockBuilder.MOCK_PAYMENT_ID, paymentMethodId: "oxxo", success: { (instruction) -> Void in
            expectInstructionService.fulfill()
            }) { (error) -> Void in
        }
        waitForExpectationsWithTimeout(10.0, handler: nil)*/
    }

    func testInstructionServiceInvalidPublicKey() {
       /* MercadoPagoContext.setPublicKey("")
        let expectInstructionService = expectationWithDescription("instructionServiceFails")
        MercadoPagoServices.getInstructionsByPaymentId(MockBuilder.MOCK_PAYMENT_ID, paymentMethodId: "oxxo", success: { (instruction) -> Void in
            
            }) { (error) -> Void in
                expectInstructionService.fulfill()
        }
        waitForExpectationsWithTimeout(10.0, handler: nil)*/
    }

}
