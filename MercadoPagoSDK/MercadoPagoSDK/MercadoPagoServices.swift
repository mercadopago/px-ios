//
//  MercadoPagoServices.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation

open class MercadoPagoServices: NSObject {

    private var merchantPublicKey: String
    private var payerAccessToken: String
    private var proccesingMode: String

    private static var baseURL: String!
    private var createPaymentBaseURL: String!
    private var gatewayBaseURL: String!
    private var getCustomerBaseURL: String!
    private var createCheckoutPreferenceURL: String!
    private var getMerchantDiscountBaseURL: String!
    private var getCustomerURI: String!
    private var createPaymentURI: String!
    private var createCheckoutPreferenceURI: String!
    private var getMerchantDiscountURI: String!

    private var getCustomerAdditionalInfo: NSDictionary!
    private var createPaymentAdditionalInfo: NSDictionary!
    private var createCheckoutPreferenceAdditionalInfo: NSDictionary!
    private var getDiscountAdditionalInfo: NSDictionary!

    init(merchantPublicKey: String, payerAccessToken: String, proccesingMode: String) {
        self.merchantPublicKey = merchantPublicKey
        self.payerAccessToken = payerAccessToken
        self.proccesingMode = proccesingMode
    }

    open class func getCheckoutPreference(checkoutPreferenceId: String, callback : @escaping (CheckoutPreference) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let preferenceService = PreferenceService(baseURL: baseURL)
        preferenceService.getPreference(checkoutPreferenceId, success: { (preference : CheckoutPreference) in
            MercadoPagoContext.setSiteID(preference.siteId) //TODO AUGUSTO: SACAR ESTO DE ACA.
            callback(preference)
        }, failure: failure)
    }

    open class func getInstructions(paymentId: Int64, paymentTypeId: String, callback : @escaping (InstructionsInfo) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let instructionsService = InstructionsService(baseURL: baseURL)
        instructionsService.getInstructions(for: paymentId, paymentTypeId: paymentTypeId, success: { (instructionsInfo : InstructionsInfo) -> Void in
            callback(instructionsInfo)
        }, failure : failure)
    }

