//
//  PXServicesURLConfigs.swift
//  MercadoPagoServices
//
//  Created by Eden Torres on 11/8/17.
//  Copyright © 2017 Mercado Pago. All rights reserved.
//

import Foundation

internal class PXServicesURLConfigs: NSObject {
    static var MP_ALPHA_ENV = "/alpha"
    static var MP_BETA_ENV = "/beta"
    static var MP_PROD_ENV = "/v1"
    static var MP_SELECTED_ENV = MP_PROD_ENV

    static let NEW_API_ALPHA_ENV = "/alpha"
    static let NEW_API_BETA_ENV = "/beta"
    static let NEW_API_PROD_ENV = "/production"
    static var NEW_API_SELECTED_ENV = NEW_API_PROD_ENV
    
    static var API_VERSION = "2.0"
    static let MP_API_BASE_URL_PROD: String =  "https://api.mercadopago.com"
    static let MP_API_BASE_URL: String = MP_API_BASE_URL_PROD

    static let MP_DEFAULT_PROCESSING_MODE = "aggregator"
    static let MP_DEFAULT_PROCESSING_MODES = [MP_DEFAULT_PROCESSING_MODE]

    static var MP_ENVIROMENT = MP_SELECTED_ENV  + "/checkout"
    static let MP_OP_ENVIROMENT = "/v1"
    static let PAYMENT_METHODS = "/payment_methods"
    static let CARD_ISSSUERS = "\(PAYMENT_METHODS)/card_issuers"
    static let PAYMENTS = "/payments"
    static let MP_CREATE_TOKEN_URI = MP_OP_ENVIROMENT + "/card_tokens"
    static var MP_ISSUERS_URI = MP_ENVIROMENT + CARD_ISSSUERS
    static let MP_IDENTIFICATION_URI = "/identification_types"
    static let MP_PROMOS_URI = MP_OP_ENVIROMENT + PAYMENT_METHODS + "/deals"
    static let MP_REMEDY_URI = NEW_API_SELECTED_ENV + "/px_mobile/v1/remedies/${payment_id}"
    static let MP_INSTRUCTIONS_URI = MP_ENVIROMENT + PAYMENTS + "/${payment_id}/results"
    static let MP_SUMMARY_AMOUNT_URI = "\(MP_SELECTED_ENV)/px_mobile_api/summary_amount"
    static let MP_PAYMENTS_URI = MP_SELECTED_ENV + "/px_mobile" + PAYMENTS
    static let MP_INIT_URI = NEW_API_SELECTED_ENV + "/px_mobile/v2/checkout"
    static let MP_RESET_ESC_CAP = NEW_API_SELECTED_ENV + "/px_mobile/v1/esc_cap"
    static let MP_POINTS_URI = MP_SELECTED_ENV + "/px_mobile" + "/congrats"
}
