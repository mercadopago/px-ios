
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
        return "access_token"
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
    
    
    open class func isCardPaymentType(_ paymentTypeId: String) -> Bool {
        if paymentTypeId == "credit_card" || paymentTypeId == "debit_card" || paymentTypeId == "prepaid_card" {
            return true
        }
        return false
    }
    
    open class func getBundle() -> Bundle? {
       return Bundle(for:MercadoPago.self)
    }
    

    open class func getImage(_ name: String?, bundle: Bundle) -> UIImage? {
        if name == nil || (name?.isEmpty)! {
            return nil
        }

        if (UIDevice.current.systemVersion as NSString).compare("8.0", options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending {
            var nameArr = name!.characters.split {$0 == "."}.map(String.init)
            let imageExtension : String = nameArr[1]
            let filePath = bundle.path(forResource: name, ofType: imageExtension)
            if filePath != nil {
                return UIImage(contentsOfFile: filePath!)
            } else {
                return nil
            }
        }
        return UIImage(named:name!, in: bundle, compatibleWith:nil)
    
    }
    
    open class func getImage(_ name: String?) -> UIImage? {
        if name == nil || (name?.isEmpty)! {
            return nil
        }
        if name!.hasPrefix("MPSDK_") {
            if let image = MercadoPago.getImage(name, bundle: Bundle.main){
                return image
            } else {
                return MercadoPago.getImage(name, bundle: MercadoPago.getBundle()!)
            }
        }
        return MercadoPago.getImage(name, bundle: MercadoPago.getBundle()!)
        
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
    
    open class func getImageForPaymentMethod(withDescription : String, defaultColor : Bool = false) -> UIImage?{
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethodSearch", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        var description = withDescription
        
        if defaultColor {
            description = description+"Azul"
        } else if (PaymentType.allPaymentIDs.contains(description) || description == "cards") {
            description = UIColor.primaryColor() == UIColor.px_blueMercadoPago() ? description+"Azul" : description
        }
        
        guard let itemSelected = dictPM?.value(forKey: description) as? NSDictionary else {
            return nil
        }
        
        let image = MercadoPago.getImage(itemSelected.object(forKey: "image_name") as! String?)
        
        if description == "credit_card" || description == "account_money" || description == "prepaid_card" || description == "debit_card" || description == "bank_transfer" || description == "ticket" || description == "cards" {
            return image?.imageWithOverlayTint(tintColor: UIColor.primaryColor())
        } else {
            return image
        }
        
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
    
    open class func getColorFor(_ paymentMethod : PaymentMethod, settings: [Setting]?) -> UIColor {
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
       
        
        if let pmConfig = dictPM?.value(forKey: paymentMethod._id) as? NSDictionary{
            if let stringColor = pmConfig.value(forKey: "first_color") as? String{
                return UIColor.fromHex(stringColor)
            }else{
                return UIColor.cardDefaultColor()
            }
        } else if let setting = settings?[0] {
            if let pmConfig = dictPM?.value(forKey: paymentMethod._id + "_" + String(setting.cardNumber.length)) as? NSDictionary{
                if let stringColor = pmConfig.value(forKey: "first_color") as? String{
                    return UIColor.fromHex(stringColor)
                }else{
                    return UIColor.cardDefaultColor()
                }
            }
        }
            return UIColor.cardDefaultColor()
        
    }
    
    open class func getLabelMaskFor(_ paymentMethod : PaymentMethod, settings: [Setting]?, forCell: Bool? = false) -> String{
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        let defaultMask = "XXXX XXXX XXXX XXXX"
        
        if let pmConfig = dictPM?.value(forKey: paymentMethod._id) as? NSDictionary{
            let etMask = pmConfig.value(forKey: "label_mask") as? String
            return etMask ?? defaultMask
        } else if let setting = settings?[0]{
            if let pmConfig = dictPM?.value(forKey: paymentMethod._id + "_" + String(setting.cardNumber.length)) as? NSDictionary{
                let etMask = pmConfig.value(forKey: "label_mask") as? String
                return etMask ?? defaultMask
            }
        }
        return defaultMask
    }
    
    open class func getEditTextMaskFor(_ paymentMethod : PaymentMethod, settings: [Setting]?, forCell: Bool? = false) -> String{
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        
        let defaultMask = "XXXX XXXX XXXX XXXX"
        
        if let pmConfig = dictPM?.value(forKey: paymentMethod._id) as? NSDictionary{
            let etMask = pmConfig.value(forKey: "editText_mask") as? String
            return etMask ?? defaultMask
        } else if let setting = settings?[0]{
            if let pmConfig = dictPM?.value(forKey: paymentMethod._id + "_" + String(setting.cardNumber.length)) as? NSDictionary{
                let etMask = pmConfig.value(forKey: "editText_mask") as? String
                return etMask ?? defaultMask
            }
        }
        return defaultMask
    }
    
    
    open class func getFontColorFor(_ paymentMethod : PaymentMethod, settings: [Setting]?) -> UIColor{
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        let defaultColor = MPLabel.defaultColorText
    

        if let pmConfig = dictPM?.value(forKey: paymentMethod._id) as? NSDictionary{
            if let stringColor = pmConfig.value(forKey: "font_color") as? String{
                return UIColor.fromHex(stringColor)
            }else{
                return defaultColor
            }
        } else if let setting = settings?[0]{
            if let pmConfig = dictPM?.value(forKey: paymentMethod._id + "_" + String(setting.cardNumber.length)) as? NSDictionary{
                if let stringColor = pmConfig.value(forKey: "font_color") as? String{
                    return UIColor.fromHex(stringColor)
                }else{
                    return defaultColor
                }            }
        }
        return defaultColor

        
        
    }
    
    open class func getEditingFontColorFor(_ paymentMethod : PaymentMethod, settings: [Setting]?) -> UIColor{
        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethod", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        let defaultColor = MPLabel.highlightedColorText
        
        
        if let pmConfig = dictPM?.value(forKey: paymentMethod._id) as? NSDictionary{
            if let stringColor = pmConfig.value(forKey: "editing_font_color") as? String{
                return UIColor.fromHex(stringColor)
            }else{
                return defaultColor
            }
        } else if let setting = settings?[0]{
            if let pmConfig = dictPM?.value(forKey: paymentMethod._id + "_" + String(setting.cardNumber.length)) as? NSDictionary{
                if let stringColor = pmConfig.value(forKey: "editing_font_color") as? String{
                    return UIColor.fromHex(stringColor)
                }else{
                    return defaultColor
                }
            }
        }
        return defaultColor
        
        
        
    }
    
    internal class func openURL(_ url : String){
        let currentURL = URL(string: url)
        if (currentURL != nil && UIApplication.shared.canOpenURL(currentURL!)) {
            UIApplication.shared.openURL(currentURL!)
        }
    }
}

