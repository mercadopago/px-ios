//
//  ExamplesUtils.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 29/1/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import UIKit
import MercadoPagoSDK

class ExamplesUtils {
    
    
    
    static var preferenceSelectedID : String = ExamplesUtils.PREF_ID_NO_EXCLUSIONS
    
    
    class var MERCHANT_PUBLIC_KEY : String {
        return //"444a9ef5-8a6b-429f-abdf-587639155d88"
            //"444a9ef5-8a6b-429f-abdf-587639155d88" // AR
            // "APP_USR-f163b2d7-7462-4e7b-9bd5-9eae4a7f99c3" // BR
            // "6c0d81bc-99c1-4de8-9976-c8d1d62cd4f2" // MX
            // "2b66598b-8b0f-4588-bd2f-c80ca21c6d18" // VZ
            // "aa371283-ad00-4d5d-af5d-ed9f58e139f1" // CO
            
            //"6c0d81bc-99c1-4de8-9976-c8d1d62cd4f2"
        //"TEST-9eb0be69-329a-417f-9dd5-aad772a4d50b"
        "APP_USR-5a399d42-6015-4f6a-8ff8-dd7d368068f8"
        
        // "TEST-d7ecb23b-8cbd-4292-96d5-eccfe39748b5"
        // "TEST-2edbc541-4e19-43b9-8241-2cda72da6b6f"
        
        //USUARIO AXEL - ARG
        // "TEST-c0e6ec4e-efb3-4fb9-bb73-169484533a63"
        
        
    }
    
    class var MERCHANT_PUBLIC_KEY_TEST : String {
        return //"444a9ef5-8a6b-429f-abdf-587639155d88"
            //"444a9ef5-8a6b-429f-abdf-587639155d88" // AR
             //"APP_USR-f163b2d7-7462-4e7b-9bd5-9eae4a7f99c3" // BR
            // "6c0d81bc-99c1-4de8-9976-c8d1d62cd4f2" // MX
            // "2b66598b-8b0f-4588-bd2f-c80ca21c6d18" // VZ
            // "aa371283-ad00-4d5d-af5d-ed9f58e139f1" // CO
            
            // "444a9ef5-8a6b-429f-abdf-587639155d88"
            
        //"6c0d81bc-99c1-4de8-9976-c8d1d62cd4f2"
        //"TEST-9eb0be69-329a-417f-9dd5-aad772a4d50b" // MX
        "TEST-ad365c37-8012-4014-84f5-6c895b3f8e0a" //ARG
        // "TEST-2edbc541-4e19-43b9-8241-2cda72da6b6f"
        
        //USUARIO AXEL - ARG
        // "TEST-c0e6ec4e-efb3-4fb9-bb73-169484533a63"
        
    }
    
    class var MERCHANT_MOCK_BASE_URL : String {
        return "https://www.mercadopago.com"
    }
    class var MERCHANT_MOCK_GET_CUSTOMER_URI : String {
        return "/checkout/examples/getCustomer"
    }
    
    class var MERCHANT_MOCK_CREATE_PAYMENT_URI : String {
        return  "/checkout/examples/doPayment"
    }
    
    class var MERCHANT_MOCK_GET_DISCOUNT_URI : String {
        return  "/checkout/examples/getDiscounts"
    }
    
    class var MERCHANT_ACCESS_TOKEN : String {
        return "mla-cards-data"
        // "mla-cards-data" // AR
        // "mlb-cards-data" // BR
        // "mlm-cards-data" // MX
        // "mlv-cards-data" // VZ
        // "mco-cards-data" // CO
        // "mla-cards-data-tarshop" // NO CVV
        // return "mla-cards-data-tarshop" // No CVV
    }
    class var AMOUNT : Double {
        return 999.99
    }
    
    class var ITEM_ID : String {
        return "id1"
    }
    
    class var ITEM_TITLE : String {
        return "This is the title for an item purchased, extremely long so you can test how a long title will be displayed in the app"
    }
    
    class var ITEM_QUANTITY : Int {
        return 1
    }
    
    class var ITEM_UNIT_PRICE : Double {
        return 1000.00
    }
    
    
    class var PREF_ID_NO_EXCLUSIONS : String {
        return "150216849-e131b785-10d3-48c0-a58b-2910935512e0"
    }
    
    class var PREF_ID_TICKET_EXCLUDED : String {
        return "150216849-551cddcc-e221-4289-bb9c-54bfab992e3d"
    }
    
    class var PREF_ID_MLA_ONLY_CC : String {
        return "150216849-80a7a6da-dec9-410f-b865-7244c91141fb"
    }
    
    class var PREF_ID_MLA_RAPIPAGO_CARGAVIRTUAL_EXCLUDED : String {
        return "150216849-e6ab0d15-e6f1-4160-a447-2ba5294ca7f4"
    }
    
    class var PREF_ID_MLA_ONLY_PAGOFACIL : String {
        return "150216849-b4c456b8-e880-497e-aafa-cbfc60c8114b"
    }
    
