
//
//  MercadoPago.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit



public class MercadoPago : NSObject, UIAlertViewDelegate {
    
    
    
    public static let DEFAULT_FONT_NAME = ".SFUIDisplay-Light"
    
    public class var PUBLIC_KEY : String {
        return "public_key"
    }
    public class var PRIVATE_KEY : String {
        return "private_key"
    }
    
    public class var ERROR_KEY_CODE : Int {
        return -1
    }
    
    public class var ERROR_API_CODE : Int {
        return -2
    }
    
    public class var ERROR_UNKNOWN_CODE : Int {
        return -3
    }
    
    public class var ERROR_NOT_INSTALLMENTS_FOUND : Int {
        return -4
    }
    
    public class var ERROR_PAYMENT : Int {
        return -4
    }
    
    public class var ERROR_INSTRUCTIONS : Int {
        return -4
    }
    
    

    
    public func publicKey() -> String!{
        return self.pk
    }
    
    let BIN_LENGTH : Int = 6
    
    
    static var MP_TEST_ENV = "/beta"
    static let MP_PROD_ENV = "/v1"
    static let MP_ALPHA_ENV = "/gamma"
    static let MP_ENVIROMENT = MP_TEST_ENV  + "/checkout"
    
    static let MP_OP_ENVIROMENT = "/v1"
    
    static let MP_ALPHA_API_BASE_URL : String =  "http://api.mp.internal.ml.com"
    static let MP_API_BASE_URL_PROD : String =  "https://api.mercadopago.com"
    
    static let MP_API_BASE_URL : String =  MP_API_BASE_URL_PROD

    static let MP_CUSTOMER_URI = "/customers?preference_id="
    static let MP_PAYMENTS_URI = MP_ENVIROMENT + "/payments"
    
    public var privateKey : String?
    public var pk : String!
    
    public var paymentMethodId : String?
    public var paymentTypeId : String?
    
    public init (publicKey: String) {
        self.pk = publicKey
        
        
    }
    
    static var temporalNav : UINavigationController?
    
    public init (keyType: String?, key: String?) {
        if keyType != nil && key != nil {
        
            if keyType != MercadoPago.PUBLIC_KEY && keyType != MercadoPago.PRIVATE_KEY {
                fatalError("keyType must be 'public_key' or 'private_key'.")
            } else {
                if keyType == MercadoPago.PUBLIC_KEY {
                    self.pk = key
                } else if keyType == MercadoPago.PUBLIC_KEY {
                    self.privateKey = key
                }
            }
        } else {
            fatalError("keyType and key cannot be nil.")
        }
    }
    

