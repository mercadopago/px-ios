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
}
