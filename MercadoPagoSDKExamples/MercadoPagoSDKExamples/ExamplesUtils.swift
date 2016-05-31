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

    class var MERCHANT_PUBLIC_KEY : String {
		return //"444a9ef5-8a6b-429f-abdf-587639155d88"
		 //"444a9ef5-8a6b-429f-abdf-587639155d88" // AR
		// "APP_USR-f163b2d7-7462-4e7b-9bd5-9eae4a7f99c3" // BR
		// "6c0d81bc-99c1-4de8-9976-c8d1d62cd4f2" // MX
		// "2b66598b-8b0f-4588-bd2f-c80ca21c6d18" // VZ
		// "aa371283-ad00-4d5d-af5d-ed9f58e139f1" // CO
        
       // "444a9ef5-8a6b-429f-abdf-587639155d88"
          "APP_USR-5a399d42-6015-4f6a-8ff8-dd7d368068f8"

        // "TEST-d7ecb23b-8cbd-4292-96d5-eccfe39748b5"
       // "TEST-2edbc541-4e19-43b9-8241-2cda72da6b6f"

        //USUARIO AXEL - ARG
        // "TEST-c0e6ec4e-efb3-4fb9-bb73-169484533a63"
    }
    
    class var MERCHANT_PUBLIC_KEY_TEST : String {
        return //"444a9ef5-8a6b-429f-abdf-587639155d88"
            //"444a9ef5-8a6b-429f-abdf-587639155d88" // AR
            // "APP_USR-f163b2d7-7462-4e7b-9bd5-9eae4a7f99c3" // BR
            // "6c0d81bc-99c1-4de8-9976-c8d1d62cd4f2" // MX
            // "2b66598b-8b0f-4588-bd2f-c80ca21c6d18" // VZ
            // "aa371283-ad00-4d5d-af5d-ed9f58e139f1" // CO
            
            // "444a9ef5-8a6b-429f-abdf-587639155d88"
        
        
         "TEST-ad365c37-8012-4014-84f5-6c895b3f8e0a"
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
        return "150216849-ceed1ee4-8ab9-4449-869f-f4a8565d386f"
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
    
    class func startCardActivity(merchantPublicKey: String, paymentMethod: PaymentMethod, callback: (token: Token?) -> Void) -> CardViewController {
        return CardViewController(merchantPublicKey: merchantPublicKey, paymentMethod: paymentMethod, callback: callback)
    }
    
    class func startSimpleVaultActivity(merchantPublicKey: String, merchantBaseUrl: String, merchantGetCustomerUri: String, merchantAccessToken: String, supportedPaymentTypes: Set<PaymentTypeId>, callback: (paymentMethod: PaymentMethod, token: Token?) -> Void) -> SimpleVaultViewController {
        return SimpleVaultViewController(merchantPublicKey: merchantPublicKey, merchantBaseUrl: merchantBaseUrl, merchantGetCustomerUri: merchantGetCustomerUri, merchantAccessToken: merchantAccessToken, supportedPaymentTypes: supportedPaymentTypes, callback: callback)
    }
    
    class func startAdvancedVaultActivity(merchantPublicKey: String, merchantBaseUrl: String, merchantGetCustomerUri: String, merchantAccessToken: String, amount: Double, supportedPaymentTypes: Set<PaymentTypeId>, callback: (paymentMethod: PaymentMethod, token: String?, issuer: Issuer?, installments: Int) -> Void) -> AdvancedVaultViewController {
        return AdvancedVaultViewController(merchantPublicKey: merchantPublicKey, merchantBaseUrl: merchantBaseUrl, merchantGetCustomerUri: merchantGetCustomerUri, merchantAccessToken: merchantAccessToken, amount: amount, supportedPaymentTypes: supportedPaymentTypes, callback: callback)
    }
    
    class func startFinalVaultActivity(merchantPublicKey: String, merchantBaseUrl: String, merchantGetCustomerUri: String, merchantAccessToken: String, amount: Double, supportedPaymentTypes: Set<PaymentTypeId>, callback: (paymentMethod: PaymentMethod, token: String?, issuer: Issuer?, installments: Int) -> Void) -> FinalVaultViewController {
        return FinalVaultViewController(merchantPublicKey: merchantPublicKey, merchantBaseUrl: merchantBaseUrl, merchantGetCustomerUri: merchantGetCustomerUri, merchantAccessToken: merchantAccessToken, amount: amount, supportedPaymentTypes: supportedPaymentTypes, callback: callback)
    }
    
    class func createPayment(token: String, installments: Int, cardIssuer: Issuer?, paymentMethod: PaymentMethod, callback: (payment: Payment) -> Void) {
        // Set item
        let item : Item = Item(_id: ExamplesUtils.ITEM_ID, title: ExamplesUtils.ITEM_TITLE, quantity: ExamplesUtils.ITEM_QUANTITY,
            unitPrice: ExamplesUtils.ITEM_UNIT_PRICE)

		//let issuerId : NSNumber = cardIssuerId == nil ? 0 : cardIssuerId!
		
        // Set merchant payment
        let payment : MerchantPayment = MerchantPayment(items: [item], installments: installments, cardIssuer: cardIssuer, tokenId: token, paymentMethod: paymentMethod, campaignId: 0)
        
        // Create payment
        MerchantServer.createPayment(ExamplesUtils.MERCHANT_MOCK_BASE_URL, merchantPaymentUri: ExamplesUtils.MERCHANT_MOCK_CREATE_PAYMENT_URI, payment: payment, success: callback, failure: nil)
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
        let paymentPreference = PaymentPreference(excludedPaymentMethodsIds: ["oxxo", "bancomer_bank_transfer"], excludedPaymentTypesIds: [PaymentTypeId.DEBIT_CARD,], defaultPaymentMethodId: nil, maxAcceptedInstallment: 1, defaultInstallments: 1)
        
        preference.paymentPreference = paymentPreference
        
        return preference
    }

}
