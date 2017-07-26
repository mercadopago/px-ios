//
//  ApiExceptionTest.swift
//  MercadoPagoSDK
//
//  Created by Mauro Reverter on 7/5/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class ApiExceptionTest: XCTestCase {

    func testFromJson() {
        let json: NSDictionary = MockManager.getMockFor("ApiException")!
        let apiExceptionFromJSON = ApiException.fromJSON(json)
        let apiException = MockBuilder.buildApiException(code: ApiUtil.ErrorCauseCodes.INVALID_IDENTIFICATION_NUMBER.rawValue)

        XCTAssertEqual(apiExceptionFromJSON.cause?[0].code, apiException?.cause?[0].code)
        XCTAssertEqual(apiExceptionFromJSON.error, apiException?.error)
        XCTAssertEqual(apiExceptionFromJSON.message, apiException?.message)
        XCTAssertEqual(apiExceptionFromJSON.status, apiException?.status)
    }

    func testWhenCauseContainsCodeThenContainsCauseShouldReturnTrue() {
        let apiException = MockBuilder.buildApiException(code: ApiUtil.ErrorCauseCodes.INVALID_IDENTIFICATION_NUMBER.rawValue)
        XCTAssertTrue((apiException?.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_IDENTIFICATION_NUMBER.rawValue))!)
    }

    func testWhenCauseDoesNotContainCodeThenContainsCauseShouldReturnFalse() {
        let apiException = MockBuilder.buildApiException(code: ApiUtil.ErrorCauseCodes.INVALID_IDENTIFICATION_NUMBER.rawValue)
        XCTAssertFalse((apiException?.containsCause(code: "132312"))!)
    }

    func testWhenApiExceptionCauseIsNilThenContainsCauseShouldReturnFalse() {
        let apiException = MockBuilder.buildApiException(code: ApiUtil.ErrorCauseCodes.INVALID_IDENTIFICATION_NUMBER.rawValue)

        //Remove cause
        apiException?.cause = nil

        XCTAssertFalse((apiException?.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_IDENTIFICATION_NUMBER.rawValue))!)
    }
}