    open class func getPaymentMethodSearch(amount: Double, excludedPaymentTypesIds: Set<String>?, excludedPaymentMethodsIds: Set<String>?, payer: Payer, site: PXSite, callback : @escaping (PaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        //TODO AUGUSTO: AGREGAR DEFAULT PAYMENT METHOD COMO PARAMETRO.
        let paymentMethodSearchService = PaymentMethodSearchService(baseURL: baseURL)
        paymentMethodSearchService.getPaymentMethods(amount, defaultPaymenMethodId: nil, excludedPaymentTypeIds: excludedPaymentTypesIds, excludedPaymentMethodIds: excludedPaymentMethodsIds, success: callback, failure: failure)
    }

    public func createPayment(paymentBody: MPPayment, callback : @escaping (Payment) -> Void, failure: ((_ error: NSError) -> Void)) {

    }

    public func createPayment(transactionId: String, paymentData: [String: Any], callback : @escaping (Payment) -> Void, failure: ((_ error: NSError) -> Void)) {

    }

    public func createToken(cardToken: CardToken, callback : @escaping (Token) -> Void, failure: ((_ error: NSError) -> Void)) {

    }

    public func createToken(savedESCCardToken: SavedESCCardToken, callback : @escaping (Token) -> Void, failure: ((_ error: NSError) -> Void)) {
    }

    public func createToken(savedCardToken: SavedCardToken, callback : @escaping (Token) -> Void, failure: ((_ error: NSError) -> Void)) {

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
        service.getIdentificationTypes(success: {(jsonResult: AnyObject?) -> Void in

            if let error = jsonResult as? NSDictionary {
                if (error["status"]! as? Int) == 404 {
                    failure(NSError(domain: "mercadopago.sdk.getIdentificationTypes", code: MercadoPago.ERROR_API_CODE, userInfo: error as! [AnyHashable: AnyObject]))
                }
            } else {
                let identificationTypesResult = jsonResult as? NSArray?
                var identificationTypes : [IdentificationType] = [IdentificationType]()
                if identificationTypesResult != nil {
                    for i in 0 ..< identificationTypesResult!!.count {
                        if let identificationTypeDic = identificationTypesResult!![i] as? NSDictionary {
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
        service.getIssuers(payment_method_id: paymentMethodId, bin: bin, success: {(jsonResult: AnyObject?) -> Void in
            
            if let errorDic = jsonResult as? NSDictionary {
                if errorDic["error"] != nil {
                    failure(NSError(domain: "mercadopago.sdk.getIssuers", code: MercadoPago.ERROR_API_CODE, userInfo: errorDic as! [AnyHashable: AnyObject]))
                }
            } else {
                let issuersArray = jsonResult as? NSArray
                var issuers : [PXIssuer] = [PXIssuer]()
                if issuersArray != nil {
                    for i in 0..<issuersArray!.count {
                        if let issuerDic = issuersArray![i] as? [String:Any] {
                            issuers.append(PXIssuer.fromJSON(issuerDic))
                        }
                    }
                }
                callback(issuers)
            }
        }, failure: failure)
    }

    open class func getPaymentMethods(callback: @escaping ([PXPaymentMethod]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        let service: PaymentService = PaymentService(baseURL: baseURL)
        service.getPaymentMethods(success: {(jsonResult: AnyObject?) -> Void in
            if let errorDic = jsonResult as? NSDictionary {
                if errorDic["error"] != nil {
                    failure(NSError(domain: "mercadopago.sdk.getPaymentMethods", code: MercadoPago.ERROR_API_CODE, userInfo: errorDic as! [AnyHashable: AnyObject]))
                }
            } else {
                let paymentMethods = jsonResult as? NSArray
                var pms : [PXPaymentMethod] = [PXPaymentMethod]()
                if paymentMethods != nil {
                    for i in 0..<paymentMethods!.count {
                        if let pmDic = paymentMethods![i] as? [String:Any] {
                            pms.append(PXPaymentMethod.fromJSON(pmDic))
                        }
                    }
                }
                callback(pms)
            }
        }, failure: failure)
    }

    public func getDirectDiscount(amount: String, payerEmail: String, discountAdditionalInfo: NSDictionary, callback: @escaping (DiscountCoupon) -> Void, failure: ((_ error: NSError) -> Void)) {

    }

    public func getCodeDiscount(amount: String, payerEmail: String, couponCode: String, callback: @escaping (DiscountCoupon) -> Void, failure: ((_ error: NSError) -> Void)) {

    }

    public func getCodeDiscount(amount: String, payerEmail: String, couponCode: String, discountAdditionalInfo: NSDictionary, callback: @escaping (DiscountCoupon) -> Void, failure: ((_ error: NSError) -> Void)) {

    }

//    public func getCampaigns(callback: @escaping ([Campaign]) -> Void, failure: ((_ error: NSError) -> Void)) {
//
//    }

    public func getCustomer(additionalInfo: NSDictionary? = nil, callback: @escaping (Customer) -> Void, failure: ((_ error: NSError) -> Void)) {

    }

    public func createCheckoutPreference(bodyInfo: NSDictionary? = nil, callback: @escaping (CheckoutPreference) -> Void, failure: ((_ error: NSError) -> Void)) {

    }

    //SETS
    open static func setBaseURL(_ baseURL: String) {
        MercadoPagoServices.baseURL = baseURL
    }

    public func setGatewayBaseURL(_ gatewayBaseURL: String) {
        self.gatewayBaseURL = gatewayBaseURL
    }

    public func setGetCustomerBaseURL(_ getCustomerBaseURL: String) {
        self.getCustomerBaseURL = getCustomerBaseURL
    }

    public func setCreateCheckoutPreferenceURL(_ createCheckoutPreferenceURL: String) {
        self.createCheckoutPreferenceURL = createCheckoutPreferenceURL
    }

    public func setGetMerchantDiscountBaseURL(_ getMerchantDiscountBaseURL: String) {
        self.getMerchantDiscountBaseURL = getMerchantDiscountBaseURL
    }

    public func setGetCustomerURI(_ getCustomerURI: String) {
        self.getCustomerURI = getCustomerURI
    }

//    public func setCreatePayment(baseURL: String = MP_API_BASE_URL, URI: String = MP_PAYMENTS_URI + "?api_version=" + API_VERSION, additionalInfo: NSDictionary = [:]) {
//        self.createPaymentBaseURL = baseURL
//        self.createPaymentURI  = URI
//        self.createPaymentAdditionalInfo = additionalInfo
//    }

    public func setCreatePaymentURI(_ createPaymentURI: String) {
        self.createPaymentURI = createPaymentURI
    }

    public func setCreateCheckoutPreferenceURI(_ createCheckoutPreferenceURI: String) {
        self.createCheckoutPreferenceURI = createCheckoutPreferenceURI
    }

    public func setGetMerchantDiscountURI(_ getMerchantDiscountURI: String) {
        self.getMerchantDiscountURI = getMerchantDiscountURI
    }

    public func setGetCustomerAdditionalInfo(_ getCustomerAdditionalInfo: NSDictionary) {
        self.getCustomerAdditionalInfo = getCustomerAdditionalInfo
    }

    public func setCreatePaymentAdditionalInfo(_ createPaymentAdditionalInfo: NSDictionary) {
        self.createPaymentAdditionalInfo = createPaymentAdditionalInfo
    }

    public func setCreateCheckoutPreferenceAdditionalInfo(_ createCheckoutPreferenceAdditionalInfo: NSDictionary) {
        self.createCheckoutPreferenceAdditionalInfo = createCheckoutPreferenceAdditionalInfo
    }

    public func setGetDiscountAdditionalInfo(_ getDiscountAdditionalInfo: NSDictionary) {
        self.getDiscountAdditionalInfo = getDiscountAdditionalInfo
    }

    open class func createNewCardToken(_ cardToken: CardToken, baseURL: String = ServicePreference.MP_API_BASE_URL,
                                       success:@escaping (_ token: Token) -> Void,
                                       failure: ((_ error: NSError) -> Void)?) {
        cardToken.device = Device()
        self.createToken(baseURL: baseURL, cardTokenJSON: cardToken.toJSONString(), success: success, failure: failure)
    }

    open class func createSavedCardToken(_ savedCardToken: SavedCardToken,
                                         baseURL: String =  ServicePreference.MP_API_BASE_URL, success: @escaping (_ token: Token) -> Void,
                                         failure: ((_ error: NSError) -> Void)?) {
        self.createToken(baseURL: baseURL, cardTokenJSON: savedCardToken.toJSONString(), success: success, failure: failure)
    }

    open class func createSavedESCCardToken(savedESCCardToken: SavedESCCardToken,
                                            baseURL: String =  ServicePreference.MP_API_BASE_URL, success: @escaping (_ token: Token) -> Void,
                                            failure: ((_ error: NSError) -> Void)?) {
        self.createToken(baseURL: baseURL, cardTokenJSON: savedESCCardToken.toJSONString(), success: success, failure: failure)
    }

    open class func createToken(baseURL: String, cardTokenJSON: String, success: @escaping (_ token: Token) -> Void, failure: ((_ error: NSError) -> Void)?) {
        let service: GatewayService = GatewayService(baseURL: baseURL)
        service.getToken(cardTokenJSON: cardTokenJSON, success: {(jsonResult: AnyObject?) -> Void in
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
        }, failure: failure)
    }

    open class func cloneToken(_ token: Token,
                               securityCode: String,
                               baseURL: String = ServicePreference.MP_API_BASE_URL, success: @escaping (_ token: Token) -> Void,
                               failure: ((_ error: NSError) -> Void)?) {

        let service: GatewayService = GatewayService(baseURL: baseURL)
        service.cloneToken(public_key: MercadoPagoContext.publicKey(), token: token, securityCode: securityCode, success: {(jsonResult: AnyObject?) -> Void in
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
        }, failure: failure)

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
