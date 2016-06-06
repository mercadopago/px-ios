//
//  MPServicesBuilder.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation


public class MPServicesBuilder : NSObject {
   
    static let MP_PAYMENTS_URI = "/beta/checkout/payments"


    public class func createNewCardToken(cardToken : CardToken, success: (token : Token?) -> Void, failure: ((error: NSError) -> Void)?) {
        cardToken.device = Device()
        let service = GatewayService(baseURL: MercadoPagoService.MP_BASE_URL)
        service.getToken(public_key: MercadoPagoContext.publicKey(), cardToken: cardToken, success: {(jsonResult: AnyObject?) -> Void in
            var token : Token? = nil
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = Token.fromJSON(tokenDic)
                    success(token: token)
                } else {
                    if failure != nil {
                        failure!(error: NSError(domain: "mercadopago.sdk.createNewCardToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as [NSObject : AnyObject]))
                    }
                }
            }
            }, failure: failure)
    }
    
    public class func createToken(savedCardToken : SavedCardToken, success: (token : Token?) -> Void, failure: ((error: NSError) -> Void)?) {
        

            savedCardToken.device = Device()
            
            let service : GatewayService = GatewayService(baseURL: MercadoPagoService.MP_BASE_URL)
            service.getToken(public_key: MercadoPagoContext.publicKey(), savedCardToken: savedCardToken, success: {(jsonResult: AnyObject?) -> Void in
                var token : Token? = nil
                if let tokenDic = jsonResult as? NSDictionary {
                    if tokenDic["error"] == nil {
                        token = Token.fromJSON(tokenDic)
                        success(token: token)
                    } else {
                        if failure != nil {
                            failure!(error: NSError(domain: "mercadopago.sdk.createToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as [NSObject : AnyObject]))
                        }
                    }
                }
                }, failure: failure)

    }
    
    public class func getPaymentMethods(success: (paymentMethods: [PaymentMethod]?) -> Void, failure: ((error: NSError) -> Void)?) {
        
              let service : PaymentService = PaymentService(baseURL: MercadoPagoService.MP_BASE_URL)
            service.getPaymentMethods(public_key: MercadoPagoContext.publicKey(), success: {(jsonResult: AnyObject?) -> Void in
                if let errorDic = jsonResult as? NSDictionary {
                    if errorDic["error"] != nil {
                        if failure != nil {
                            failure!(error: NSError(domain: "mercadopago.sdk.getPaymentMethods", code: MercadoPago.ERROR_API_CODE, userInfo: errorDic as [NSObject : AnyObject]))
                        }
                    }
                } else {
                    print(jsonResult)
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
    
    public class func getIdentificationTypes(success: (identificationTypes: [IdentificationType]?) -> Void, failure: ((error: NSError) -> Void)?) {
        
             let service : IdentificationService = IdentificationService(baseURL: MercadoPagoService.MP_BASE_URL)
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
    
    public class func getInstallments(bin: String, amount: Double, issuer: Issuer?, paymentTypeId: PaymentTypeId, success: (installments: [Installment]?) -> Void, failure: ((error: NSError) -> Void)) {
        
            let service : PaymentService = PaymentService(baseURL: MercadoPagoService.MP_BASE_URL)
            service.getInstallments(public_key:MercadoPagoContext.publicKey(), bin: bin, amount: amount, issuer_id: issuer?._id, payment_type_id: paymentTypeId.rawValue, success: success, failure: failure)
        
    }
    
    public class func getIssuers(paymentMethod : PaymentMethod, bin: String? = nil, success: (issuers: [Issuer]?) -> Void, failure: ((error: NSError) -> Void)?) {
        
            let service : PaymentService = PaymentService(baseURL: MercadoPagoService.MP_BASE_URL)
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
    
    public class func getPromos(success: (promos: [Promo]?) -> Void, failure: ((error: NSError) -> Void)?) {
        // TODO: Está hecho para MLA fijo porque va a cambiar la URL para que dependa de una API y una public key
        let service : PromosService = PromosService(baseURL: MercadoPagoService.MP_BASE_URL)
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

        
    public class func createPayment(merchantBaseUrl : String, merchantPaymentUri : String, payment : MerchantPayment, success: (payment: Payment) -> Void, failure: ((error: NSError) -> Void)?) {
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

    public class func searchPaymentMethods(amount : Double, excludedPaymentTypeIds : Set<PaymentTypeId>?, excludedPaymentMethodIds : Set<String>?, success: PaymentMethodSearch -> Void, failure: ((error: NSError) -> Void)?) {
        let paymentMethodSearchService = PaymentMethodSearchService()
        paymentMethodSearchService.getPaymentMethods(amount, excludedPaymentTypeIds: excludedPaymentTypeIds, excludedPaymentMethodIds: excludedPaymentMethodIds, success: success, failure: failure!)
    
    }
    
    public class func getInstructions(paymentId : Int, paymentMethodId : String, paymentTypeId: String, success : (instruction : Instruction) -> Void, failure: ((error: NSError) -> Void)?){
        let instructionsService = InstructionsService()
        instructionsService.getInstructions(paymentId, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId, success:  { (instruction) -> Void in
            success(instruction: instruction)
        }, failure : failure)
    }
    
    public class func getPreference(preferenceId : String, success : (preference : CheckoutPreference) -> Void, failure: ((error: NSError) -> Void)){
        let preferenceService = PreferenceService()
        preferenceService.getPreference(preferenceId, success: { (preference : CheckoutPreference) in
            success(preference: preference)
            }, failure: failure)
    }

}



