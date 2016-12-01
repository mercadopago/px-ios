//
//  TransactionDetailsTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class TransactionDetailsTest: BaseTest {
    
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("TransactionDetails")!
        let transactionDetailsFromJSON = TransactionDetails.fromJSON(json)
        XCTAssertEqual(transactionDetailsFromJSON, transactionDetailsFromJSON)
    }

}
