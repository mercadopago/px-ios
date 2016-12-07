//
//  MercadoPagoContext.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit


open class MercadoPagoContext : NSObject, MPTrackerDelegate {
    
    static let sharedInstance = MercadoPagoContext()
    
    var trackListener : MPTrackListener?
    
    var public_key: String = ""
    
    var payer_access_token: String = ""
    
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

    var account_money_available = false
    
    var currency : Currency!
    
    var display_default_loading = true
    
    open class var PUBLIC_KEY : String {
        return "public_key"
    }
    
    open class var PRIVATE_KEY : String {
        return "private_key"
    }

    open class func isAuthenticatedUser() -> Bool{
        return !sharedInstance.payer_access_token.isEmpty
    }

    public func flavor() -> Flavor!{
        if (initialFlavor == nil){
        return Flavor.Flavor_3
    }else{
                return initialFlavor
        }
    
    }
    
    open func framework() -> String!{
        return  "iOS"
    }
    open func sdkVersion() -> String!{
        return "2.2.0"
    }
 
    static let siteIdsSettings : [String : NSDictionary] = [
        "MLA" : ["language" : "es", "currency" : "ARS","termsconditions" : "https://www.mercadopago.com.ar/ayuda/terminos-y-condiciones_299"],
        "MLB" : ["language" : "pt", "currency" : "BRL","termsconditions" : "https://www.mercadopago.com.br/ajuda/termos-e-condicoes_300"],
        "MLC" : ["language" : "es", "currency" : "CLP","termsconditions" : "https://www.mercadopago.com.co/ayuda/terminos-y-condiciones_299"],
        "MLM" : ["language" : "es-MX", "currency" : "MXN","termsconditions" : "https://www.mercadopago.com.mx/ayuda/terminos-y-condiciones_715"]
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
    
    
    
    open func siteId() -> String! {
        return site.rawValue
    }
    
    fileprivate func setSite(_ site : Site) {
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

    open class func setSite(_ site : Site) {
        MercadoPagoContext.sharedInstance.setSite(site)
    }
    open class func getSite() -> String{
        return MercadoPagoContext.sharedInstance.site.rawValue
    }
    
    open class func setSiteID(_ siteId : String) {
        let site = Site(rawValue: siteId)
        if site != nil {
            MercadoPagoContext.setSite(site!)
        }
    }
    
    open class func setTrack(listener : MPTrackListener) {
        MercadoPagoContext.sharedInstance.trackListener = listener
    }
    
    open static func getTrackListener() -> MPTrackListener? {
        return sharedInstance.trackListener
    }
    
    open static func getLanguage() -> String {
        return sharedInstance.language
    }
    
    open static func getTermsAndConditionsSite() -> String {
        return sharedInstance.termsAndConditionsSite
    }
    
    open static func getCurrency() -> Currency {
        return sharedInstance.currency
    }
    
    open func publicKey() -> String!{
        return self.public_key
    }
    
    fileprivate static var primaryColor : UIColor = UIColor.mpDefaultColor()

    
    fileprivate static var complementaryColor : UIColor = UIColor.blueMercadoPago()
    fileprivate static var textColor : UIColor = UIColor.white()
    
    open static func setupPrimaryColor(_ color: UIColor, complementaryColor: UIColor? = nil){
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
    open static func setupComplementaryColor(_ color: UIColor){
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
    open static func setDarkTextColor(){
        textColor = UIColor.black
    }
    open static func setLightTextColor(){
        textColor = UIColor.white()
    }
    
    
    fileprivate override init() {
        super.init()
        MercadoPagoUIViewController.loadFont(MercadoPago.DEFAULT_FONT_NAME)
        self.setSite(Site.MLA)
    }
    
    open class func setPayerAccessToken(_ payerAccessToken : String){
        
        
        sharedInstance.payer_access_token = payerAccessToken
      _ = CardFrontView()
      _ = CardBackView()
        
    }
    
    open class func setPublicKey(_ public_key : String){
        
       sharedInstance.public_key = public_key
       _ = CardFrontView()
       _ = CardBackView()
        
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
   
    
    open class func setBaseURL(_ base_url : String){
        
        sharedInstance.base_url = base_url
        
    }
    
    open class func setCustomerURI(_ customer_uri : String){
        
        sharedInstance.customer_uri = customer_uri
        
    }
    
    open class func setPreferenceURI(_ preference_uri : String){
        
        sharedInstance.preference_uri = preference_uri
        
    }
    
    open class func setPaymentURI(_ payment_uri : String){
        
        sharedInstance.payment_uri = payment_uri
        
    }
    
    open class func setMerchantAccessToken(_ merchant_access_token : String){
        
        sharedInstance.merchant_access_token = merchant_access_token
        
    }
    
    open class func setAccountMoneyAvailable(accountMoneyAvailable : Bool) {
        sharedInstance.account_money_available = accountMoneyAvailable
    }
    
    
    open class func setDisplayDefaultLoading(flag : Bool){
        sharedInstance.display_default_loading = flag
    }
    
    open class func merchantAccessToken() -> String {
        return sharedInstance.merchant_access_token
    }
    

    open class func publicKey() -> String {
        
        return sharedInstance.public_key
        
    }
    
    
    open class func payerAccessToken() -> String {
        
        return sharedInstance.payer_access_token
        
    }
    
    open class func accountMoneyAvailable() -> Bool {
        return sharedInstance.account_money_available
    }
    
    open class func baseURL() -> String {
        
        return sharedInstance.base_url
        
    }
    open class func customerURI() -> String {
        
        return sharedInstance.customer_uri
        
    }
    
    open class func preferenceURI() -> String {
        
        return sharedInstance.preference_uri
        
    }
    
    open class func paymentURI() -> String {
        
        return sharedInstance.payment_uri
        
    }
    
    open class func shouldDisplayDefaultLoading() -> Bool {
        return sharedInstance.display_default_loading
    }
    

    
    
    
    open class func isCustomerInfoAvailable() -> Bool {
        return (self.sharedInstance.base_url.characters.count > 0 && self.sharedInstance.customer_uri.characters.count > 0 && self.sharedInstance.merchant_access_token.characters.count > 0)
    }
    
    open class func paymentKey() -> String {
        if sharedInstance.payment_key == "" {
            sharedInstance.payment_key = String(arc4random()) + String(Date().timeIntervalSince1970)
        }
        return sharedInstance.payment_key
    }
    
    open class func clearPaymentKey(){
        sharedInstance.payment_key = ""
    }
    
    open class func keyType() -> String{
        if(MercadoPagoContext.isAuthenticatedUser()){
            return MercadoPagoContext.PRIVATE_KEY
        }else{
            return MercadoPagoContext.PUBLIC_KEY
        }
    }
    
    open class func keyValue(_ forcingPublic : Bool = true) -> String{
        if forcingPublic {
            return MercadoPagoContext.publicKey()
        }
        if(MercadoPagoContext.isAuthenticatedUser()){
            return MercadoPagoContext.payerAccessToken()
        }else{
            return MercadoPagoContext.publicKey()
        }
    }
    
}


