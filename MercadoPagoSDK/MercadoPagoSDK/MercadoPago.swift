
//
//  MercadoPago.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit



@objc open class MercadoPago : NSObject, UIAlertViewDelegate {
    
    
    open static let DEFAULT_FONT_NAME = ".SFUIDisplay-Regular"
    
    open class var PUBLIC_KEY : String {
        return "public_key"
    }
    open class var PRIVATE_KEY : String {
        return "private_key"
    }
    
    open class var ERROR_KEY_CODE : Int {
        return -1
    }
    
    open class var ERROR_API_CODE : Int {
        return -2
    }
    
    open class var ERROR_UNKNOWN_CODE : Int {
        return -3
    }
    
    open class var ERROR_NOT_INSTALLMENTS_FOUND : Int {
        return -4
    }
    
    open class var ERROR_PAYMENT : Int {
        return -4
    }
    
    open class var ERROR_INSTRUCTIONS : Int {
        return -4
    }
    
    

    
    open func publicKey() -> String!{
        return self.pk
    }
    
    let BIN_LENGTH : Int = 6
    
    static let MP_ALPHA_ENV = "/gamma"
    static var MP_TEST_ENV = "/beta"
    static let MP_PROD_ENV = "/v1"
    static let API_VERSION = "1.3.X"

    static let MP_ENVIROMENT = MP_TEST_ENV  + "/checkout"
    
    static let MP_OP_ENVIROMENT = "/v1"
    
    static let MP_ALPHA_API_BASE_URL : String =  "http://api.mp.internal.ml.com"
    static let MP_API_BASE_URL_PROD : String =  "https://api.mercadopago.com"
    
    static let MP_API_BASE_URL : String =  MP_API_BASE_URL_PROD

    static let MP_CUSTOMER_URI = "/customers?preference_id="
    static let MP_PAYMENTS_URI = MP_ENVIROMENT + "/payments"
    
    open var privateKey : String?
    open var pk : String!
    
    open var paymentMethodId : String?
    open var paymentTypeId : String?
    
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
    

