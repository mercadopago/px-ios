//
//  MerchantPayment.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

@objcMembers open class MerchantPayment: NSObject {
    open var issuer: Issuer?
    open var cardTokenId: String!
    open var campaignId: Int = 0
    open var installments: Int = 0
    open var items: [Item]?
    open var merchantAccessToken: String!
    open var paymentMethod: PaymentMethod!

    public override init() {
        super.init()
    }

    public init(items: [Item], installments: Int, cardIssuer: Issuer?, tokenId: String, paymentMethod: PaymentMethod, campaignId: Int) {
        self.items = items
        self.installments = installments
        self.issuer = cardIssuer
        self.cardTokenId = tokenId
        self.paymentMethod = paymentMethod
        self.campaignId = campaignId
        self.merchantAccessToken = MercadoPagoContext.merchantAccessToken()
    }

    open func toJSONString() -> String {

        let card_issuer_id: Any = (issuer == nil || self.issuer?.issuerId == "0") ? JSONHandler.null : (self.issuer?.issuerId)!
        let card_token: Any =  self.cardTokenId == nil ? JSONHandler.null : self.cardTokenId!
        let campaign_id: Any = self.campaignId == 0 ? JSONHandler.null : String(self.campaignId)
        let installments: Any = self.installments == 0 ? JSONHandler.null : self.installments
        let merchant_access_token: Any = self.merchantAccessToken == nil ? JSONHandler.null : self.merchantAccessToken!
       let payment_method_id: Any = (self.paymentMethod == nil || self.paymentMethod.paymentMethodId == nil) ? JSONHandler.null : self.paymentMethod.paymentMethodId!

        var obj: [String: Any] = [
            "card_issuer_id": card_issuer_id,
            "card_token": card_token,
            "campaign_id": campaign_id,
            "installments": installments,
            "merchant_access_token": merchant_access_token,
            "payment_method_id": payment_method_id
        ]

        var itemsJson = ""
        for item in items! {
            itemsJson.append(item.toJSONString())
        }
        obj["items"] = itemsJson

        return JSONHandler.jsonCoding(obj)
    }

}
