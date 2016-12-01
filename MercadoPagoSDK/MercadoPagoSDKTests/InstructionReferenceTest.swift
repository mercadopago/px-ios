//
//  InstructionReferenceTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class InstructionReferenceTest: BaseTest {
    

    func testGetFullReferenceValue() {
        let instructionReference = InstructionReference()
        instructionReference.separator = ""
        instructionReference.value = ["1","2","3"]
        var result = instructionReference.getFullReferenceValue()
        XCTAssertEqual(result, "123")
        
        instructionReference.separator = "-"
        result = instructionReference.getFullReferenceValue()
        //XCTAssertEqual(result, "1-2-3")
        
    }
}
