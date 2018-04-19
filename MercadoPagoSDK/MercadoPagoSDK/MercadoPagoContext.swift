//
//  MercadoPagoContext.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

@objcMembers open class MercadoPagoContext: NSObject {

    static let sharedInstance = MercadoPagoContext()

    var public_key: String = ""

    var payer_access_token: String = ""

    var merchant_access_token: String = ""

    var payment_key: String = ""

    var site: Site!

    var termsAndConditionsSite: String!

    var account_money_available = false

    var currency: Currency!

    // TODO: Deprecate/Delete in Q2. - 2018
    var display_default_loading = true

    var language: String = NSLocale.preferredLanguages[0]

    static let kSdkVersion = "sdk_version"

    open class func isAuthenticatedUser() -> Bool {
        return !sharedInstance.payer_access_token.isEmpty
    }
    static var mpxPublicKey: String {return sharedInstance.publicKey()}
    static var mpxCheckoutVersion: String {return sharedInstance.sdkVersion()}
    static var mpxPlatform: String {return sharedInstance.framework()}
    static var mpxSiteId: String {return sharedInstance.siteId()}
    static var platformType: String {return "native/ios"}

    open func framework() -> String! {
        return  "iOS"
    }

    open func sdkVersion() -> String {
        let sdkVersion: String = Utils.getSetting(identifier: MercadoPagoContext.kSdkVersion) ?? ""
        return sdkVersion
    }

    static let siteIdsSettings: [String: NSDictionary] = [
        //Argentina
        "MLA": ["language": "es", "currency": "ARS", "termsconditions": "https://www.mercadopago.com.ar/ayuda/terminos-y-condiciones_299"],
        //Brasil
        "MLB": ["language": "pt", "currency": "BRL", "termsconditions": "https://www.mercadopago.com.br/ajuda/termos-e-condicoes_300"],
        //Chile

        "MLC": ["language": "es", "currency": "CLP", "termsconditions": "https://www.mercadopago.cl/ayuda/terminos-y-condiciones_299"],
        //Mexico
        "MLM": ["language": "es-MX", "currency": "MXN", "termsconditions": "https://www.mercadopago.com.mx/ayuda/terminos-y-condiciones_715"],
        //Peru
        "MPE": ["language": "es", "currency": "PEN", "termsconditions": "https://www.mercadopago.com.pe/ayuda/terminos-condiciones-uso_2483"],
        //Uruguay
        "MLU": ["language": "es", "currency": "UYU", "termsconditions": "https://www.mercadopago.com.uy/ayuda/terminos-y-condiciones-uy_2834"],
        //Colombia
        "MCO": ["language": "es-CO", "currency": "COP", "termsconditions": "https://www.mercadopago.com.co/ayuda/terminos-y-condiciones_299"],
        //Venezuela
        "MLV": ["language": "es", "currency": "VEF", "termsconditions": "https://www.mercadopago.com.ve/ayuda/terminos-y-condiciones_299"]
    ]

    public enum Site: String {
        case MLA
        case MLB
        case MLM
        case MLV
        case MLU
        case MPE
        case MLC
        case MCO
    }

    open func siteId() -> String! {
        return site.rawValue
    }

    fileprivate func setSite(_ site: Site) {
        let siteConfig = MercadoPagoContext.siteIdsSettings[site.rawValue]
        if siteConfig != nil {
            self.site = site
            self.termsAndConditionsSite = siteConfig!["termsconditions"] as? String ?? ""
            let currency = CurrenciesUtil.getCurrencyFor(siteConfig!["currency"] as? String)
            if currency != nil {
                self.currency = currency!
            }
        }
    }

    open class func setSite(_ site: Site) {
        MercadoPagoContext.sharedInstance.setSite(site)
    }

    open class func getSite() -> String {
        return MercadoPagoContext.sharedInstance.site.rawValue
    }

    open class func setSiteID(_ siteId: String) {
        let site = Site(rawValue: siteId)
        if site != nil {
            MercadoPagoContext.setSite(site!)
        }
    }
    open static func setLanguage(language: Languages) {
        sharedInstance.language = language.langPrefix()
    }

    open static func setLanguage(string: String) {
        sharedInstance.language = string
    }