    public func createNewCardToken(cardToken : CardToken, success: (token : Token?) -> Void, failure: ((error: NSError) -> Void)?) {
        
        if self.publicKey() != nil {
            cardToken.device = Device()
            let service : GatewayService = GatewayService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getToken(public_key: self.publicKey(), cardToken: cardToken, success: {(jsonResult: AnyObject?) -> Void in
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
        } else {
            if failure != nil {
                failure!(error: NSError(domain: "mercadopago.sdk.createNewCardToken", code: MercadoPago.ERROR_KEY_CODE, userInfo: ["message": "Unsupported key type for this method"]))
            }
        }
    }
    
    public func createToken(savedCardToken : SavedCardToken, success: (token : Token?) -> Void, failure: ((error: NSError) -> Void)?) {
        
        if self.publicKey() != nil {
            savedCardToken.device = Device()
            
            let service : GatewayService = GatewayService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getToken(public_key: self.publicKey(), savedCardToken: savedCardToken, success: {(jsonResult: AnyObject?) -> Void in
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
        } else {
            if failure != nil {
                failure!(error: NSError(domain: "mercadopago.sdk.createToken", code: MercadoPago.ERROR_KEY_CODE, userInfo: ["message": "Unsupported key type for this method"]))
            }
        }
    }
    
    public func getIdentificationTypes(success: (identificationTypes: [IdentificationType]?) -> Void, failure: ((error: NSError) -> Void)?) {
        
        if self.publicKey() != nil {
            let service : IdentificationService = IdentificationService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getIdentificationTypes(public_key: self.publicKey(), privateKey: self.privateKey, success: {(jsonResult: AnyObject?) -> Void in
                
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
        } else {
            if failure != nil {
                failure!(error: NSError(domain: "mercadopago.sdk.getIdentificationTypes", code: MercadoPago.ERROR_KEY_CODE, userInfo: ["message": "Unsupported key type for this method"]))
            }
        }
    }
    
    @available(*, deprecated=2.0)
    public func getInstallments(bin: String, amount: Double, issuerId: NSNumber?, paymentTypeId: String, success: (installments: [Installment]?) -> Void, failure: ((error: NSError) -> Void)) {
        
        if self.publicKey() != nil {
            let service : PaymentService = PaymentService(baseURL: MercadoPago.MP_API_BASE_URL)
             service.getInstallments(public_key: self.publicKey(), bin: bin, amount: amount, issuer_id: issuerId, payment_method_id: paymentTypeId, success: success, failure: failure)
        
        }
    }
    
    public func getIssuers(paymentMethodId : String, success: (issuers: [Issuer]?) -> Void, failure: ((error: NSError) -> Void)?) {
        
        if self.publicKey() != nil {
            let service : PaymentService = PaymentService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getIssuers(public_key: self.publicKey()!, payment_method_id: paymentMethodId, success: {(jsonResult: AnyObject?) -> Void in
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
        } else {
            if failure != nil {
                failure!(error: NSError(domain: "mercadopago.sdk.getIssuers", code: MercadoPago.ERROR_KEY_CODE, userInfo: ["message": "Unsupported key type for this method"]))
            }
        }
    }
    
    public func getPromos(success: (promos: [Promo]?) -> Void, failure: ((error: NSError) -> Void)?) {
        // TODO: Está hecho para MLA fijo porque va a cambiar la URL para que dependa de una API y una public key
        let service : PromosService = PromosService(baseURL: MercadoPago.MP_API_BASE_URL)
        service.getPromos(public_key: self.publicKey()!, success: { (jsonResult) -> Void in
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
    
    public class func isCardPaymentType(paymentTypeId: String) -> Bool {
        if paymentTypeId == "credit_card" || paymentTypeId == "debit_card" || paymentTypeId == "prepaid_card" {
            return true
        }
        return false
    }
    
    public class func getBundle() -> NSBundle? {
       return NSBundle(forClass:MercadoPago.self)
    }
    
    public class func getImage(name: String?) -> UIImage? {
        if name == nil || (name?.isEmpty)! {
            return nil
        }
        
        let bundle = getBundle()

        if (UIDevice.currentDevice().systemVersion as NSString).compare("8.0", options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending {
            var nameArr = name!.characters.split {$0 == "."}.map(String.init)
            let imageExtension : String = nameArr[1]
            let filePath = bundle?.pathForResource(name, ofType: imageExtension)
            if filePath != nil {
                return UIImage(contentsOfFile: filePath!)
            } else {
                return nil
            }
        }
        if #available(iOS 8.0, *) {
            return UIImage(named:name!, inBundle: bundle, compatibleWithTraitCollection:nil)
        } else {
        }
        return nil
    }
    
    public class func screenBoundsFixedToPortraitOrientation() -> CGRect {
        let screenSize : CGRect = UIScreen.mainScreen().bounds
        if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 && UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
            return CGRectMake(0.0, 0.0, screenSize.height, screenSize.width)
        }
        return screenSize
    }
    
    public class func showAlertViewWithError(error: NSError?, nav: UINavigationController?) {
        let msgDefault = "An error occurred while processing your request. Please try again."
        var msg : String? = msgDefault
        
        if error != nil {
            msg = error!.userInfo["message"] as? String
        }
        
        MercadoPago.temporalNav = nav
        
        let alert = UIAlertView()
        alert.title = "MercadoPago Error"
        alert.delegate = self
        alert.message = "Error = \(msg != nil ? msg! : msgDefault)"
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    public func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            MercadoPago.temporalNav?.popViewControllerAnimated(true)
        }
    }
    

    public class func getImageFor(paymentMethod : PaymentMethod, forCell: Bool? = false) -> UIImage?{
        if (forCell == true) {
            return MercadoPago.getImage(paymentMethod._id.lowercaseString)
        }else{
            return MercadoPago.getImage("icoTc_"+paymentMethod._id.lowercaseString)
        }

    }
    
    public class func getColorFor(paymentMethod : PaymentMethod) -> UIColor?{
        let path = MercadoPago.getBundle()!.pathForResource("PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        let pmConfig = dictPM?.valueForKey(paymentMethod._id) as! NSDictionary
        let stringColor = pmConfig.valueForKey("first_color") as! String
        //let intColor = Int(stringColor)
        return UIColor(netHex:Int(stringColor, radix: 16)!)
        
    }
    
    public class func getLabelMaskFor(paymentMethod : PaymentMethod, forCell: Bool? = false) -> String?{
        let path = MercadoPago.getBundle()!.pathForResource("PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        let pmConfig = dictPM?.valueForKey(paymentMethod._id) as! NSDictionary
        let etMask = pmConfig.valueForKey("label_mask") as! String
        
        return etMask
    }
    
    public class func getEditTextMaskFor(paymentMethod : PaymentMethod, forCell: Bool? = false) -> String?{
        let path = MercadoPago.getBundle()!.pathForResource("PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        let pmConfig = dictPM?.valueForKey(paymentMethod._id) as! NSDictionary
        let etMask = pmConfig.valueForKey("editText_mask") as! String

        return etMask
    }
    
    
    public class func getFontColorFor(paymentMethod : PaymentMethod) -> UIColor?{
        let path = MercadoPago.getBundle()!.pathForResource("PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        let pmConfig = dictPM?.valueForKey(paymentMethod._id) as! NSDictionary
        let stringColor = pmConfig.valueForKey("font_color") as! String
        //let intColor = Int(stringColor)
        return UIColor(netHex:Int(stringColor, radix: 16)!)
        
    }
    
    public class func getEditingFontColorFor(paymentMethod : PaymentMethod) -> UIColor?{
        let path = MercadoPago.getBundle()!.pathForResource("PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        let pmConfig = dictPM?.valueForKey(paymentMethod._id) as! NSDictionary
        let stringColor = pmConfig.valueForKey("editing_font_color") as! String
        //let intColor = Int(stringColor)
        return UIColor(netHex:Int(stringColor, radix: 16)!)
        
    }
    
    public class func createMPPayment(email : String, preferenceId : String, paymentMethod: PaymentMethod, token : Token? = nil, installments: Int = 1, issuer: Issuer? = nil, success: (payment: Payment) -> Void, failure: ((error: NSError) -> Void)?) {
    
        var issuerId = ""
        if issuer != nil {
            issuerId = String(issuer!._id!.integerValue)
        }

        
        var tokenId = ""
        if token != nil {
            tokenId = token!._id
        }
        
        let mpPayment = MPPayment(email: email, preferenceId: preferenceId, publicKey: MercadoPagoContext.publicKey(), paymentMethodId: paymentMethod._id, installments: installments, issuerId: issuerId, tokenId: tokenId)
        let service : MerchantService = MerchantService()
        service.createMPPayment(payment: mpPayment, success: { (jsonResult) in
            var payment : Payment? = nil
            
            if let paymentDic = jsonResult as? NSDictionary {
                if paymentDic["error"] != nil {
                    if failure != nil {
                        failure!(error: NSError(domain: "mercadopago.sdk.mercadoPago.createMPPayment", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey : "No se ha podido procesar el pago".localized, NSLocalizedFailureReasonErrorKey : paymentDic["error"] as! String]))
                    }
                } else {
                    if paymentDic.allKeys.count > 0 {
                        payment = Payment.fromJSON(paymentDic)
                        success(payment: payment!)
                        // Clear payment key after post payment success
                        MercadoPagoContext.clearPaymentKey()
                    } else {
                        failure!(error: NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_API_CODE, userInfo: ["message": "PAYMENT_ERROR".localized]))
                    }
                    
                }
            } else {
                if failure != nil {
                    failure!(error: NSError(domain: "mercadopago.sdk.mercadoPago.createMPPayment", code: NSURLErrorCannotDecodeContentData, userInfo: [NSLocalizedDescriptionKey : "No se ha podido procesar el pago".localized, NSLocalizedFailureReasonErrorKey : "No se ha podido procesar el pago".localized]))
                }
            }}, failure: failure)

    }
    
    
    internal class func openURL(url : String){
        let currentURL = NSURL(string: url)
        if (currentURL != nil && UIApplication.sharedApplication().canOpenURL(currentURL!)) {
            UIApplication.sharedApplication().openURL(currentURL!)
        }
    }
}

