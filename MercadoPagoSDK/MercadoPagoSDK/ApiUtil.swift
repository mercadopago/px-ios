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
    }
    enum ErrorCauseCodes: String {
        case INVALID_IDENTIFICATION_NUMBER = "324"
    }

    enum RequestOrigin: String {
        case GET_PREFERENCE = "GET_PREFERENCE"
        case PAYMENT_METHOD_SEARCH = "PAYMENT_METHOD_SEARCH"
        case GET_INSTALLMENTS = "GET_INSTALLMENTS"
        case GET_ISSUERS = "GET_ISSUERS"
        case GET_DIRECT_DISCOUNT = "GET_DIRECT_DISCOUNT"
        case CREATE_PAYMENT = "CREATE_PAYMENT"
        case CREATE_TOKEN = "CREATE_TOKEN"
        case GET_CUSTOMER = "GET_CUSTOMER"
        case GET_CODE_DISCOUNT = "GET_CODE_DISCOUNT"
        case GET_CAMPAINGS = "GET_CAMPAINGS"
        case GET_PAYMENT_METHODS = "GET_PAYMENT_METHODS"
        case GET_IDENTIFICATION_TYPES = "GET_IDENTIFICATION_TYPES"
        case GET_BANK_DEALS = "GET_BANK_DEALS"
        case GET_INSTRUCTIONS = "GET_INSTRUCTIONS"
    }

}
