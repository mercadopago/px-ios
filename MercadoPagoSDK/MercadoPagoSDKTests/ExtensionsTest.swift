//
//  ExtensionsTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/5/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import XCTest

class ExtensionsTest: BaseTest {

    func testParseToLiteral() {
        let params: NSDictionary = ["key1": "value1", "key2": "value2", "key3": "value3"]

        let result = params.parseToLiteral()

        XCTAssertEqual(3, result.count)
        XCTAssertNotNil(result["key1"])
        XCTAssertNotNil(result["key2"])
        XCTAssertNotNil(result["key3"])
        XCTAssertEqual("value1", result["key1"] as! String)
        XCTAssertEqual("value2", result["key2"] as! String)
        XCTAssertEqual("value3", result["key3"] as! String)
    }
    func testToJsonString() {
        var dict = NSDictionary(dictionary: ["hola": "hola"])
        XCTAssertEqual(dict.toJsonString(), "{\n  \"hola\" : \"hola\"\n}" )

        dict = ["2": "B", "1": "A", "3": "C"]
        XCTAssertEqual(dict.toJsonString(), "{\n  \"2\" : \"B\",\n  \"1\" : \"A\",\n  \"3\" : \"C\"\n}")

        dict = ["2": [2], "1": 4, "3": "C"]
        XCTAssertEqual(dict.toJsonString(), "{\n  \"2\" : [\n    2\n  ],\n  \"1\" : 4,\n  \"3\" : \"C\"\n}")

        dict = [:]
        XCTAssertEqual(dict.toJsonString(), "{\n\n}")

        dict = NSDictionary()
        XCTAssertEqual(dict.toJsonString(), "{\n\n}")

    }
    func testParseToQuery() {
        var dict = NSDictionary(dictionary: ["hola": "hola"])
        XCTAssertEqual(dict.parseToQuery(), "hola=hola")
        dict = ["2": "B", "1": "A"]
        let query = dict.parseToQuery()
        XCTAssert(query == "2=B&1=A" || query == "1=A&2=B")

        dict = ["2 sarasa": "B"]
        XCTAssertEqual(dict.parseToQuery(), "2%20sarasa=B")
        dict = [:]
        XCTAssertEqual(dict.parseToQuery(), "")
    }
}
