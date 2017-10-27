//
//  MercadoPagoServices.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServices

open class MercadoPagoServices: NSObject {

    private var merchantPublicKey: String
    private var payerAccessToken: String
    private var procesingMode: String

    private var baseURL: String!
    private var gatewayBaseURL: String!
    private var getCustomerBaseURL: String! = MercadoPagoCheckoutViewModel.servicePreference.getCustomerURL() // TODO: Sacar!!
    private var createCheckoutPreferenceURL: String!
    private var getMerchantDiscountBaseURL: String!
    private var getCustomerURI: String! =  MercadoPagoCheckoutViewModel.servicePreference.getCustomerURI()

    private var createCheckoutPreferenceURI: String!
    private var getMerchantDiscountURI: String!

    private var getCustomerAdditionalInfo: NSDictionary!
    private var createCheckoutPreferenceAdditionalInfo: NSDictionary!
    private var getDiscountAdditionalInfo: NSDictionary!

    init(merchantPublicKey: String, payerAccessToken: String, procesingMode: String) {
        self.merchantPublicKey = merchantPublicKey
        self.payerAccessToken = payerAccessToken
        self.procesingMode = procesingMode
    }

    open func getCheckoutPreference(checkoutPreferenceId: String, callback : @escaping (PXCheckoutPreference) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let preferenceService = PreferenceService(baseURL: baseURL)
        preferenceService.getPreference(checkoutPreferenceId, success: { (preference : PXCheckoutPreference) in
            callback(preference)
        }, failure: failure)
    }