    class var PREF_ID_MLA_SEVERAL_ITEMS : String {
        return "150216849-77db2abc-a73d-4293-8914-4a35ddf835c0"
    }
    
    class func startCardActivity(_ merchantPublicKey: String, paymentMethod: PaymentMethod, callback: @escaping (_ token: Token?) -> Void) -> CardViewController {
        return CardViewController(merchantPublicKey: merchantPublicKey, paymentMethod: paymentMethod, callback: callback)
    }
    
    class func startSimpleVaultActivity(_ merchantPublicKey: String, merchantBaseUrl: String, merchantGetCustomerUri: String, merchantAccessToken: String, paymentPreference: PaymentPreference?, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?) -> Void) -> SimpleVaultViewController {
        return SimpleVaultViewController(merchantPublicKey: merchantPublicKey, merchantBaseUrl: merchantBaseUrl, merchantGetCustomerUri: merchantGetCustomerUri, merchantAccessToken: merchantAccessToken, paymentPreference: paymentPreference, callback: callback)
    }
    
    class func startAdvancedVaultActivity(_ merchantPublicKey: String, merchantBaseUrl: String, merchantGetCustomerUri: String, merchantAccessToken: String, amount: Double, paymentPreference: PaymentPreference?, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: String?, _ issuer: Issuer?, _ installments: Int) -> Void) -> AdvancedVaultViewController {
        return AdvancedVaultViewController(merchantPublicKey: merchantPublicKey, merchantBaseUrl: merchantBaseUrl, merchantGetCustomerUri: merchantGetCustomerUri, merchantAccessToken: merchantAccessToken, amount: amount, paymentPreference: paymentPreference, callback: callback)
    }
    
    class func startFinalVaultActivity(_ merchantPublicKey: String, merchantBaseUrl: String, merchantGetCustomerUri: String, merchantAccessToken: String, amount: Double, paymentPreference: PaymentPreference?, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: String?, _ issuer: Issuer?, _ installments: Int) -> Void) -> FinalVaultViewController {
        return FinalVaultViewController(merchantPublicKey: merchantPublicKey, merchantBaseUrl: merchantBaseUrl, merchantGetCustomerUri: merchantGetCustomerUri, merchantAccessToken: merchantAccessToken, amount: amount, paymentPreference: paymentPreference, callback: callback)
    }
    
    class func createPayment(_ token: String, installments: Int, cardIssuer: Issuer?, paymentMethod: PaymentMethod, callback: @escaping (_ payment: Payment) -> Void) {
        // Set item
        let item : Item = Item(_id: ExamplesUtils.ITEM_ID, title: ExamplesUtils.ITEM_TITLE, quantity: ExamplesUtils.ITEM_QUANTITY,
                               unitPrice: ExamplesUtils.ITEM_UNIT_PRICE)
        
        //let issuerId : NSNumber = cardIssuerId == nil ? 0 : cardIssuerId!
        
        // Set merchant payment
        let payment : MerchantPayment = MerchantPayment(items: [item], installments: installments, cardIssuer: cardIssuer, tokenId: token, paymentMethod: paymentMethod, campaignId: 0)
        
        // Create payment
        MercadoPagoContext.setBaseURL(ExamplesUtils.MERCHANT_MOCK_BASE_URL)
        MercadoPagoContext.setPaymentURI(ExamplesUtils.MERCHANT_MOCK_CREATE_PAYMENT_URI)
        MerchantServer.createPayment(payment, success: callback, failure: nil)
    }
    
    class func createCheckoutPreferenceWithNoExclusions() -> CheckoutPreference {
        
        // Create items
        let item_1 : Item = Item(_id: ExamplesUtils.ITEM_ID, title : ExamplesUtils.ITEM_TITLE, quantity: ExamplesUtils.ITEM_QUANTITY,
                                 unitPrice: ExamplesUtils.ITEM_UNIT_PRICE)
        item_1.currencyId = "MXN"
        var items = [Item]()
        items.append(item_1)
        
        //Create Payer
        let payer = Payer()
        payer._id = 2
        payer.email = "thisis@nemail.com"
        
        
        //Create CheckoutPreference
        let preference = CheckoutPreference(items: items, payer: payer, paymentMethods: nil)
        preference._id = ExamplesUtils.PREF_ID_NO_EXCLUSIONS
        
        return preference
    }
    
    class func createCheckoutPreference() -> CheckoutPreference {
        
        let preference = self.createCheckoutPreferenceWithNoExclusions()
        
        //Preference payment methods
        let paymentPreference = PaymentPreference()
        
        paymentPreference.excludedPaymentMethodIds = ["oxxo", "bancomer_bank_transfer"]
        paymentPreference.excludedPaymentTypeIds = [PaymentTypeId.DEBIT_CARD.rawValue]
        paymentPreference.maxAcceptedInstallments = 1
        paymentPreference.defaultInstallments = 1
        preference.paymentPreference = paymentPreference
        
        return preference
    }
    
}
