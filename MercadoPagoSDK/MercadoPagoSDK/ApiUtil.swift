//
//  ApiUtil.swift
//  MercadoPagoSDK
//
//  Created by Mauro Reverter on 6/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class ApiUtil {
    enum StatusCodes: Int {
        case INTERNAL_SERVER_ERROR = 500
        case PROCESSING = 499
        case BAD_REQUEST = 400
        case NOT_FOUND = 404
        case OK = 200
    }
    enum ErrorCauseCodes: String {
        case INVALID_IDENTIFICATION_NUMBER = "324"
        case INVALID_ESC = "E216"
        case INVALID_FINGERPRINT = "E217"
        case INVALID_PAYMENT_WITH_ESC = "2107"
        case INVALID_PAYMENT_IDENTIFICATION_NUMBER = "2067"
    }

    enum RequestOrigin: String {
        case GET_PREFERENCE
        case PAYMENT_METHOD_SEARCH
        case GET_INSTALLMENTS
        case GET_ISSUERS
        case GET_DIRECT_DISCOUNT
        case CREATE_PAYMENT
        case CREATE_TOKEN
        case GET_CUSTOMER
        case GET_CODE_DISCOUNT
        case GET_CAMPAIGNS
        case GET_PAYMENT_METHODS
        case GET_IDENTIFICATION_TYPES
        case GET_BANK_DEALS
        case GET_INSTRUCTIONS
    }
}

open class ApiParams: NSObject {
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