    open func getInstructions(paymentId: Int64, paymentTypeId: String, callback : @escaping (PXInstructions) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let instructionsService = InstructionsService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken)
        instructionsService.getInstructions(for: paymentId, paymentTypeId: paymentTypeId, success: { (instructionsInfo : PXInstructions) -> Void in
            callback(instructionsInfo)
        }, failure : failure)
    }

    open func getPaymentMethodSearch(amount: Double, excludedPaymentTypesIds: Set<String>?, excludedPaymentMethodsIds: Set<String>?, defaultPaymentMethod: String?, payer: PXPayer, site: PXSite, callback : @escaping (PXPaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let paymentMethodSearchService = PaymentMethodSearchService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken, processingMode: procesingMode)
        paymentMethodSearchService.getPaymentMethods(amount, defaultPaymenMethodId: defaultPaymentMethod, excludedPaymentTypeIds: excludedPaymentTypesIds, excludedPaymentMethodIds: excludedPaymentMethodsIds, success: callback, failure: failure)
    }

    open func createPayment(url: String, uri: String, transactionId: String? = nil, paymentData: NSDictionary, callback : @escaping (PXPayment) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: CustomService = CustomService(baseURL: url, URI: uri)
        var headers: [String: String]?
        if !String.isNullOrEmpty(transactionId), let transactionId = transactionId {
            headers = ["X-Idempotency-Key": transactionId]
        } else {
            headers = nil
        }
        
        service.createPayment(headers: headers, body: paymentData.toJsonString(), success: callback, failure: failure)
    }

    open func createToken(cardToken: CardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        cardToken.device = Device()
        createToken(cardTokenJSON: cardToken.toJSONString(), callback: callback, failure: failure)
    }

    open func createToken(savedESCCardToken: SavedESCCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        createToken(cardTokenJSON: savedESCCardToken.toJSONString(), callback: callback, failure: failure)
    }

    open func createToken(savedCardToken: SavedCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        createToken(cardTokenJSON: savedCardToken.toJSONString(), callback: callback, failure: failure)
    }
    
    internal func createToken(cardTokenJSON: String, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: GatewayService = GatewayService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken)
        service.getToken(cardTokenJSON: cardTokenJSON, success: {(data: Data) -> Void in

            let jsonResult = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)
            var token : PXToken
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = try! PXToken.fromJSON(data: data)
                    MPXTracker.trackToken(token: token.id)
                    callback(token)
                } else {
                    failure(NSError(domain: "mercadopago.sdk.createToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as! [AnyHashable: AnyObject]))
                }
            }
        }, failure: failure)
    }

    open func cloneToken(tokenId: String, securityCode: String, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: GatewayService = GatewayService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken)
        service.cloneToken(public_key: MercadoPagoContext.publicKey(), tokenId: tokenId, securityCode: securityCode, success: {(data: Data) -> Void in
            let jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)
            var token : PXToken
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = try! PXToken.fromJSON(data: data)
                    MPXTracker.trackToken(token: token.id)
                    callback(token)
                } else {
                    failure(NSError(domain: "mercadopago.sdk.createToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as! [AnyHashable: AnyObject]))
                }
            }
            } as! (Data?) -> Void, failure: failure)
    }

    open func getBankDeals(callback : @escaping ([PXBankDeal]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: PromosService = PromosService(baseURL: baseURL)
        service.getPromos(public_key: MercadoPagoContext.publicKey(), success: { (jsonResult) -> Void in
            var promos : [PXBankDeal] = [PXBankDeal]()
            if let data = jsonResult {
                promos = try! PXBankDeal.fromJSON(data: data)
            }
            callback(promos)
        }, failure: failure)
    }

    open func getIdentificationTypes(callback: @escaping ([PXIdentificationType]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: IdentificationService = IdentificationService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken)
        service.getIdentificationTypes(success: {(data: Data!) -> Void in
            let jsonResult = try! JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments)

            if let error = jsonResult as? NSDictionary {
                if (error["status"]! as? Int) == 404 {
                    failure(NSError(domain: "mercadopago.sdk.getIdentificationTypes", code: MercadoPago.ERROR_API_CODE, userInfo: error as! [AnyHashable: AnyObject]))
                }
            } else {
                var identificationTypes : [PXIdentificationType] = [PXIdentificationType]()
                identificationTypes = try! PXIdentificationType.fromJSON(data: data)
                callback(identificationTypes)
            }
        }, failure: failure)
    }

    open func getInstallments(bin: String?, amount: Double, issuerId: String?, paymentMethodId: String, callback: @escaping ([PXInstallment]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: PaymentService = PaymentService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken, processingMode: procesingMode)
        service.getInstallments(bin: bin, amount: amount, issuerId: issuerId, payment_method_id: paymentMethodId, success: callback, failure: failure)
    }

    open func getIssuers(paymentMethodId: String, bin: String? = nil, callback: @escaping ([PXIssuer]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: PaymentService = PaymentService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken, processingMode: procesingMode)
        service.getIssuers(payment_method_id: paymentMethodId, bin: bin, success: {(data: Data) -> Void in

            let jsonResponse = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)

            if let errorDic = jsonResponse as? NSDictionary {
                if errorDic["error"] != nil {
                    failure(NSError(domain: "mercadopago.sdk.getIssuers", code: MercadoPago.ERROR_API_CODE, userInfo: errorDic as! [AnyHashable: AnyObject]))
                }
            } else {
                var issuers : [PXIssuer] = [PXIssuer]()
                issuers =  try! PXIssuer.fromJSON(data: data)
                callback(issuers)
            }
        }, failure: failure)
    }

    open func getPaymentMethods(callback: @escaping ([PXPaymentMethod]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: PaymentService = PaymentService(baseURL: baseURL, merchantPublicKey: merchantPublicKey, payerAccessToken: payerAccessToken, processingMode: procesingMode)
        service.getPaymentMethods(success: {(data: Data) -> Void in

            let jsonResult = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)
            if let errorDic = jsonResult as? NSDictionary {
                if errorDic["error"] != nil {
                    failure(NSError(domain: "mercadopago.sdk.getPaymentMethods", code: MercadoPago.ERROR_API_CODE, userInfo: errorDic as! [AnyHashable: AnyObject]))
                }
            } else {
                var paymentMethods : [PXPaymentMethod] = [PXPaymentMethod]()
                paymentMethods = try! PXPaymentMethod.fromJSON(data: data)
                callback(paymentMethods)
            }
            }, failure: failure)
    }

    open func getDirectDiscount(amount: Double, payerEmail: String, discountAdditionalInfo: NSDictionary?, callback: @escaping (PXDiscount?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        getCodeDiscount(amount: amount, payerEmail: payerEmail, couponCode: nil, discountAdditionalInfo: discountAdditionalInfo, callback: callback, failure: failure)
    }
    
    open func getCodeDiscount(amount: Double, payerEmail: String, couponCode: String?, discountAdditionalInfo: NSDictionary?, callback: @escaping (PXDiscount?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        var addInfo: String? = nil
        if !NSDictionary.isNullOrEmpty(discountAdditionalInfo) {
            addInfo = discountAdditionalInfo?.parseToQuery()
        }
        let discountService = DiscountService(baseURL: getMerchantDiscountBaseURL, URI: getMerchantDiscountURI)
        
        discountService.getDiscount(amount: amount, code: couponCode, payerEmail: payerEmail, additionalInfo: addInfo, success: callback, failure: failure)
    }

    //    public func getCampaigns(callback: @escaping ([Campaign]) -> Void, failure: ((_ error: NSError) -> Void)) {
    //
    //    }

    // TODO: Sacar esto

    open func getCustomer(additionalInfo: NSDictionary? = MercadoPagoCheckoutViewModel.servicePreference.customerAdditionalInfo, callback: @escaping (PXCustomer) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: CustomService = CustomService(baseURL: getCustomerBaseURL, URI: getCustomerURI)
        
        var addInfo: String = ""
        if !NSDictionary.isNullOrEmpty(additionalInfo), let addInfoDict = additionalInfo {
            addInfo = addInfoDict.parseToQuery()
        }
        
        service.getCustomer(params: addInfo, success: callback, failure: failure)
    }

    open func createCheckoutPreference(bodyInfo: NSDictionary? = nil, callback: @escaping (PXCheckoutPreference) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: CustomService = CustomService(baseURL: createCheckoutPreferenceURL, URI: createCheckoutPreferenceURI)
        
        let body: String?
        if let bodyInfo = bodyInfo {
            body = bodyInfo.toJsonString()
        } else {
            body = nil
        }
        
        service.createPreference(body: body, success: callback, failure: failure)
    }

    //SETS
    open func setBaseURL(_ baseURL: String) {
        self.baseURL = baseURL
    }

    open func setGatewayBaseURL(_ gatewayBaseURL: String) {
        self.gatewayBaseURL = gatewayBaseURL
    }

    open func setGetCustomerBaseURL(_ getCustomerBaseURL: String) {
        self.getCustomerBaseURL = getCustomerBaseURL
    }

    open func setCreateCheckoutPreferenceURL(_ createCheckoutPreferenceURL: String) {
        self.createCheckoutPreferenceURL = createCheckoutPreferenceURL
    }

    open func setGetMerchantDiscountBaseURL(_ getMerchantDiscountBaseURL: String) {
        self.getMerchantDiscountBaseURL = getMerchantDiscountBaseURL
    }

    open func setGetCustomerURI(_ getCustomerURI: String) {
        self.getCustomerURI = getCustomerURI
    }

    open func setCreateCheckoutPreferenceURI(_ createCheckoutPreferenceURI: String) {
        self.createCheckoutPreferenceURI = createCheckoutPreferenceURI
    }

    open func setGetMerchantDiscountURI(_ getMerchantDiscountURI: String) {
        self.getMerchantDiscountURI = getMerchantDiscountURI
    }

    open func setGetCustomerAdditionalInfo(_ getCustomerAdditionalInfo: NSDictionary) {
        self.getCustomerAdditionalInfo = getCustomerAdditionalInfo
    }

    open func setCreateCheckoutPreferenceAdditionalInfo(_ createCheckoutPreferenceAdditionalInfo: NSDictionary) {
        self.createCheckoutPreferenceAdditionalInfo = createCheckoutPreferenceAdditionalInfo
    }

    open func setGetDiscountAdditionalInfo(_ getDiscountAdditionalInfo: NSDictionary) {
        self.getDiscountAdditionalInfo = getDiscountAdditionalInfo
    }
 
    internal class func getParamsPublicKey(_ merchantPublicKey: String) -> String {
        var params: String = ""

        params.paramsAppend(key: ApiParams.PUBLIC_KEY, value: merchantPublicKey)

        return params
    }

    internal class func getParamsPublicKeyAndAcessToken(_ merchantPublicKey: String, _ payerAccessToken: String?) -> String {
        var params: String = ""

        if String.isNullOrEmpty(payerAccessToken) {
            params.paramsAppend(key: ApiParams.PAYER_ACCESS_TOKEN, value: payerAccessToken!)
        }

        params.paramsAppend(key: ApiParams.PUBLIC_KEY, value: merchantPublicKey)

        return params
    }

}