    open static func getLanguage() -> String {
        return sharedInstance.language
    }

    open static func getLocalizedID() -> String {
        let bundle = MercadoPago.getBundle() ?? Bundle.main

        let currentLanguage = MercadoPagoContext.getLanguage()
        let currentLanguageSeparated = currentLanguage.components(separatedBy: "-")[0]
        if bundle.path(forResource: currentLanguage, ofType: "lproj") != nil {
            return currentLanguage
        } else if (bundle.path(forResource: currentLanguageSeparated, ofType: "lproj") != nil) {
            return currentLanguageSeparated
        } else {
            return "es"
        }
    }

    open static func getParentLanguageID() -> String {
        return MercadoPagoContext.getLanguage().components(separatedBy: "-")[0]
    }

    open static func getLocalizedPath() -> String {
        let bundle = MercadoPago.getBundle() ?? Bundle.main
        let pathID = getLocalizedID()
        return bundle.path(forResource: pathID, ofType: "lproj")!
    }

    open static func getParentLocalizedPath() -> String {
        let bundle = MercadoPago.getBundle() ?? Bundle.main
        let pathID = getParentLanguageID()
        return bundle.path(forResource: pathID, ofType: "lproj")!
    }

    open static func getTermsAndConditionsSite() -> String {
        return sharedInstance.termsAndConditionsSite
    }

    open static func getCurrency() -> Currency {
        return sharedInstance.currency
    }

    open func publicKey() -> String! {
        return self.public_key
    }

    fileprivate override init() {
        super.init()
        _ = MercadoPagoUIViewController.loadFont(MercadoPago.DEFAULT_FONT_NAME)
        self.setSite(Site.MLA)
    }

    open class func setPayerAccessToken(_ payerAccessToken: String) {

        sharedInstance.payer_access_token = payerAccessToken.trimSpaces()
        _ = CardFrontView()
        _ = CardBackView()

    }

    open class func setPublicKey(_ public_key: String) {

        sharedInstance.public_key = public_key.trimSpaces()
        _ = CardFrontView()
        _ = CardBackView()

    }

    open class func setAccountMoneyAvailable(accountMoneyAvailable: Bool) {
        sharedInstance.account_money_available = accountMoneyAvailable
    }

    @available(*, deprecated, message: "Do not use. Deprecated in Q2 - 2018.")
    open class func setDisplayDefaultLoading(flag: Bool) {
        print("setDisplayDefaultLoading - Do not use. Deprecated in Q2 - 2018")
        //sharedInstance.display_default_loading = flag
    }

    open class func merchantAccessToken() -> String {
        return sharedInstance.merchant_access_token
    }
    open class func setMerchantAccessToken(merchantAT: String) {
        sharedInstance.merchant_access_token = merchantAT
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

    @available(*, deprecated, message: "Do not use. Deprecated in Q2 - 2018.")
    open class func shouldDisplayDefaultLoading() -> Bool {
        return false
        //return sharedInstance.display_default_loading
    }

    open class func paymentKey() -> String {
        if sharedInstance.payment_key == "" {
            sharedInstance.payment_key = String(arc4random()) + String(Date().timeIntervalSince1970)
        }
        return sharedInstance.payment_key
    }

    open class func clearPaymentKey() {
        sharedInstance.payment_key = ""
    }
}

@objc public enum Languages: Int {
    case _SPANISH
    case _SPANISH_MEXICO
    case _SPANISH_COLOMBIA
    case _SPANISH_URUGUAY
    case _SPANISH_PERU
    case _SPANISH_VENEZUELA
    //        case _SPANISH_CHILE
    case _PORTUGUESE
    case _ENGLISH

    func langPrefix() -> String {
        switch self {
        case ._SPANISH : return "es"
        case ._SPANISH_MEXICO : return "es-MX"
        case ._SPANISH_COLOMBIA : return "es-CO"
        case ._SPANISH_URUGUAY : return "es-UY"
        case ._SPANISH_PERU : return "es-PE"
        case ._SPANISH_VENEZUELA : return "es-VE"
            //            case ._SPANISH_CHILE : return "es-CH"

        case ._PORTUGUESE : return "pt"
        case ._ENGLISH : return "en"
        }
    }

}
