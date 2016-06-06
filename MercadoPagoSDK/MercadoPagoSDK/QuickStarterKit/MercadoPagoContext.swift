//
//  MercadoPagoContext.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

public class MercadoPagoContext {
    
    static let sharedInstance = MercadoPagoContext()
    
    var public_key: String = ""
    
    var private_key: String = ""
    
    var base_url: String = ""

    var customer_uri: String = ""
    
    var merchant_access_token: String = ""
    
    //TODO : complete with default preference_uri
    var preference_uri: String = ""
    
    var payment_uri: String = ""
    
    var payment_key : String = ""
    
    public class var PUBLIC_KEY : String {
        return "public_key"
    }
    
    public class var PRIVATE_KEY : String {
        return "private_key"
    }

    public class func isAuthenticatedUser() -> Bool{
        return !sharedInstance.private_key.isEmpty
    }
    
    private init() {
    
        MercadoPagoUIViewController.loadFont(MercadoPago.DEFAULT_FONT_NAME)
    } //This prevents others from using the default '()' initializer for this class.

    
    public class func setPrivateKey(private_key : String){
        
        
        sharedInstance.private_key = private_key
      let   cardFront = CardFrontView()
      let  cardBack = CardBackView()
        
    }
    
    public class func setPublicKey(public_key : String){
        
       sharedInstance.public_key = public_key
       let cardFront = CardFrontView()
       let  cardBack = CardBackView()
        
    }
    
    /*
    private func registerAllCells(){
        
        //Register rows
        let offlinePaymentMethodNib = UINib(nibName: "OfflinePaymentMethodCell", bundle: self.bundle)
        self.checkoutTable.registerNib(offlinePaymentMethodNib, forCellReuseIdentifier: "offlinePaymentCell")
        let preferenceDescriptionCell = UINib(nibName: "PreferenceDescriptionTableViewCell", bundle: self.bundle)
        self.checkoutTable.registerNib(preferenceDescriptionCell, forCellReuseIdentifier: "preferenceDescriptionCell")
        let selectPaymentMethodCell = UINib(nibName: "SelectPaymentMethodCell", bundle: self.bundle)
        self.checkoutTable.registerNib(selectPaymentMethodCell, forCellReuseIdentifier: "selectPaymentMethodCell")
        let paymentDescriptionFooter = UINib(nibName: "PaymentDescriptionFooterTableViewCell", bundle: self.bundle)
        self.checkoutTable.registerNib(paymentDescriptionFooter, forCellReuseIdentifier: "paymentDescriptionFooter")
        let purchaseTermsAndConditions = UINib(nibName: "TermsAndConditionsViewCell", bundle: self.bundle)
        self.checkoutTable.registerNib(purchaseTermsAndConditions, forCellReuseIdentifier: "purchaseTermsAndConditions")
        let exitButtonCell = UINib(nibName: "ExitButtonTableViewCell", bundle: self.bundle)
        self.checkoutTable.registerNib(exitButtonCell, forCellReuseIdentifier: "exitButtonCell")
        
        // Payment ON rows
        let paymentSelectedCell = UINib(nibName: "PaymentMethodSelectedTableViewCell", bundle: self.bundle)
        self.checkoutTable.registerNib(paymentSelectedCell, forCellReuseIdentifier: "paymentSelectedCell")
        let installmentSelectionCell = UINib(nibName: "InstallmentSelectionTableViewCell", bundle: self.bundle)
        self.checkoutTable.registerNib(installmentSelectionCell, forCellReuseIdentifier: "installmentSelectionCell")
        
        self.checkoutTable.delegate = self
        self.checkoutTable.dataSource = self
        self.checkoutTable.separatorStyle = .None
    }
*/
    
    
    public class func setBaseURL(base_url : String){
        
        sharedInstance.base_url = base_url
        
    }
    
    public class func setCustomerURI(customer_uri : String){
        
        sharedInstance.customer_uri = customer_uri
        
    }
    
    public class func setPreferenceURI(preference_uri : String){
        
        sharedInstance.preference_uri = preference_uri
        
    }
    
    public class func setMerchantAccessToken(merchant_access_token : String){
        
        sharedInstance.merchant_access_token = merchant_access_token
        
    }
    
    public class func merchantAccessToken() -> String {
        
        return sharedInstance.merchant_access_token
        
    }
    

    public class func publicKey() -> String {
        
        return sharedInstance.public_key
        
    }
    
    
    public class func privateKey() -> String {
        
        return sharedInstance.private_key
        
    }
    
    public class func baseURL() -> String {
        
        return sharedInstance.base_url
        
    }
    public class func customerURI() -> String {
        
        return sharedInstance.customer_uri
        
    }
    
    public class func preferenceURI() -> String {
        
        return sharedInstance.preference_uri
        
    }
    
    public class func paymentURI() -> String {
        
        return sharedInstance.payment_uri
        
    }
    
    public class func paymentKey() -> String {
        if sharedInstance.payment_key == "" {
            sharedInstance.payment_key = String(arc4random()) + String(NSDate().timeIntervalSince1970)
        }
        return sharedInstance.payment_key
    }
    
    public class func clearPaymentKey(){
        sharedInstance.payment_key = ""
    }
    
    public class func keyType() -> String{
        if(MercadoPagoContext.isAuthenticatedUser()){
            return MercadoPagoContext.PRIVATE_KEY
        }else{
            return MercadoPagoContext.PUBLIC_KEY
        }
    }
    
    public class func keyValue(forcingPublic : Bool = true) -> String{
        if forcingPublic {
            return MercadoPagoContext.publicKey()
        }
        if(MercadoPagoContext.isAuthenticatedUser()){
            return MercadoPagoContext.privateKey()
        }else{
            return MercadoPagoContext.publicKey()
        }
    }
    
}