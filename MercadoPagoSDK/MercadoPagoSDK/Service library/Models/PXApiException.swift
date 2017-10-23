//
//  PXApiException.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXApiException: NSObject {

    open static let CUSTOMER_NOT_ALLOWED_TO_OPERATE = "2021"
    open static let COLLECTOR_NOT_ALLOWED_TO_OPERATE = "2022"
    open static let INVALID_USERS_INVOLVED = "2035"
    open static let CUSTOMER_EQUAL_TO_COLLECTOR = "3000"
    open static let INVALID_CARD_HOLDER_NAME = "3001"
    open static let UNAUTHORIZED_CLIENT = "3010"
    open static let PAYMENT_METHOD_NOT_FOUND = "3012"
    open static let INVALID_SECURITY_CODE = "3013"
    open static let SECURITY_CODE_REQUIRED = "3014"
    open static let INVALID_PAYMENT_METHOD = "3015"
    open static let INVALID_CARD_NUMBER = "3017"
    open static let EMPTY_EXPIRATION_MONTH = "3019"
    open static let EMPTY_EXPIRATION_YEAR = "3020"
    open static let EMPTY_CARD_HOLDER_NAME = "3021"
    open static let EMPTY_DOCUMENT_NUMBER = "3022"
    open static let EMPTY_DOCUMENT_TYPE = "3023"
    open static let INVALID_PAYMENT_TYPE_ID = "3028"
    open static let INVALID_PAYMENT_METHOD_ID = "3029"
    open static let INVALID_CARD_EXPIRATION_MONTH = "3030"
    open static let INVALID_CARD_EXPIRATION_YEAR = "4000"
    open static let INVALID_PAYER_EMAIL = "4050"
    open static let INVALID_PAYMENT_WITH_ESC = "2107"
    open static let INVALID_IDENTIFICATION_NUMBER = "2067"
    open static let INVALID_CARD_HOLDER_IDENTIFICATION_NUMBER = "324"
    open static let INVALID_ESC = "E216"
    open static let INVALID_FINGERPRINT = "E217"

    open var cause: [PXCause]!
    open var error: String!
    open var message: String!
    open var status: Int!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXApiException {
        return PXApiException()
    }
}
