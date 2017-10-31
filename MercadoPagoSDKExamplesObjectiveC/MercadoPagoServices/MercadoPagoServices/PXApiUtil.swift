//
//  PXApiUtil.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXApitUtil: NSObject {
    open static let INTERNAL_SERVER_ERROR = 500
    open static let PROCESSING = 499
    open static let BAD_REQUEST = 400
    open static let NOT_FOUND = 404
    open static let OK = 200

    open class var ERROR_KEY_CODE: Int {
        return -1
    }

    open class var ERROR_API_CODE: Int {
        return -2
    }

    open class var ERROR_UNKNOWN_CODE: Int {
        return -3
    }

    open class var ERROR_NOT_INSTALLMENTS_FOUND: Int {
        return -4
    }

    open class var ERROR_PAYMENT: Int {
        return -4
    }

    open class var ERROR_INSTRUCTIONS: Int {
        return -4
    }
}
internal class ApiParams: NSObject {
    static let PAYER_ACCESS_TOKEN = "access_token"
    static let PUBLIC_KEY = "public_key"
    static let BIN = "bin"
    static let AMOUNT = "amount"
    static let ISSUER_ID = "issuer.id"
    static let PAYMENT_METHOD_ID = "payment_method_id"
    static let PROCESSING_MODE = "processing_mode"
    static let PAYMENT_TYPE = "payment_type"
    static let API_VERSION = "api_version"
    static let SITE_ID = "site_id"
    static let CUSTOMER_ID = "customer_id"
    static let EMAIL = "email"
    static let DEFAULT_PAYMENT_METHOD = "default_payment_method"
    static let EXCLUDED_PAYMENT_METHOD = "excluded_payment_methods"
    static let EXCLUDED_PAYMET_TYPES = "excluded_payment_types"
}

