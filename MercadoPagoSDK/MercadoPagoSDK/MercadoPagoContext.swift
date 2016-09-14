//
//  MercadoPagoContext.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit
import MercadoPagoTracker

public class MercadoPagoContext : NSObject, MPTrackerDelegate {
    
    static let sharedInstance = MercadoPagoContext()
    
    var public_key: String = ""
    
    var private_key: String = ""
    
    var base_url: String = ""

    var customer_uri: String = ""
    
    var merchant_access_token: String = ""
    
    var initialFlavor: Flavor?

    var preference_uri: String = ""
    
    var payment_uri: String = ""
    
    var payment_key : String = ""
    
    var site : Site!
    
    var language : String!
    
    var termsAndConditionsSite : String!

    
    var currency : Currency!
    
    public class var PUBLIC_KEY : String {
        return "public_key"
    }
    
    public class var PRIVATE_KEY : String {
        return "private_key"
    }

    public class func isAuthenticatedUser() -> Bool{
        return !sharedInstance.private_key.isEmpty
    }

   public func flavor() -> Flavor!{
    if (initialFlavor == nil){
        return Flavor.Flavor_3
    }else{
        return initialFlavor
    }
    
    }
    public func framework() -> String!{
        return  "iOS"
    }
    public func sdkVersion() -> String!{
        return "1.0.0"
    }
 
    static let siteIdsSettings : [String : NSDictionary] = [
        "MLA" : ["language" : "es", "currency" : "ARS","termsconditions" : "https://www.mercadopago.com.ar/ayuda/terminos-y-condiciones_299"],
        "MLB" : ["language" : "pt", "currency" : "BRL","termsconditions" : "https://www.mercadopago.com.br/ajuda/termos-e-condicoes_300"],
        "MLC" : ["language" : "es", "currency" : "CLP","termsconditions" : "https://www.mercadopago.com.co/ayuda/terminos-y-condiciones_299"],
        "MLM" : ["language" : "es", "currency" : "MXN","termsconditions" : "https://www.mercadopago.com.mx/ayuda/terminos-y-condiciones_715"]
     ]

    public enum Site : String {
        case MLA = "MLA"
        case MLB = "MLB"
        case MLM = "MLM"
        case MLV = "MLV"
        case MLU = "MLU"
        case MPE = "MPE"
        case MLC = "MLC"
        case MCO = "MCO"
    }
    
    
    
    public func siteId() -> String! {
        return site.rawValue
    }
    
    private func setSite(site : Site) {
        let siteConfig = MercadoPagoContext.siteIdsSettings[site.rawValue]
        if siteConfig != nil {
            self.site = site
            self.language = siteConfig!["language"] as! String
            self.termsAndConditionsSite = siteConfig!["termsconditions"] as! String
            let currency = CurrenciesUtil.getCurrencyFor(siteConfig!["currency"] as? String)
            if currency != nil {
                self.currency = currency!
            }
        }
    }

    public class func setSite(site : Site) {
        MercadoPagoContext.sharedInstance.setSite(site)
    }
    
    public class func setSiteID(siteId : String) {
        let site = Site(rawValue: siteId)
        if site != nil {
            MercadoPagoContext.setSite(site!)
        }
    }
    
    public static func getLanguage() -> String {
        return sharedInstance.language
    }
    
    public static func getTermsAndConditionsSite() -> String {
        return sharedInstance.termsAndConditionsSite
    }
    
    public static func getCurrency() -> Currency {
        return sharedInstance.currency
    }
    
    public func publicKey() -> String!{
        return self.public_key
    }
    
    
    private static var primaryColor : UIColor = UIColor.mpDefaultColor()

    
    private static var complementaryColor : UIColor = UIColor.blueMercadoPago()
    private static var textColor : UIColor = UIColor.whiteColor()
    
    public static func setupPrimaryColor(color: UIColor, complementaryColor: UIColor? = nil){
        MercadoPagoContext.primaryColor = color
        if (complementaryColor != nil){
            MercadoPagoContext.setupComplementaryColor(complementaryColor!)
        }else{
            if (color == UIColor.mpDefaultColor()){
                MercadoPagoContext.setupComplementaryColor(UIColor.blueMercadoPago())
            }else{
                MercadoPagoContext.setupComplementaryColor(color.lighter())
            }
        }
    }
    public static func setupComplementaryColor(color: UIColor){
        MercadoPagoContext.complementaryColor = color
    }
    
    internal static func getPrimaryColor() -> UIColor {
        return primaryColor
    }
    
    internal static func getComplementaryColor() -> UIColor {
        return complementaryColor
    }
    
    internal static func getTextColor() -> UIColor {
        return textColor
    }
    public static func setDarkTextColor(){
        textColor = UIColor.blackColor()
    }
    public static func setLightTextColor(){
        textColor = UIColor.whiteColor()
    }
    
    
    private override init() {
        super.init()
        MercadoPagoUIViewController.loadFont(MercadoPago.DEFAULT_FONT_NAME)
        self.setSite(Site.MLA)
    }
    
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
    
    public class func initFlavor1(){
        if (MercadoPagoContext.sharedInstance.initialFlavor != nil){
            return
        }
        MercadoPagoContext.sharedInstance.initialFlavor = Flavor.Flavor_1
    }
    public class func initFlavor2(){
        if (MercadoPagoContext.sharedInstance.initialFlavor != nil){
            return
        }
        MercadoPagoContext.sharedInstance.initialFlavor = Flavor.Flavor_2
    }
    public class func initFlavor3(){
        if (MercadoPagoContext.sharedInstance.initialFlavor != nil){
            return
        }
        MercadoPagoContext.sharedInstance.initialFlavor = Flavor.Flavor_3
    }
    
    
    public class func setBaseURL(base_url : String){
        
        sharedInstance.base_url = base_url
        
    }
    
    public class func setCustomerURI(customer_uri : String){
        
        sharedInstance.customer_uri = customer_uri
        
    }
    
    public class func setPreferenceURI(preference_uri : String){
        
        sharedInstance.preference_uri = preference_uri
        
    }
    
    public class func setPaymentURI(payment_uri : String){
        
        sharedInstance.payment_uri = payment_uri
        
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
    
    public class func isCustomerInfoAvailable() -> Bool {
        return (self.sharedInstance.base_url.characters.count > 0 && self.sharedInstance.customer_uri.characters.count > 0 && self.sharedInstance.merchant_access_token.characters.count > 0)
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


