//
//  MPServicesBuilder.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation

open class MPServicesBuilder: NSObject {

    static let MP_PAYMENTS_URI = ServicePreference.MP_ENVIROMENT + "/checkout/payments"

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
        service.getToken(key: MercadoPagoContext.keyValue(), cardTokenJSON: cardTokenJSON, success: {(jsonResult: AnyObject?) -> Void in
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

    open class func getPaymentMethods(baseURL: String = ServicePreference.MP_API_BASE_URL,
                                      _ success: @escaping (_ paymentMethods: [PaymentMethod]?) -> Void,
                                      failure: ((_ error: NSError) -> Void)?) {

        let service: PaymentService = PaymentService(baseURL: baseURL)
        service.getPaymentMethods(key: MercadoPagoContext.keyValue(), success: {(jsonResult: AnyObject?) -> Void in
            if let errorDic = jsonResult as? NSDictionary {
                if errorDic["error"] != nil {
                    if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.getPaymentMethods", code: MercadoPago.ERROR_API_CODE, userInfo: errorDic as! [AnyHashable: AnyObject]))
                    }
                }
            } else {
                let paymentMethods = jsonResult as? NSArray
                var pms : [PaymentMethod] = [PaymentMethod]()
                if paymentMethods != nil {
                    for i in 0..<paymentMethods!.count {
                        if let pmDic = paymentMethods![i] as? NSDictionary {
                            pms.append(PaymentMethod.fromJSON(pmDic))
                        }
                    }
                }
                success(pms)
            }
        }, failure: failure)

    }

    open class func getIdentificationTypes(baseURL: String = ServicePreference.MP_API_BASE_URL,
                                           _ success: @escaping (_ identificationTypes: [IdentificationType]?) -> Void,
                                           failure: ((_ error: NSError) -> Void)?) {

        let service: IdentificationService = IdentificationService(baseURL: baseURL)
        service.getIdentificationTypes(key: MercadoPagoContext.keyValue(), success: {(jsonResult: AnyObject?) -> Void in

            if let error = jsonResult as? NSDictionary {
                if (error["status"]! as? Int) == 404 {
                    if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.getIdentificationTypes", code: MercadoPago.ERROR_API_CODE, userInfo: error as! [AnyHashable: AnyObject]))
                    }
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
                success(identificationTypes)
            }
        }, failure: failure)

    }

    open class func getInstallments(_ bin: String? = nil, amount: Double, issuer: Issuer?, paymentMethodId: String, baseURL: String = ServicePreference.MP_API_BASE_URL,
                                    success: @escaping (_ installments: [Installment]) -> Void,
                                    failure: @escaping ((_ error: NSError) -> Void)) {

        let service: PaymentService = PaymentService(baseURL: baseURL)
        service.getInstallments(key: MercadoPagoContext.keyValue(), bin: bin, amount: amount, issuer_id: issuer?._id, payment_method_id: paymentMethodId, success: success, failure: failure)

    }

    open class func getIssuers(_ paymentMethod: PaymentMethod, bin: String? = nil, baseURL: String = ServicePreference.MP_API_BASE_URL, success: @escaping (_ issuers: [Issuer]) -> Void, failure: ((_ error: NSError) -> Void)?) {

        let service: PaymentService = PaymentService(baseURL: baseURL)
        service.getIssuers(key: MercadoPagoContext.keyValue(), payment_method_id: paymentMethod._id, bin: bin, success: {(jsonResult: AnyObject?) -> Void in

            if let errorDic = jsonResult as? NSDictionary {
                if errorDic["error"] != nil {
                    if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.getIssuers", code: MercadoPago.ERROR_API_CODE, userInfo: errorDic as! [AnyHashable: AnyObject]))
                    }
                }
            } else {
                let issuersArray = jsonResult as? NSArray
                var issuers : [Issuer] = [Issuer]()
                if issuersArray != nil {
                    for i in 0..<issuersArray!.count {
                        if let issuerDic = issuersArray![i] as? NSDictionary {
                            issuers.append(Issuer.fromJSON(issuerDic))
                        }
                    }
                }
                success(issuers)
            }
        }, failure: failure)

    }

    open class func getPromos( baseURL: String = ServicePreference.MP_API_BASE_URL,
                               _ success: @escaping (_ promos: [Promo]?) -> Void,
                               failure: ((_ error: NSError) -> Void)?) {

        let service: PromosService = PromosService(baseURL: baseURL)
        service.getPromos(public_key: MercadoPagoContext.publicKey(), success: { (jsonResult) -> Void in
            let promosArray = jsonResult as? NSArray?
            var promos : [Promo] = [Promo]()
            if promosArray != nil {
                for i in 0 ..< promosArray!!.count {
                    if let promoDic = promosArray!![i] as? NSDictionary {
                        promos.append(Promo.fromJSON(promoDic))
                    }
                }
            }
            success(promos)
        }, failure: failure)

    }

    open class func searchPaymentMethods(_ amount: Double, defaultPaymenMethodId: String?, excludedPaymentTypeIds: Set<String>?, excludedPaymentMethodIds: Set<String>?, baseURL: String = ServicePreference.MP_API_BASE_URL, success: @escaping (PaymentMethodSearch) -> Void, failure: ((_ error: NSError) -> Void)?) {

        let paymentMethodSearchService = PaymentMethodSearchService(baseURL: baseURL)
        paymentMethodSearchService.getPaymentMethods(amount, defaultPaymenMethodId : defaultPaymenMethodId, excludedPaymentTypeIds: excludedPaymentTypeIds, excludedPaymentMethodIds: excludedPaymentMethodIds, success: success, failure: failure!)

    }

    @available(*, deprecated: 2.4.4, message: "Use getInstructions(for paymentId : String ...) instead")
    open class func getInstructions(_ paymentId: Int, paymentTypeId: String? = "",
                                    success : @escaping (_ instructionsInfo: InstructionsInfo) -> Void,
                                    failure: ((_ error: NSError) -> Void)?) {
        let paymentId = String(paymentId)
        MPServicesBuilder.getInstructions(for: paymentId, paymentTypeId: paymentTypeId, success: success, failure: failure)
    }

    open class func getInstructions(for paymentId: String, paymentTypeId: String? = "",
                                    baseURL: String = ServicePreference.MP_API_BASE_URL, success : @escaping (_ instructionsInfo: InstructionsInfo) -> Void,
                                    failure: ((_ error: NSError) -> Void)?) {

        let instructionsService = InstructionsService(baseURL: baseURL)
        instructionsService.getInstructions(for: paymentId, paymentTypeId: paymentTypeId, success: { (instructionsInfo : InstructionsInfo) -> Void in
            success(instructionsInfo)
        }, failure : failure)
    }

    open class func getPreference(_ preferenceId: String,
                                  baseURL: String = ServicePreference.MP_API_BASE_URL, success : @escaping (_ preference: CheckoutPreference) -> Void,
                                  failure: @escaping ((_ error: NSError) -> Void)) {

        let preferenceService = PreferenceService(baseURL: baseURL)
        preferenceService.getPreference(preferenceId, success: { (preference : CheckoutPreference) in
            MercadoPagoContext.setSiteID(preference.siteId)
            success(preference)
        }, failure: failure)
    }

}
