//
//  InstructionTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class InstructionTest: BaseTest {

    func testFromJSON() {
        let json: NSDictionary = MockManager.getMockFor("Instruction")!
        let instructionFromJSON = Instruction.fromJSON(json)
        XCTAssertEqual(instructionFromJSON, instructionFromJSON)

        XCTAssertEqual(instructionFromJSON.title, "title")
        XCTAssert(instructionFromJSON.hasTitle())

        XCTAssertNil(instructionFromJSON.subtitle)
        XCTAssertFalse(instructionFromJSON.hasSubtitle())

        XCTAssertEqual(instructionFromJSON.accreditationMessage, "accreditation_message")
        XCTAssert(instructionFromJSON.hasAccreditationMessage())

        XCTAssertEqual(instructionFromJSON.secondaryInfo!, ["secondary_info"])
        XCTAssert(instructionFromJSON.hasSecondaryInformation())

        XCTAssertNil(instructionFromJSON.accreditationComment)
        XCTAssertFalse(instructionFromJSON.hasAccreditationComment())

        XCTAssertNil(instructionFromJSON.actions)
        XCTAssertFalse(instructionFromJSON.hasActions())
    }
}
