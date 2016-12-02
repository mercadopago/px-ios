//
//  FeedDetailTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class FeedDetailTest: BaseTest {
    

    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("FeesDetail")!
        let feesDetailFromJSON = FeesDetail.fromJSON(json)
        XCTAssertEqual(feesDetailFromJSON, feesDetailFromJSON)
    }
}
