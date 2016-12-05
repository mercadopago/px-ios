//
//  PayerCostTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class PayerCostTest: BaseTest {
    
    let labels = ["label1", "label2"]
    
    func testPayerCost(){
    
        let payerCost = PayerCost(installments: 6, installmentRate: 1.2, labels: labels, minAllowedAmount: 5, maxAllowedAmount: 500, recommendedMessage: "message", installmentAmount: 5.0, totalAmount: 30.0)
        
        XCTAssertEqual(payerCost.installments, 6)
        XCTAssertEqual(payerCost.installmentRate, 1.2)
        XCTAssertEqual(payerCost.labels, labels)
        XCTAssertEqual(payerCost.minAllowedAmount, 5)
        XCTAssertEqual(payerCost.maxAllowedAmount, 500)
        XCTAssertEqual(payerCost.recommendedMessage, "message")
        XCTAssertEqual(payerCost.installmentAmount, 5.0)
        XCTAssertEqual(payerCost.totalAmount, 30.0)
    }
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("PayerCost")!
        let payerCostFromJSON = PayerCost.fromJSON(json)
        XCTAssertEqual(payerCostFromJSON, payerCostFromJSON)
    }
    
}
