//
//  MercadoPagoServices.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation

internal class MercadoPagoServices: NSObject {

    open var merchantPublicKey: String
    open var payerAccessToken: String
    open var procesingMode: String

    private var baseURL: String! = PXServicesURLConfigs.MP_API_BASE_URL
    private var gatewayBaseURL: String!

    private var language: String = NSLocale.preferredLanguages[0]

    init(merchantPublicKey: String, payerAccessToken: String = "", procesingMode: String = "aggregator") {
        self.merchantPublicKey = merchantPublicKey
        self.payerAccessToken = payerAccessToken
        self.procesingMode = procesingMode
        super.init()
        initMercadPagoPXTracking()
    }

    func initMercadPagoPXTracking() {
        MPXTracker.sharedInstance.setPublicKey(merchantPublicKey)
    }

    func getCheckoutPreference(checkoutPreferenceId: String, callback : @escaping (PXCheckoutPreference) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let preferenceService = PreferenceService(baseURL: baseURL)
        preferenceService.getPreference(publicKey: merchantPublicKey, preferenceId: checkoutPreferenceId, success: { (preference : PXCheckoutPreference) in
            callback(preference)
        }, failure: failure)
    }

    func getInstructions(paymentId: Int64, paymentTypeId: String, callback : @escaping (PXInstructions) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let instructionsService = InstructionsService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken)
        instructionsService.getInstructions(for: paymentId, paymentTypeId: paymentTypeId, language: language, success: { (instructionsInfo : PXInstructions) -> Void in
            callback(instructionsInfo)
        }, failure: failure)
    }

    func getPaymentMethodSearch(amount: Double, excludedPaymentTypesIds: [String], excludedPaymentMethodsIds: [String], cardsWithEsc: [String]?, supportedPlugins: [String]?, defaultPaymentMethod: String?, payer: PXPayer, site: PXSite, differentialPricingId: String?, defaultInstallments: String?, callback : @escaping (PXPaymentMethodSearch) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let paymentMethodSearchService = PaymentMethodSearchService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken, processingMode: procesingMode)
        paymentMethodSearchService.getPaymentMethods(amount, defaultPaymenMethodId: defaultPaymentMethod, excludedPaymentTypeIds: excludedPaymentTypesIds, excludedPaymentMethodIds: excludedPaymentMethodsIds, cardsWithEsc: cardsWithEsc, supportedPlugins: supportedPlugins, site: site, payer: payer, language: language, differentialPricingId: differentialPricingId, defaultInstallments: defaultInstallments, success: callback, failure: failure)
    }

    func createPayment(url: String, uri: String, transactionId: String? = nil, paymentDataJSON: Data, query: [String: String]? = nil, callback : @escaping (PXPayment) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let service: CustomService = CustomService(baseURL: url, URI: uri)
        var headers: [String: String]?
        if !String.isNullOrEmpty(transactionId), let transactionId = transactionId {
            headers = ["X-Idempotency-Key": transactionId]
        } else {
            headers = nil
        }
        var params = ""
        if let queryParams = query as NSDictionary? {
            params = queryParams.parseToQuery()
        }

        service.createPayment(headers: headers, body: paymentDataJSON, params: params, success: callback, failure: failure)
    }

    func createToken(cardToken: PXCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        createToken(cardToken: try? cardToken.toJSON(), callback: callback, failure: failure)
    }

    func createToken(savedESCCardToken: PXSavedESCCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        createToken(cardToken: try? savedESCCardToken.toJSON(), callback: callback, failure: failure)
    }

    func createToken(savedCardToken: PXSavedCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        createToken(cardToken: try? savedCardToken.toJSON(), callback: callback, failure: failure)
    }

    func createToken(cardToken: Data?, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let service: GatewayService = GatewayService(baseURL: getGatewayURL(), merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken)
        guard let cardToken = cardToken else {
            return
        }
        service.getToken(cardTokenJSON: cardToken, success: {(data: Data) -> Void in
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                var token : PXToken
                if let tokenDic = jsonResult as? NSDictionary {
                    if tokenDic["error"] == nil {
                        token = try PXToken.fromJSON(data: data)
                        MPXTracker.trackToken(token: token.id)
                        callback(token)
                    } else {
                        let apiException = try PXApiException.fromJSON(data: data)
                        failure(PXError(domain: "mercadopago.sdk.createToken", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: tokenDic as? [String: Any], apiException: apiException))
                    }
                }
            } catch {
                failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido crear el token"]))
            }
        }, failure: failure)
    }

    func cloneToken(tokenId: String, securityCode: String, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: GatewayService = GatewayService(baseURL: getGatewayURL(), merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken)
        service.cloneToken(public_key: merchantPublicKey, tokenId: tokenId, securityCode: securityCode, success: {(data: Data) -> Void in
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                var token : PXToken
                if let tokenDic = jsonResult as? NSDictionary {
                    if tokenDic["error"] == nil {
                        token = try PXToken.fromJSON(data: data)
                        MPXTracker.trackToken(token: token.id)
                        callback(token)
                    } else {
                        let apiException = try PXApiException.fromJSON(data: data)
                        failure(PXError(domain: "mercadopago.sdk.createToken", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: tokenDic as? [String: Any], apiException: apiException))
                    }
                }
            } catch {
                failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido clonar el token"]))
            }
        }, failure: failure)
    }

    func getBankDeals(callback : @escaping ([PXBankDeal]) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let service: PromosService = PromosService(baseURL: baseURL)
        service.getPromos(public_key: merchantPublicKey, success: { (jsonResult) -> Void in
            do {
                var promos : [PXBankDeal] = [PXBankDeal]()
                if let data = jsonResult {
                    promos = try PXBankDeal.fromJSON(data: data)
                }
                callback(promos)
            } catch {
                failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener las promociones"]))
            }
        }, failure: failure)
    }

    func getIdentificationTypes(callback: @escaping ([PXIdentificationType]) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let service: IdentificationService = IdentificationService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken)
        service.getIdentificationTypes(success: {(data: Data!) -> Void in do {
            let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)

            if let error = jsonResult as? NSDictionary {
                if (error["status"]! as? Int) == 404 {
                    let apiException = try PXApiException.fromJSON(data: data)
                    failure(PXError(domain: "mercadopago.sdk.getIdentificationTypes", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: error as? [String: Any], apiException: apiException))
                } else if error["error"] != nil {
                    let apiException = try PXApiException.fromJSON(data: data)
                    failure(PXError(domain: "mercadopago.sdk.getIdentificationTypes", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: error as? [String: Any], apiException: apiException))
                }
            } else {
                var identificationTypes : [PXIdentificationType] = [PXIdentificationType]()
                identificationTypes = try PXIdentificationType.fromJSON(data: data)
                callback(identificationTypes)
            }
        } catch {
            failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los tipos de identificación"]))
            }
        }, failure: failure)
    }

    func getInstallments(bin: String?, amount: Double, issuerId: String?, paymentMethodId: String, differentialPricingId: String?, callback: @escaping ([PXInstallment]) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let service: PaymentService = PaymentService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken, processingMode: procesingMode)
        service.getInstallments(bin: bin, amount: amount, issuerId: issuerId, payment_method_id: paymentMethodId, differential_pricing_id: differentialPricingId, success: callback, failure: failure)
    }

    func getIssuers(paymentMethodId: String, bin: String? = nil, callback: @escaping ([PXIssuer]) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let service: PaymentService = PaymentService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken, processingMode: procesingMode)
        service.getIssuers(payment_method_id: paymentMethodId, bin: bin, success: {(data: Data) -> Void in
            do {

                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)

                if let errorDic = jsonResponse as? NSDictionary {
                    if errorDic["error"] != nil {
                        let apiException = try PXApiException.fromJSON(data: data)
                        failure(PXError(domain: "mercadopago.sdk.getIssuers", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: errorDic as? [String: Any], apiException: apiException))
                    }
                } else {
                    var issuers : [PXIssuer] = [PXIssuer]()
                    issuers =  try PXIssuer.fromJSON(data: data)
                    callback(issuers)
                }
            } catch {
                failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los bancos"]))
            }
        }, failure: failure)
    }

    func getPaymentMethods(callback: @escaping ([PXPaymentMethod]) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let service: PaymentService = PaymentService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken, processingMode: procesingMode)
        service.getPaymentMethods(success: {(data: Data) -> Void in
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                if let errorDic = jsonResult as? NSDictionary {
                    if errorDic["error"] != nil {
                        let apiException = try PXApiException.fromJSON(data: data)
                        failure(PXError(domain: "mercadopago.sdk.getPaymentMethods", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: errorDic as? [String: Any], apiException: apiException))
                    }
                } else {
                    var paymentMethods : [PXPaymentMethod] = [PXPaymentMethod]()
                    paymentMethods = try PXPaymentMethod.fromJSON(data: data)
                    callback(paymentMethods)
                }} catch {
                    failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"]))
            }
        }, failure: failure)
    }

    func getDirectDiscount(url: String = PXServicesURLConfigs.MP_API_BASE_URL, uri: String = PXServicesURLConfigs.MP_DISCOUNT_URI, amount: Double, payerEmail: String, discountAdditionalInfo: [String: String]?, callback: @escaping (PXDiscount?) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        getCodeDiscount(url: url, uri: uri, amount: amount, payerEmail: payerEmail, couponCode: nil, discountAdditionalInfo: discountAdditionalInfo, callback: callback, failure: failure)
    }

    func getCodeDiscount(url: String = PXServicesURLConfigs.MP_API_BASE_URL, uri: String = PXServicesURLConfigs.MP_DISCOUNT_URI, amount: Double, payerEmail: String, couponCode: String?, discountAdditionalInfo: [String: String]?, callback: @escaping (PXDiscount?) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        var addInfo: String? = nil
        if let discountAdditionalInfo = discountAdditionalInfo {
            let discountAdditionalInfoDic = discountAdditionalInfo as NSDictionary
            if !NSDictionary.isNullOrEmpty(discountAdditionalInfoDic) {
                addInfo = discountAdditionalInfoDic.parseToQuery()
            }
        }
        var discountUrl = url
        if discountUrl == PXServicesURLConfigs.MP_API_BASE_URL, baseURL != PXServicesURLConfigs.MP_API_BASE_URL {
            discountUrl = baseURL
        }
        let discountService = DiscountService(baseURL: discountUrl, URI: uri)

        discountService.getDiscount(publicKey: merchantPublicKey, amount: amount, code: couponCode, payerEmail: payerEmail, additionalInfo: addInfo, success: callback, failure: failure)
    }

    func getCampaigns(payerEmail: String?, callback: @escaping ([PXCampaign]) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let discountService = DiscountService(baseURL: baseURL, URI: PXServicesURLConfigs.MP_CAMPAIGNS_URI)
        discountService.getCampaigns(publicKey: merchantPublicKey, payerEmail: payerEmail, success: callback, failure: failure)
    }

    func getCustomer(url: String, uri: String, additionalInfo: [String: String]? = nil, callback: @escaping (PXCustomer) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let service: CustomService = CustomService(baseURL: url, URI: uri)

        var addInfo: String = ""
        if let additionalInfo = additionalInfo {
            let additionalInfoDic = additionalInfo as NSDictionary
            if !NSDictionary.isNullOrEmpty(additionalInfoDic) {
                addInfo = additionalInfoDic.parseToQuery()
            }
        }
        service.getCustomer(params: addInfo, success: callback, failure: failure)
    }

    func createCheckoutPreference(url: String, uri: String, bodyInfo: NSDictionary? = nil, callback: @escaping (PXCheckoutPreference) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let service: CustomService = CustomService(baseURL: url, URI: uri)

        let body: Data?
        if let bodyInfo = bodyInfo {
            body = NSKeyedArchiver.archivedData(withRootObject: bodyInfo)
        } else {
            body = nil
        }

        service.createPreference(body: body, success: callback, failure: failure)
    }

    //SETS
    func setBaseURL(_ baseURL: String) {
        self.baseURL = baseURL
    }

    func setGatewayBaseURL(_ gatewayBaseURL: String) {
        self.gatewayBaseURL = gatewayBaseURL
    }

    func getGatewayURL() -> String {
        if !String.isNullOrEmpty(gatewayBaseURL) {
            return gatewayBaseURL
        }
        return baseURL
    }

    class func getParamsPublicKey(_ merchantPublicKey: String) -> String {
        var params: String = ""
        params.paramsAppend(key: ApiParams.PUBLIC_KEY, value: merchantPublicKey)
        return params
    }

    class func getParamsPublicKeyAndAcessToken(_ merchantPublicKey: String, _ payerAccessToken: String?) -> String {
        var params: String = ""

        if !String.isNullOrEmpty(payerAccessToken) {
            params.paramsAppend(key: ApiParams.PAYER_ACCESS_TOKEN, value: payerAccessToken!)
        }
        params.paramsAppend(key: ApiParams.PUBLIC_KEY, value: merchantPublicKey)

        return params
    }

    func setLanguage(language: String) {
        self.language = language
    }
}
