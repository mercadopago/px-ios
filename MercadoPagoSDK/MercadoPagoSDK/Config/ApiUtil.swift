//
//  ApiUtil.swift
//  MercadoPagoSDK
//
//  Created by Mauro Reverter on 6/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

internal class ApiUtil {
    enum ErrorCauseCodes: String {
        case INVALID_IDENTIFICATION_NUMBER = "324"
        case INVALID_ESC = "E216"
        case INVALID_FINGERPRINT = "E217"
        case INVALID_PAYMENT_WITH_ESC = "2107"
        case INVALID_PAYMENT_IDENTIFICATION_NUMBER = "2067"
    }

    enum RequestOrigin: String {
        case GET_INIT
        case CREATE_PAYMENT
        case CREATE_TOKEN
        case GET_INSTRUCTIONS
    }
}
