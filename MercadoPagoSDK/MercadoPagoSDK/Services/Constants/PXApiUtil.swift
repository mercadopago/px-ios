//
//  PXApiUtil.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
internal class PXApitUtil: NSObject {
    static let INTERNAL_SERVER_ERROR = 500
    static let PROCESSING = 499
    static let BAD_REQUEST = 400
    static let NOT_FOUND = 404
    static let OK = 200
}

internal class ApiParams: NSObject {
    static let PAYER_ACCESS_TOKEN = "access_token"
    static let PUBLIC_KEY = "public_key"
    static let BIN = "bin"
    static let AMOUNT = "amount"
    static let TRANSACTION_AMOUNT = "transaction_amount"
    static let ISSUER_ID = "issuer.id"
    static let PAYMENT_METHOD_ID = "payment_method_id"
    static let PROCESSING_MODES = "processing_modes"
    static let PAYMENT_TYPE = "payment_type"
    static let API_VERSION = "api_version"
    static let SITE_ID = "site_id"
    static let CUSTOMER_ID = "customer_id"
    static let EMAIL = "email"
    static let DEFAULT_PAYMENT_METHOD = "default_payment_method"
    static let EXCLUDED_PAYMENT_METHOD = "excluded_payment_methods"
    static let EXCLUDED_PAYMET_TYPES = "excluded_payment_types"
    static let DIFFERENTIAL_PRICING_ID = "differential_pricing_id"
    static let DEFAULT_INSTALLMENTS = "default_installments"
    static let MAX_INSTALLMENTS = "max_installments"
    static let MARKETPLACE = "marketplace"
    static let PRODUCT_ID = "product_id"
    static let LABELS = "labels"
    static let CHARGES = "charges"
}

internal struct ApiDomains {
    static let GET_CUSTOMER = "mercadopago.sdk.CustomService.getCustomer"
    static let CREATE_PAYMENT = "mercadopago.sdk.CustomService.createPayment"
    static let CREATE_PREFERENCE = "mercadopago.sdk.CustomService.createCheckoutPreference"
    static let GET_DISCOUNT = "mercadopago.sdk.DiscountService.getDiscount"
    static let GET_CAMPAIGNS = "mercadopago.sdk.DiscountService.getCampaigns"
    static let GET_TOKEN = "mercadopago.sdk.GatewayService.getToken"
    static let CLONE_TOKEN = "mercadopago.sdk.GatewayService.cloneToken"
    static let GET_IDENTIFICATION_TYPES = "mercadopago.sdk.IdentificationService.getIdentificationTypes"
    static let GET_INSTRUCTIONS = "mercadopago.sdk.InstructionsService.getInstructions"
    static let GET_PAYMENT_METHODS = "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods"
    static let GET_SUMMARY_AMOUNT = "mercadopago.sdk.PaymentService.getSummaryAmount"
    static let GET_ISSUERS = "mercadopago.sdk.PaymentService.getIssuers"
    static let GET_PREFERENCE = "mercadopago.sdk.PreferenceService.getPreference"
    static let GET_PROMOS = "mercadopago.sdk.PromosService.getPromos"
}
