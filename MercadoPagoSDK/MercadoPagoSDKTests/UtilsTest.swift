//
//  UtilTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 23/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class UtilsTest: BaseTest {

    let TEN = "10.00"
    let HUNDRED = "100.00"
    let THOUSAND = "1000.00"
    let TEN_THOUSAND = "10000.00"
    let MILLON = "1000000.00"
    let OVER_MILLON = "10000000000.00"
    let MILLIONS = "10000000000000000.00"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
  /*  func testGetAmountFormatted() {
        var amountFormatted = Utils.getAmountFormatted(TEN, thousandSeparator: ",", decimalSeparator: ".")
        XCTAssertEqual(amountFormatted, "10")

        amountFormatted = Utils.getAmountFormatted(HUNDRED, thousandSeparator: ",", decimalSeparator: ".")
        XCTAssertEqual(amountFormatted, "100")

        amountFormatted = Utils.getAmountFormatted(THOUSAND, thousandSeparator: ",", decimalSeparator: ".")
        XCTAssertEqual(amountFormatted, "1,000")

        amountFormatted = Utils.getAmountFormatted(TEN_THOUSAND, thousandSeparator: ",", decimalSeparator: ".")
        XCTAssertEqual(amountFormatted, "10,000")

        amountFormatted = Utils.getAmountFormatted(MILLON, thousandSeparator: ",", decimalSeparator: ".")
        XCTAssertEqual(amountFormatted, "1,000,000")

        amountFormatted = Utils.getAmountFormatted(OVER_MILLON, thousandSeparator: ",", decimalSeparator: ".")
        XCTAssertEqual(amountFormatted, "10,000,000,000")

        amountFormatted = Utils.getAmountFormatted(MILLIONS, thousandSeparator: ",", decimalSeparator: ".")
        XCTAssertEqual(amountFormatted, "10,000,000,000,000,000")
    }*/
    
    
}
