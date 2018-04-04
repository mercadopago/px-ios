//
//  MaskElementTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/23/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class MaskElementTest: BaseTest {

    var maskToTest = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX")

    override func setUp() {
        super.setUp()
        maskToTest = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleMask() {
       XCTAssertEqual(maskToTest.textMasked("2222"), "2222 •••• •••• ••••")
       XCTAssertEqual(maskToTest.textMasked("22222"), "2222 2••• •••• ••••")
       XCTAssertEqual(maskToTest.textMasked("11112222333344445"), "1111 2222 3333 4444")
        XCTAssertEqual(maskToTest.textUnmasked("1111 2222 3333 4444"), "1111222233334444")
       }

    func testMaskRight() {
        maskToTest.leftToRight = false
        XCTAssertEqual(maskToTest.textMasked("2222"), "•••• •••• •••• 2222")
        XCTAssertEqual(maskToTest.textMasked("22222"), "•••• •••• •••2 2222")
        XCTAssertEqual(maskToTest.textMasked("11112222333344445"), "1111 2222 3333 4444")
        XCTAssertEqual(maskToTest.textUnmasked("1111 2222 3333 4444"), "1111222233334444")
    }
    func testMaskLeft() {
        maskToTest.leftToRight = true

        XCTAssertEqual(maskToTest.textMasked("2222"), "2222 •••• •••• ••••")
        XCTAssertEqual(maskToTest.textMasked("22222"), "2222 2••• •••• ••••")
        XCTAssertEqual(maskToTest.textMasked("11112222333344445"), "1111 2222 3333 4444")
        XCTAssertEqual(maskToTest.textUnmasked("1111 2222 3333 4444"), "1111222233334444")
    }

    func changeCharacterSpaceMask(charStr: Character) {
        maskToTest.characterSpace = charStr

    }
    func changeEmptyMaskElement(charStr: Character) {
        maskToTest.emptyMaskElement = charStr
    }

    func completeEmptySpaces() {
        maskToTest.completeEmptySpaces = true
    }
    func noCompleteEmptySpaces() {
        maskToTest.completeEmptySpaces = false
    }

}
