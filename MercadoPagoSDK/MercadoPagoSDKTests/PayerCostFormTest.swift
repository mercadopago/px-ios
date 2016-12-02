//
//  PayerCostFormTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 4/18/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class PayerCostFormTest: BaseTest {
    
    var payerCostFormViewController : PayerCostViewController?
    
    
    override func setUp() {
        super.setUp()
       /* MercadoPagoContext.setPublicKey(MockBuilder.MOCK_PUBLIC_KEY)
       
        self.payerCostFormViewController = MPStepBuilder.startPayerCostForm(nil, issuer: nil, cardToken: <#T##CardToken#>, amount: 10000, minInstallments: 1, callback: { (payerCost) -> Void in
        })
 
        self.simulateViewDidLoadFor(self.payerCostFormViewController!)*/    
 }
 
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
