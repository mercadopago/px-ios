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
    private var proccesingMode: String

    private static var baseURL: String!
    private static var gatewayBaseURL: String!
    private static var getCustomerBaseURL: String! = MercadoPagoCheckoutViewModel.servicePreference.getCustomerURL() // TODO: Sacar!!
    private static var createCheckoutPreferenceURL: String!
    private static var getMerchantDiscountBaseURL: String!
    private static var getCustomerURI: String! =  MercadoPagoCheckoutViewModel.servicePreference.getCustomerURI()

    private static var createCheckoutPreferenceURI: String!
    private static var getMerchantDiscountURI: String!

    private static var getCustomerAdditionalInfo: NSDictionary!
    private static var createCheckoutPreferenceAdditionalInfo: NSDictionary!
    private static var getDiscountAdditionalInfo: NSDictionary!

    init(merchantPublicKey: String, payerAccessToken: String, proccesingMode: String) {
        self.merchantPublicKey = merchantPublicKey
        self.payerAccessToken = payerAccessToken
        self.proccesingMode = proccesingMode
    }

    open class func getCheckoutPreference(checkoutPreferenceId: String, callback : @escaping (PXCheckoutPreference) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let preferenceService = PreferenceService(baseURL: baseURL)
        preferenceService.getPreference(checkoutPreferenceId, success: { (preference : PXCheckoutPreference) in
            callback(preference)
        }, failure: failure)
    }

    open class func getInstructions(paymentId: Int64, paymentTypeId: String, callback : @escaping (InstructionsInfo) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let instructionsService = InstructionsService(baseURL: baseURL)
        instructionsService.getInstructions(for: paymentId, paymentTypeId: paymentTypeId, success: { (instructionsInfo : InstructionsInfo) -> Void in
            callback(instructionsInfo)
        }, failure : failure)
    }

    open class func getPaymentMethodSearch(amount: Double, excludedPaymentTypesIds: Set<String>?, excludedPaymentMethodsIds: Set<String>?, defaultPaymentMethod: String?, payer: PXPayer, site: PXSite, callback : @escaping (PXPaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let paymentMethodSearchService = PaymentMethodSearchService(baseURL: baseURL)
        paymentMethodSearchService.getPaymentMethods(amount, defaultPaymenMethodId: defaultPaymentMethod, excludedPaymentTypeIds: excludedPaymentTypesIds, excludedPaymentMethodIds: excludedPaymentMethodsIds, success: callback, failure: failure)
    }

    open class func createPayment(url: String, uri: String, transactionId: String? = nil, paymentData: NSDictionary, callback : @escaping (PXPayment) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: CustomService = CustomService(baseURL: url, URI: uri)
        var headers: [String: String]?
        if !String.isNullOrEmpty(transactionId), let transactionId = transactionId {
            headers = ["X-Idempotency-Key": transactionId]
        } else {
            headers = nil
        }
        
        service.createPayment(headers: headers, body: paymentData.toJsonString(), success: callback, failure: failure)
    }

    open class func createToken(cardToken: CardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        cardToken.device = Device()
        createToken(cardTokenJSON: cardToken.toJSONString(), callback: callback, failure: failure)
    }

    open class func createToken(savedESCCardToken: SavedESCCardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        createToken(cardTokenJSON: savedESCCardToken.toJSONString(), callback: callback, failure: failure)
    }

    open class func createToken(savedCardToken: SavedCardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        createToken(cardTokenJSON: savedCardToken.toJSONString(), callback: callback, failure: failure)
    }
    
    internal class func createToken(cardTokenJSON: String, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: GatewayService = GatewayService(baseURL: baseURL)
        service.getToken(cardTokenJSON: cardTokenJSON, success: {(data: Data?) -> Void in

            let jsonResult = try! JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments)
            var token : Token
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = Token.fromJSON(tokenDic)
                    MPXTracker.trackToken(token: token._id)
                    callback(token)
                } else {
                    failure(NSError(domain: "mercadopago.sdk.createToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as! [AnyHashable: AnyObject]))
                }
            }
        }, failure: failure)
    }


    public func cloneToken(tokenId: String, callback : @escaping (Token) -> Void, failure: ((_ error: NSError) -> Void)) {

    }

    open class func getBankDeals(callback : @escaping ([BankDeal]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: PromosService = PromosService(baseURL: baseURL)
        service.getPromos(public_key: MercadoPagoContext.publicKey(), success: { (jsonResult) -> Void in
            let promosArray = jsonResult as? NSArray?
            var promos : [BankDeal] = [BankDeal]()
            if promosArray != nil {
                for i in 0 ..< promosArray!!.count {
                    if let promoDic = promosArray!![i] as? NSDictionary {
                        promos.append(BankDeal.fromJSON(promoDic))
                    }
                }
            }
            callback(promos)
        }, failure: failure)
    }

    open class func getIdentificationTypes(callback: @escaping ([IdentificationType]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: IdentificationService = IdentificationService(baseURL: baseURL)
        service.getIdentificationTypes(success: {(data: Data!) -> Void in
            let jsonResult = try! JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments)

            if let error = jsonResult as? NSDictionary {
                if (error["status"]! as? Int) == 404 {
                    failure(NSError(domain: "mercadopago.sdk.getIdentificationTypes", code: MercadoPago.ERROR_API_CODE, userInfo: error as! [AnyHashable: AnyObject]))
                }
            } else {
                let identificationTypesResult = jsonResult as? NSArray
                var identificationTypes : [IdentificationType] = [IdentificationType]()
                if identificationTypesResult != nil {
                    for i in 0 ..< identificationTypesResult!.count {
                        if let identificationTypeDic = identificationTypesResult![i] as? NSDictionary {
                            identificationTypes.append(IdentificationType.fromJSON(identificationTypeDic))
                        }
                    }
                }
                callback(identificationTypes)
            }
        }, failure: failure)
    }

    open class func getInstallments(bin: String?, amount: Double, issuerId: String?, paymentMethodId: String, callback: @escaping ([PXInstallment]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: PaymentService = PaymentService(baseURL: baseURL)
        service.getInstallments(bin: bin, amount: amount, issuerId: issuerId, payment_method_id: paymentMethodId, success: callback, failure: failure)
    }

    open class func getIssuers(paymentMethodId: String, bin: String? = nil, callback: @escaping ([PXIssuer]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: PaymentService = PaymentService(baseURL: baseURL)
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

    open class func getPaymentMethods(callback: @escaping ([PXPaymentMethod]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: PaymentService = PaymentService(baseURL: baseURL)
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

    open class func getDirectDiscount(amount: Double, payerEmail: String, discountAdditionalInfo: NSDictionary?, callback: @escaping (PXDiscount?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        getCodeDiscount(amount: amount, payerEmail: payerEmail, couponCode: nil, discountAdditionalInfo: discountAdditionalInfo, callback: callback, failure: failure)
    }
    
    open class func getCodeDiscount(amount: Double, payerEmail: String, couponCode: String?, discountAdditionalInfo: NSDictionary?, callback: @escaping (PXDiscount?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
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

    open class func getCustomer(additionalInfo: NSDictionary? = MercadoPagoCheckoutViewModel.servicePreference.customerAdditionalInfo, callback: @escaping (PXCustomer) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: CustomService = CustomService(baseURL: getCustomerBaseURL, URI: getCustomerURI)
        
        var addInfo: String = ""
        if !NSDictionary.isNullOrEmpty(additionalInfo), let addInfoDict = additionalInfo {
            addInfo = addInfoDict.parseToQuery()
        }
        
        service.getCustomer(params: addInfo, success: callback, failure: failure)
    }

    open class func createCheckoutPreference(bodyInfo: NSDictionary? = nil, callback: @escaping (PXCheckoutPreference) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
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
    open static func setBaseURL(_ baseURL: String) {
        MercadoPagoServices.baseURL = baseURL
    }

    open static func setGatewayBaseURL(_ gatewayBaseURL: String) {
        MercadoPagoServices.gatewayBaseURL = gatewayBaseURL
    }

    open static func setGetCustomerBaseURL(_ getCustomerBaseURL: String) {
        MercadoPagoServices.getCustomerBaseURL = getCustomerBaseURL
    }

    open static func setCreateCheckoutPreferenceURL(_ createCheckoutPreferenceURL: String) {
        MercadoPagoServices.createCheckoutPreferenceURL = createCheckoutPreferenceURL
    }

    open static func setGetMerchantDiscountBaseURL(_ getMerchantDiscountBaseURL: String) {
        MercadoPagoServices.getMerchantDiscountBaseURL = getMerchantDiscountBaseURL
    }

    open static func setGetCustomerURI(_ getCustomerURI: String) {
        MercadoPagoServices.getCustomerURI = getCustomerURI
    }

    open static func setCreateCheckoutPreferenceURI(_ createCheckoutPreferenceURI: String) {
        MercadoPagoServices.createCheckoutPreferenceURI = createCheckoutPreferenceURI
    }

    open static func setGetMerchantDiscountURI(_ getMerchantDiscountURI: String) {
        MercadoPagoServices.getMerchantDiscountURI = getMerchantDiscountURI
    }

    open static func setGetCustomerAdditionalInfo(_ getCustomerAdditionalInfo: NSDictionary) {
        MercadoPagoServices.getCustomerAdditionalInfo = getCustomerAdditionalInfo
    }

    open static func setCreateCheckoutPreferenceAdditionalInfo(_ createCheckoutPreferenceAdditionalInfo: NSDictionary) {
        MercadoPagoServices.createCheckoutPreferenceAdditionalInfo = createCheckoutPreferenceAdditionalInfo
    }

    open static func setGetDiscountAdditionalInfo(_ getDiscountAdditionalInfo: NSDictionary) {
        MercadoPagoServices.getDiscountAdditionalInfo = getDiscountAdditionalInfo
    }

    open class func cloneToken(_ token: Token,
                               securityCode: String,
                               baseURL: String = ServicePreference.MP_API_BASE_URL, success: @escaping (_ token: Token) -> Void,
                               failure: ((_ error: NSError) -> Void)?) {

        let service: GatewayService = GatewayService(baseURL: baseURL)
        service.cloneToken(public_key: MercadoPagoContext.publicKey(), token: token, securityCode: securityCode, success: {(data: Data?) -> Void in
            let jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments)
            var token : Token
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = Token.fromJSON(tokenDic)
                    MPXTracker.trackToken(token: token._id)
                    success(token)
                } else {
                    if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.createToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as! [AnyHashable: AnyObject]))
                    }
                }
            }
            } as! (Data?) -> Void, failure: failure)

    }

    internal class func getParamsPublicKey() -> String {
        var params: String = ""

        params.paramsAppend(key: ApiParams.PUBLIC_KEY, value: MercadoPagoContext.publicKey())

        return params
    }

    internal class func getParamsPublicKeyAndAcessToken() -> String {
        var params: String = ""

        params.paramsAppend(key: ApiParams.PAYER_ACCESS_TOKEN, value: MercadoPagoContext.payerAccessToken())
        params.paramsAppend(key: ApiParams.PUBLIC_KEY, value: MercadoPagoContext.publicKey())

        return params
    }

}
