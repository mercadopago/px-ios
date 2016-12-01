//
//  InstallmentTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class InstallmentTest: BaseTest {
    
    func testInstallment(){
    
    }
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Installment")!
        let installmentFromJSON = Installment.fromJSON(json)
        XCTAssertEqual(installmentFromJSON, installmentFromJSON)
    }
    
    
}
