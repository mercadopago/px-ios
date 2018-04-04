//
//  DiscountCouponTest.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 4/17/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class DiscountCouponTest: XCTestCase {

    let amount = 1000.0

    func testToJSON() {

        let discountCoupon = DiscountCoupon(discountId: 123)
        discountCoupon.name = "discount"
        discountCoupon.percent_off = "20"
        discountCoupon.amount_off = "200"
        discountCoupon.coupon_amount = "220"
        discountCoupon.currency_id = "ARS"
        discountCoupon.concept = "concept"

        let discountJson = discountCoupon.toJSON()

        XCTAssertNotNil(discountCoupon.toJSONString())

        XCTAssertEqual(discountJson["id"] as! UInt, 123)
        XCTAssertEqual(discountJson["name"] as! String, "discount")
        XCTAssertEqual(discountJson["percent_off"] as! Int, 20)
        XCTAssertEqual(discountJson["amount_off"] as! Int, 200)
        XCTAssertEqual(discountJson["coupon_amount"] as! Int, 220)
        XCTAssertEqual(discountJson["currency_id"] as! String, "ARS")
        XCTAssertEqual(discountJson["concept"] as! String, "concept")
    }

}
