//
//  ApiDomain.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 23/09/2019.
//

import Foundation

internal struct ApiDomain {
    internal static let BASE_DOMAIN = "mercadopago.sdk."
    static let CREATE_PAYMENT = "\(BASE_DOMAIN)CustomService.createPayment"
    static let GET_TOKEN = "\(BASE_DOMAIN)GatewayService.getToken"
    static let CLONE_TOKEN = "\(BASE_DOMAIN)GatewayService.cloneToken"
    static let GET_INSTRUCTIONS = "\(BASE_DOMAIN)InstructionsService.getInstructions"
    static let GET_PAYMENT_METHODS = "\(BASE_DOMAIN)PaymentMethodSearchService.getPaymentMethods"
    static let GET_PROMOS = "\(BASE_DOMAIN)PromosService.getPromos"
    static let GET_REMEDY = "\(BASE_DOMAIN)RemedyService.getRemedy"
    static let RESET_ESC_CAP = "\(BASE_DOMAIN)ESCService.resetCap"
}
