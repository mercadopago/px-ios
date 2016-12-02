//
//  InstructionTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class InstructionTest: BaseTest {
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Instruction")!
        let instructionFromJSON = Instruction.fromJSON(json)
        XCTAssertEqual(instructionFromJSON, instructionFromJSON)
    }
}
