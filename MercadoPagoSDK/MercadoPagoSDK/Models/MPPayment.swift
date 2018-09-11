//
//  MPPayment.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 26/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

internal class MPPayment: Encodable {

    open var preferenceId: String!
    open var publicKey: String!
    open var paymentMethodId: String!
    open var installments: Int = 0
    open var issuerId: String?
    open var tokenId: String?
    open var payer: PXPayer?
    open var binaryMode: Bool = false
    open var transactionDetails: PXTransactionDetails?
    open var discount: PXDiscount?

    init(preferenceId: String, publicKey: String, paymentMethodId: String, installments: Int = 0, issuerId: String = "", tokenId: String = "", transactionDetails: PXTransactionDetails, payer: PXPayer, binaryMode: Bool, discount: PXDiscount? = nil) {
        self.preferenceId = preferenceId
        self.publicKey = publicKey
        self.paymentMethodId = paymentMethodId
        self.installments = installments
        self.issuerId = issuerId
        self.tokenId = tokenId
        self.transactionDetails = transactionDetails
        self.payer = payer
        self.binaryMode = binaryMode
        self.discount = discount
    }

    public enum PXMPPaymentKeys: String, CodingKey {
        case publicKey = "public_key"
        case paymentMethodId = "payment_method_id"
        case binaryMode = "binary_mode"
        case prefId = "pref_id"
        case payer
        case installments
        case token
        case issuerId = "issuer_id"
        case campaignId = "campaign_id"
        case couponAmount = "coupon_amount"
        case transactionDetails = "transaction_details"
    }

    init(preferenceId: String, publicKey: String, paymentData: PXPaymentData, binaryMode: Bool) {
        self.issuerId = paymentData.hasIssuer() ? paymentData.getIssuer()!.id : ""
        self.tokenId = paymentData.hasToken() ? paymentData.getToken()!.id : ""
        self.installments = paymentData.hasPayerCost() ? paymentData.getPayerCost()!.installments : 0

        if let transactionDetails = paymentData.transactionDetails {
            self.transactionDetails = transactionDetails
        }

        self.payer = PXPayer(email: "")
        if let targetPayer = paymentData.payer {
            self.payer = targetPayer
        }

        self.discount = paymentData.discount
        self.paymentMethodId = paymentData.getPaymentMethod()?.id ?? ""

        self.preferenceId = preferenceId
        self.publicKey = publicKey
        self.binaryMode = binaryMode

    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXMPPaymentKeys.self)

        if installments > 0 {
            try container.encodeIfPresent(self.installments, forKey: .installments)
        }
        if !String.isNullOrEmpty(tokenId) {
            try container.encodeIfPresent(self.tokenId, forKey: .token)
        }
        if !String.isNullOrEmpty(issuerId) {
            try container.encodeIfPresent(self.issuerId, forKey: .issuerId)
        }

        try container.encodeIfPresent(self.publicKey, forKey: .publicKey)
        try container.encodeIfPresent(self.paymentMethodId, forKey: .paymentMethodId)
        try container.encodeIfPresent(self.binaryMode, forKey: .binaryMode)
        try container.encodeIfPresent(self.preferenceId, forKey: .prefId)
        try container.encodeIfPresent(self.payer, forKey: .payer)
        try container.encodeIfPresent(self.discount?.id, forKey: .campaignId)
        try container.encodeIfPresent(self.discount?.couponAmount, forKey: .couponAmount)
        try container.encodeIfPresent(self.transactionDetails, forKey: .transactionDetails)
    }

    internal func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    internal func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}