    open func createNewCardToken(_ cardToken : CardToken, success: @escaping (_ token : Token?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        
        if self.publicKey() != nil {
            cardToken.device = Device()
            let service : GatewayService = GatewayService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getToken(public_key: self.publicKey(), cardToken: cardToken, success: {(jsonResult: AnyObject?) -> Void in
                var token : Token? = nil
                if let tokenDic = jsonResult as? NSDictionary {
                    if tokenDic["error"] == nil {
                        token = Token.fromJSON(tokenDic)
                        success(token)
                    } else {
                        if failure != nil {
                            failure!(NSError(domain: "mercadopago.sdk.createNewCardToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as! [AnyHashable: Any]))
                        }
                    }
                }
                }, failure: failure)
        } else {
            if failure != nil {
                failure!(NSError(domain: "mercadopago.sdk.createNewCardToken", code: MercadoPago.ERROR_KEY_CODE, userInfo: ["message": "Unsupported key type for this method"]))
            }
        }
    }
    
    open func createToken(_ savedCardToken : SavedCardToken, success: @escaping (_ token : Token?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        
        if self.publicKey() != nil {
            savedCardToken.device = Device()
            
            let service : GatewayService = GatewayService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getToken(public_key: self.publicKey(), savedCardToken: savedCardToken, success: {(jsonResult: AnyObject?) -> Void in
                var token : Token? = nil
                if let tokenDic = jsonResult as? NSDictionary {
                    if tokenDic["error"] == nil {
                        token = Token.fromJSON(tokenDic)
                        success(token)
                    } else {
                        if failure != nil {
                            failure!(NSError(domain: "mercadopago.sdk.createToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as! [AnyHashable: Any]))
                        }
                    }
                }
                }, failure: failure)
        } else {
            if failure != nil {
                failure!(NSError(domain: "mercadopago.sdk.createToken", code: MercadoPago.ERROR_KEY_CODE, userInfo: ["message": "Unsupported key type for this method"]))
            }
        }
    }
    
    open func getIdentificationTypes(_ success: @escaping (_ identificationTypes: [IdentificationType]?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        
        if self.publicKey() != nil {
            let service : IdentificationService = IdentificationService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getIdentificationTypes(public_key: self.publicKey(), success: {(jsonResult: AnyObject?) -> Void in
                
                if let error = jsonResult as? NSDictionary {
                    if (error["status"]! as? Int) == 404 {
                        if failure != nil {
                            failure!(NSError(domain: "mercadopago.sdk.getIdentificationTypes", code: MercadoPago.ERROR_API_CODE, userInfo: error as! [AnyHashable: Any]))
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
        } else {
            if failure != nil {
                failure!(NSError(domain: "mercadopago.sdk.getIdentificationTypes", code: MercadoPago.ERROR_KEY_CODE, userInfo: ["message": "Unsupported key type for this method"]))
            }
        }
    }
    
    @available(*, deprecated: 2.0)
    open func getInstallments(_ bin: String, amount: Double, issuerId: NSNumber?, paymentTypeId: String, success: @escaping (_ installments: [Installment]?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        if self.publicKey() != nil {
            let service : PaymentService = PaymentService(baseURL: MercadoPago.MP_API_BASE_URL)
             service.getInstallments(public_key: self.publicKey(), bin: bin, amount: amount, issuer_id: issuerId, payment_method_id: paymentTypeId, success: success, failure: failure)
        
        }
    }
    
    open func getIssuers(_ paymentMethodId : String, success: @escaping (_ issuers: [Issuer]?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        
        if self.publicKey() != nil {
            let service : PaymentService = PaymentService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getIssuers(public_key: self.publicKey()!, payment_method_id: paymentMethodId, success: {(jsonResult: AnyObject?) -> Void in
                if let errorDic = jsonResult as? NSDictionary {
                    if errorDic["error"] != nil {
                        if failure != nil {
                            failure!(NSError(domain: "mercadopago.sdk.getIssuers", code: MercadoPago.ERROR_API_CODE, userInfo: errorDic as! [AnyHashable: Any]))
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
        } else {
            if failure != nil {
                failure!(NSError(domain: "mercadopago.sdk.getIssuers", code: MercadoPago.ERROR_KEY_CODE, userInfo: ["message": "Unsupported key type for this method"]))
            }
        }
    }
    
    open func getPromos(_ success: @escaping (_ promos: [Promo]?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        // TODO: Está hecho para MLA fijo porque va a cambiar la URL para que dependa de una API y una public key
        let service : PromosService = PromosService(baseURL: MercadoPago.MP_API_BASE_URL)
        service.getPromos(public_key: self.publicKey()!, success: { (jsonResult) -> Void in
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
    
    open class func isCardPaymentType(_ paymentTypeId: String) -> Bool {
        if paymentTypeId == "credit_card" || paymentTypeId == "debit_card" || paymentTypeId == "prepaid_card" {
            return true
        }
        return false
    }
    
    open class func getBundle() -> Bundle? {
       return Bundle(for:MercadoPago.self)
    }
    
    open class func getImage(_ name: String?) -> UIImage? {
        if name == nil || (name?.isEmpty)! {
            return nil
        }
        
        let bundle = getBundle()

        if (UIDevice.current.systemVersion as NSString).compare("8.0", options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending {
            var nameArr = name!.characters.split {$0 == "."}.map(String.init)
            let imageExtension : String = nameArr[1]
            let filePath = bundle?.path(forResource: name, ofType: imageExtension)
            if filePath != nil {
                return UIImage(contentsOfFile: filePath!)
            } else {
                return nil
            }
        }
        return UIImage(named:name!, in: bundle, compatibleWith:nil)
    
    }
    
    open class func screenBoundsFixedToPortraitOrientation() -> CGRect {
        let screenSize : CGRect = UIScreen.main.bounds
        if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 && UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            return CGRect(x: 0.0, y: 0.0, width: screenSize.height, height: screenSize.width)
        }
        return screenSize
    }
    
    open class func showAlertViewWithError(_ error: NSError?, nav: UINavigationController?) {
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
        alert.addButton(withTitle: "OK")
        alert.show()
    }
    
    open func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            MercadoPago.temporalNav?.popViewController(animated: true)
        }
    }
    
    open class func getImageFor(searchItem : PaymentMethodSearchItem) -> UIImage?{
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethodSearch", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        guard let itemSelected = dictPM?.value(forKey: searchItem.idPaymentMethodSearchItem) as? NSDictionary else {
            return nil
        }
        
            return MercadoPago.getImage(itemSelected.object(forKey: "image_name") as! String?)
        
    }
    
    open class func getImageFor(cardInformation : CardInformation) -> UIImage?{
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethodSearch", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        guard let itemSelected = dictPM?.value(forKey: cardInformation.getPaymentMethodId()) as? NSDictionary else {
            return nil
        }
        
        return MercadoPago.getImage(itemSelected.object(forKey: "image_name") as! String?)
        
    }
    
    
    open class func getImageFor(_ paymentMethod : PaymentMethod, forCell: Bool? = false) -> UIImage?{
        if (forCell == true) {
            return MercadoPago.getImage(paymentMethod._id.lowercased())
        }else{
            return MercadoPago.getImage("icoTc_"+paymentMethod._id.lowercased())
        }

    }
    
    open class func getColorFor(_ paymentMethod : PaymentMethod) -> UIColor?{
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        let pmConfig = dictPM?.value(forKey: paymentMethod._id) as! NSDictionary
        let stringColor = pmConfig.value(forKey: "first_color") as! String
        //let intColor = Int(stringColor)
        return UIColor(netHex:Int(stringColor, radix: 16)!)
        
    }
    
    open class func getLabelMaskFor(_ paymentMethod : PaymentMethod, forCell: Bool? = false) -> String?{
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        let pmConfig = dictPM?.value(forKey: paymentMethod._id) as! NSDictionary
        let etMask = pmConfig.value(forKey: "label_mask") as! String
        
        return etMask
    }
    
    open class func getEditTextMaskFor(_ paymentMethod : PaymentMethod, forCell: Bool? = false) -> String?{
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        let pmConfig = dictPM?.value(forKey: paymentMethod._id) as! NSDictionary
        let etMask = pmConfig.value(forKey: "editText_mask") as! String

        return etMask
    }
    
    
    open class func getFontColorFor(_ paymentMethod : PaymentMethod) -> UIColor?{
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        let pmConfig = dictPM?.value(forKey: paymentMethod._id) as! NSDictionary
        let stringColor = pmConfig.value(forKey: "font_color") as! String
        //let intColor = Int(stringColor)
        return UIColor(netHex:Int(stringColor, radix: 16)!)
        
    }
    
    open class func getEditingFontColorFor(_ paymentMethod : PaymentMethod) -> UIColor?{
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        let pmConfig = dictPM?.value(forKey: paymentMethod._id) as! NSDictionary
        let stringColor = pmConfig.value(forKey: "editing_font_color") as! String
        //let intColor = Int(stringColor)
        return UIColor(netHex:Int(stringColor, radix: 16)!)
        
    }
    
    open class func createMPPayment(_ email : String, preferenceId : String, paymentMethod: PaymentMethod, token : Token? = nil, installments: Int = 1, issuer: Issuer? = nil, success: @escaping (_ payment: Payment) -> Void, failure: ((_ error: NSError) -> Void)?) {
    
        var issuerId = ""
        if issuer != nil {
            issuerId = String(issuer!._id!.intValue)
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
                        failure!(NSError(domain: "mercadopago.sdk.mercadoPago.createMPPayment", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey : "No se ha podido procesar el pago".localized, NSLocalizedFailureReasonErrorKey : paymentDic["error"] as! String]))
                    }
                } else {
                    if paymentDic.allKeys.count > 0 {
                        payment = Payment.fromJSON(paymentDic)
                        success(payment!)
                        // Clear payment key after post payment success
                        MercadoPagoContext.clearPaymentKey()
                    } else {
                        failure!(NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_API_CODE, userInfo: ["message": "PAYMENT_ERROR".localized]))
                    }
                    
                }
            } else {
                if failure != nil {
                    failure!(NSError(domain: "mercadopago.sdk.mercadoPago.createMPPayment", code: NSURLErrorCannotDecodeContentData, userInfo: [NSLocalizedDescriptionKey : "No se ha podido procesar el pago".localized, NSLocalizedFailureReasonErrorKey : "No se ha podido procesar el pago".localized]))
                }
            }}, failure: failure)

    }
    
    
    internal class func openURL(_ url : String){
        let currentURL = URL(string: url)
        if (currentURL != nil && UIApplication.shared.canOpenURL(currentURL!)) {
            UIApplication.shared.openURL(currentURL!)
        }
    }
}

