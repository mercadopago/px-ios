//
//  CountdownTimerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/9/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import XCTest

class CountdownTimerTest: BaseTest /*, TimerDelegate*/ {
/*
     override func setUp() {
        super.setUp()
        CountdownTimer.getInstance().delegate = nil
        CountdownTimer.getInstance().timeoutCallback = nil
        CountdownTimer.getInstance().timer = nil
    }

    func testSetup() {
        let exp = expectation(description: "asdasd")
        CountdownTimer.getInstance().setup(seconds: 1, timeoutCallback: {(_) -> Void in
            exp.fulfill()
        })
        CountdownTimer.getInstance().delegate = self

        XCTAssertEqual("00 : 01", CountdownTimer.getInstance().getCurrentTiming())
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testHasTimer() {
        CountdownTimer.getInstance().delegate = self
        XCTAssertFalse(CountdownTimer.getInstance().hasTimer())

        let expectation = self.expectation(description: "timeout")
        CountdownTimer.getInstance().setup(seconds: 1, timeoutCallback: {(_) -> Void in
            expectation.fulfill()
        })

        CountdownTimer.getInstance().getCurrentTiming()

        XCTAssertTrue(CountdownTimer.getInstance().hasTimer())

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertFalse(CountdownTimer.getInstance().hasTimer())
    }

    func testStopTimer() {
        CountdownTimer.getInstance().setup(seconds: 5, timeoutCallback: {})
        CountdownTimer.getInstance().stopTimer()
    }

    func testStopTimerNoTimerSet() {
        CountdownTimer.getInstance().stopTimer()
    }

    func testCurrentTiming() {
        CountdownTimer.getInstance().setup(seconds: 45, timeoutCallback: {(_) -> Void in
            self.expectation(description: "timeout")
        })
        XCTAssertEqual("00 : 45", CountdownTimer.getInstance().getCurrentTiming())

        CountdownTimer.getInstance().setup(seconds: 60, timeoutCallback: {(_) -> Void in
            self.expectation(description: "timeout")
        })
        XCTAssertEqual("01 : 00", CountdownTimer.getInstance().getCurrentTiming())

        CountdownTimer.getInstance().setup(seconds: 270, timeoutCallback: {(_) -> Void in
            self.expectation(description: "timeout")
        })
        XCTAssertEqual("04 : 30", CountdownTimer.getInstance().getCurrentTiming())

        CountdownTimer.getInstance().setup(seconds: 600, timeoutCallback: {(_) -> Void in
            self.expectation(description: "timeout")
        })
        XCTAssertEqual("10 : 00", CountdownTimer.getInstance().getCurrentTiming())

        CountdownTimer.getInstance().setup(seconds: 3599, timeoutCallback: {(_) -> Void in
            self.expectation(description: "timeout")
        })
        XCTAssertEqual("59 : 59", CountdownTimer.getInstance().getCurrentTiming())

        CountdownTimer.getInstance().setup(seconds: 3600, timeoutCallback: {(_) -> Void in
            self.expectation(description: "timeout")
        })
        XCTAssertEqual("01 : 00 : 00", CountdownTimer.getInstance().getCurrentTiming())
    }

    func updateTimer() {

    }
 */
}
