//
//  URLConfigs.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 11/8/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class URLConfigs: NSObject {
    static let MP_ALPHA_ENV = "/gamma"
    static var MP_TEST_ENV = "/beta"
    static var MP_PROD_ENV = "/v1"
    static var MP_SELECTED_ENV = MP_PROD_ENV

    static var API_VERSION = "1.5"

    static var MP_ENVIROMENT = MP_SELECTED_ENV  + "/checkout"

    static let MP_OP_ENVIROMENT = "/v1"

    static let MP_ALPHA_API_BASE_URL: String =  "http://api.mp.internal.ml.com"
    static let MP_API_BASE_URL_PROD: String =  "https://api.mercadopago.com"

    static let MP_API_BASE_URL: String =  MP_API_BASE_URL_PROD

    static let PAYMENTS = "/payments"

    static let MP_DISCOUNT_URI =  "/discount_campaigns/"
    static let MP_PAYMENTS_URI = MP_ENVIROMENT + PAYMENTS
}
