//
//  MPServicesBuilder.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoTracker

public class MPServicesBuilder : NSObject {
   
    static let MP_PAYMENTS_URI = MercadoPago.MP_ENVIROMENT + "/checkout/payments"


    public class func createNewCardToken(cardToken : CardToken,
                                         success:(token : Token?) -> Void,
                                         failure: ((error: NSError) -> Void)?) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "CREATE_CARD_TOKEN", result: nil)
      
        cardToken.device = Device()
        let service = GatewayService(baseURL: MercadoPago.MP_API_BASE_URL)
        service.getToken(public_key: MercadoPagoContext.publicKey(), cardToken: cardToken, success: {(jsonResult: AnyObject?) -> Void in
            var token : Token? = nil
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = Token.fromJSON(tokenDic)
                    MPTracker.trackCreateToken(MercadoPagoContext.sharedInstance, token: token?._id)
                    success(token: token)
                } else {
                    if failure != nil {
                        failure!(error: NSError(domain: "mercadopago.sdk.createNewCardToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as [NSObject : AnyObject]))
                    }
                }
            }
            }, failure: failure)
    }
    
    public class func createToken(savedCardToken : SavedCardToken,
                        success: (token : Token?) -> Void,
                        failure: ((error: NSError) -> Void)?) {
        
            MercadoPagoContext.initFlavor1()
            MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "CREATE_SAVED_TOKEN", result: nil)
            savedCardToken.device = Device()
            let service : GatewayService = GatewayService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getToken(public_key: MercadoPagoContext.publicKey(), savedCardToken: savedCardToken, success: {(jsonResult: AnyObject?) -> Void in
                var token : Token? = nil
                if let tokenDic = jsonResult as? NSDictionary {
                    if tokenDic["error"] == nil {
                        token = Token.fromJSON(tokenDic)
                         MPTracker.trackCreateToken(MercadoPagoContext.sharedInstance, token: token?._id)
                        success(token: token)
                    } else {
                        if failure != nil {
                            failure!(error: NSError(domain: "mercadopago.sdk.createToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as [NSObject : AnyObject]))
                        }
                    }
                }
                }, failure: failure)

    }
    
    public class func cloneToken(token : Token,
                                 securityCode: String,
                                  success: (token : Token?) -> Void,
                                  failure: ((error: NSError) -> Void)?) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "CLONE_TOKEN", result: nil)
     //   savedCardToken.device = Device()
        let service : GatewayService = GatewayService(baseURL: MercadoPago.MP_API_BASE_URL)
        service.cloneToken(public_key: MercadoPagoContext.publicKey(), token: token,securityCode: securityCode, success:{(jsonResult: AnyObject?) -> Void in
            var token : Token? = nil
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = Token.fromJSON(tokenDic)
                    MPTracker.trackCreateToken(MercadoPagoContext.sharedInstance, token: token?._id)
                    success(token: token)
                } else {
                    if failure != nil {
                        failure!(error: NSError(domain: "mercadopago.sdk.createToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as [NSObject : AnyObject]))
                    }
                }
            }
            }, failure: failure)
        
        
    }

    
    
    public class func getPaymentMethods(
                        success: (paymentMethods: [PaymentMethod]?) -> Void,
                        failure: ((error: NSError) -> Void)?) {
        
            MercadoPagoContext.initFlavor1()
            MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_PAYMENT_METHODS", result: nil)
              let service : PaymentService = PaymentService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getPaymentMethods(public_key: MercadoPagoContext.publicKey(), success: {(jsonResult: AnyObject?) -> Void in
                if let errorDic = jsonResult as? NSDictionary {
                    if errorDic["error"] != nil {
                        if failure != nil {
                            failure!(error: NSError(domain: "mercadopago.sdk.getPaymentMethods", code: MercadoPago.ERROR_API_CODE, userInfo: errorDic as [NSObject : AnyObject]))
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
                    success(paymentMethods: pms)
                }
                }, failure: failure)
     
    }
    
    public class func getIdentificationTypes(
                        success: (identificationTypes: [IdentificationType]?) -> Void,
                        failure: ((error: NSError) -> Void)?) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_IDENTIFICATION_TYPES", result: nil)
             let service : IdentificationService = IdentificationService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getIdentificationTypes(public_key: MercadoPagoContext.publicKey(), privateKey: MercadoPagoContext.privateKey(), success: {(jsonResult: AnyObject?) -> Void in
                
                if let error = jsonResult as? NSDictionary {
                    if (error["status"]! as? Int) == 404 {
                        if failure != nil {
                            failure!(error: NSError(domain: "mercadopago.sdk.getIdentificationTypes", code: MercadoPago.ERROR_API_CODE, userInfo: error as [NSObject : AnyObject]))
                        }
                    }
                } else {
                    let identificationTypesResult = jsonResult as? NSArray?
                    var identificationTypes : [IdentificationType] = [IdentificationType]()
                    if identificationTypesResult != nil {
                        for var i = 0; i < identificationTypesResult!!.count; i++ {
                            if let identificationTypeDic = identificationTypesResult!![i] as? NSDictionary {
                                identificationTypes.append(IdentificationType.fromJSON(identificationTypeDic))
                            }
                        }
                    }
                    success(identificationTypes: identificationTypes)
                }
                }, failure: failure)
       
    }
    
    public class func getInstallments(bin: String? = nil, amount: Double, issuer: Issuer?, paymentMethodId: String,
                                      success: (installments: [Installment]?) -> Void,
                                      failure: ((error: NSError) -> Void)) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_INSTALLMENTS", result: nil)

            let service : PaymentService = PaymentService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getInstallments(public_key:MercadoPagoContext.publicKey(), bin: bin, amount: amount, issuer_id: issuer?._id, payment_method_id: paymentMethodId, success: success, failure: failure)
        
    }
    
    public class func getIssuers(paymentMethod : PaymentMethod, bin: String? = nil, success: (issuers: [Issuer]?) -> Void, failure: ((error: NSError) -> Void)?) {
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_ISSUERS", result: nil)

            let service : PaymentService = PaymentService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getIssuers(public_key: MercadoPagoContext.publicKey(), payment_method_id: paymentMethod._id, bin: bin, success: {(jsonResult: AnyObject?) -> Void in

                if let errorDic = jsonResult as? NSDictionary {
                    if errorDic["error"] != nil {
                        if failure != nil {
                            failure!(error: NSError(domain: "mercadopago.sdk.getIssuers", code: MercadoPago.ERROR_API_CODE, userInfo: errorDic as [NSObject : AnyObject]))
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
                    success(issuers: issuers)
                }
                }, failure: failure)
        
    }
    
    public class func getPromos(
                        success: (promos: [Promo]?) -> Void,
                        failure: ((error: NSError) -> Void)?) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_BANK_DEALS", result: nil)
        
        let service : PromosService = PromosService(baseURL: MercadoPago.MP_API_BASE_URL)
        service.getPromos(public_key: MercadoPagoContext.publicKey(), success: { (jsonResult) -> Void in
            let promosArray = jsonResult as? NSArray?
            var promos : [Promo] = [Promo]()
            if promosArray != nil {
                for var i = 0; i < promosArray!!.count; i++ {
                    if let promoDic = promosArray!![i] as? NSDictionary {
                        promos.append(Promo.fromJSON(promoDic))
                    }
                }
            }
            success(promos: promos)
            }, failure: failure)
        
    }

        
    public class func createPayment(merchantBaseUrl : String, merchantPaymentUri : String, payment : MerchantPayment,
                         success: (payment: Payment) -> Void,
                         failure: ((error: NSError) -> Void)?) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "CREATE_PAYMENT", result: nil)
        let service : MerchantService = MerchantService()
        service.createPayment(payment: payment, success: {(jsonResult: AnyObject?) -> Void in
            var payment : Payment? = nil
            
            
            
            if let paymentDic = jsonResult as? NSDictionary {
                if paymentDic["error"] != nil {
                    if failure != nil {
                        failure!(error: NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_API_CODE, userInfo: paymentDic as [NSObject : AnyObject]))
                    }
                } else {
                    if paymentDic.allKeys.count > 0 {
                        payment = Payment.fromJSON(paymentDic)
                        success(payment: payment!)
                    } else {
                        failure!(error: NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_PAYMENT, userInfo: ["message": "PAYMENT_ERROR".localized]))
                    }
                    
                }
            } else {
                if failure != nil {
                    failure!(error: NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
                }
            }
            }, failure: failure)
    }


    public class func searchPaymentMethods(amount : Double, customerAccessToken : String? = nil, excludedPaymentTypeIds : Set<String>?, excludedPaymentMethodIds : Set<String>?, success: PaymentMethodSearch -> Void, failure: ((error: NSError) -> Void)?) {
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_PAYMENT_METHOD_SEARCH", result: nil)
        let paymentMethodSearchService = PaymentMethodSearchService()
        paymentMethodSearchService.getPaymentMethods(amount, customerAccessToken : customerAccessToken, excludedPaymentTypeIds: excludedPaymentTypeIds, excludedPaymentMethodIds: excludedPaymentMethodIds, success: success, failure: failure!)
    
    }
    
    public class func getInstructions(paymentId : Int, paymentTypeId: String? = "",
                        success : (instructionsInfo : InstructionsInfo) -> Void,
                        failure: ((error: NSError) -> Void)?) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_INSTRUCTIONS", result: nil)
        let instructionsService = InstructionsService()
        instructionsService.getInstructions(paymentId, paymentTypeId: paymentTypeId, success:  { (instructionsInfo : InstructionsInfo) -> Void in
            success(instructionsInfo: instructionsInfo)
        }, failure : failure)
    }
    
    public class func getPreference(preferenceId : String,
                         success : (preference : CheckoutPreference) -> Void,
                         failure: ((error: NSError) -> Void)){
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_PREFERENCE", result: nil)
        let preferenceService = PreferenceService()
        preferenceService.getPreference(preferenceId, success: { (preference : CheckoutPreference) in
            MercadoPagoContext.setSiteID(preference.siteId)
            success(preference: preference)
            }, failure: failure)
    }

}



