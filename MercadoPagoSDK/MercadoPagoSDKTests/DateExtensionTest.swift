//
//  DateExtensionTest.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 8/31/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class DateExtensionTest: BaseTest {

    func test_getCurrtenMillis() {
        let date = Date()

        let timeInSeconds = date.timeIntervalSince1970
        let timeInMiliSeconds = date.getCurrentMillis()

        XCTAssertEqual(Int64(timeInSeconds * 1000), timeInMiliSeconds)
    }

    func test_fromMillis() {
        let date = Date()

        let timeInMiliSeconds = date.getCurrentMillis()

        let dateFromSeconds = Date(timeIntervalSince1970: Double(timeInMiliSeconds) / 1000)
        let dateFromMiliSeconds = Date.from(millis: timeInMiliSeconds)

        XCTAssertEqual(dateFromSeconds.timeIntervalSince1970, dateFromMiliSeconds.timeIntervalSince1970)
    }
}
