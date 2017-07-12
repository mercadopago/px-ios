//
//  ArrayExtensionsTest.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 6/29/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class ArrayExtensionsTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSafeRemoveLast() {

        //Test delete less components than the array contains
        var suffix = 3
        var testArray: Array = ["a", "b", "c", "d", "e"]
        let firstArray = testArray
        testArray.safeRemoveLast(suffix)
        let resultArray = testArray

        XCTAssertEqual(resultArray.count, firstArray.count-suffix)
        XCTAssertEqual(resultArray, ["a", "b"])

        //Test delete more components than the array contains
        suffix = 6
        var testArray2: Array = ["a", "b", "c", "d", "e"]
        testArray2.safeRemoveLast(suffix)
        let resultArray2 = testArray2

        XCTAssertEqual(resultArray2.count, 0)
        XCTAssertEqual(resultArray2, [])

        //Test delete same amount of components than the array contains
        suffix = 5
        var testArray3: Array = ["a", "b", "c", "d", "e"]
        testArray3.safeRemoveLast(suffix)
        let resultArray3 = testArray3

        XCTAssertEqual(resultArray3.count, firstArray.count-suffix)
        XCTAssertEqual(resultArray3, [])
    }

    func testSafeRemoveFirst() {
        //Test delete less components than the array contains
        var suffix = 3
        var testArray: Array = ["a", "b", "c", "d", "e"]
        let firstArray = testArray
        testArray.safeRemoveFirst(suffix)
        let resultArray = testArray

        XCTAssertEqual(resultArray.count, firstArray.count-suffix)
        XCTAssertEqual(resultArray, ["d", "e"])

        //Test delete more components than the array contains
        suffix = 6
        var testArray2: Array = ["a", "b", "c", "d", "e"]
        testArray2.safeRemoveFirst(suffix)
        let resultArray2 = testArray2

        XCTAssertEqual(resultArray2.count, 0)
        XCTAssertEqual(resultArray2, [])

        //Test delete same amount of components than the array contains
        suffix = 5
        var testArray3: Array = ["a", "b", "c", "d", "e"]
        testArray3.safeRemoveFirst(suffix)
        let resultArray3 = testArray3

        XCTAssertEqual(resultArray3.count, firstArray.count-suffix)
        XCTAssertEqual(resultArray3, [])
    }

}
