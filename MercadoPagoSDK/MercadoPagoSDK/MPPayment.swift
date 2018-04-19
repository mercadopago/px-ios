//
//  MPPayment.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 26/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

@objcMembers open class MPPayment: NSObject {

    open var preferenceId: String!
    open var publicKey: String!
    open var paymentMethodId: String!
    open var installments: Int = 0
    open var issuerId: String?
    open var tokenId: String?
    open var payer: Payer?
    open var binaryMode: Bool = false
    open var transactionDetails: TransactionDetails?
    open var discount: DiscountCoupon?
    
    override init() {
        super.init()
    }

    init(preferenceId: String, publicKey: String, paymentMethodId: String, installments: Int = 0, issuerId: String = "", tokenId: String = "", transactionDetails: TransactionDetails, payer: Payer, binaryMode: Bool, discount: DiscountCoupon? = nil) {
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

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String: Any] {
        var obj: [String: Any] = [
            "public_key": self.publicKey,
            "payment_method_id": self.paymentMethodId,
            "pref_id": self.preferenceId,
            "binary_mode": self.binaryMode
            ]

        if self.tokenId != nil && self.tokenId?.count > 0 {
            obj["token"] = self.tokenId!
        }

        obj["installments"] = self.installments

        if self.issuerId != nil && self.issuerId?.count > 0 {
            obj["issuer_id"] = self.issuerId
        }

        if self.payer != nil {
                obj["payer"] = self.payer?.toJSON()
        }

        if self.transactionDetails != nil {
            obj["transaction_details"] = self.transactionDetails?.toJSON()
        }
        if let discount = self.discount {
            obj["campaign_id"] = discount.discountId
            obj["coupon_amount"] = discount.coupon_amount
        }

        return obj
    }
}

@objcMembers open class CustomerPayment: MPPayment {

    open var customerId: String!

    init(preferenceId: String, publicKey: String, paymentMethodId: String, installments: Int = 0, issuerId: String = "", tokenId: String = "", customerId: String, transactionDetails: TransactionDetails, payer: Payer, binaryMode: Bool) {
        super.init(preferenceId: preferenceId, publicKey: publicKey, paymentMethodId: paymentMethodId, installments: installments, issuerId: issuerId, tokenId: tokenId, transactionDetails: transactionDetails, payer: payer, binaryMode: binaryMode)
        self.customerId = customerId
    }

    open override func toJSON() -> [String: Any] {
        self.payer?.payerId = customerId
        let customerPaymentObj: [String: Any] = super.toJSON()
        return customerPaymentObj
    }

}

@objcMembers open class BlacklabelPayment: MPPayment {

    open override func toJSON() -> [String: Any] {
        // Override payer object with groupsPayer (which includes AT in its body)
        guard let payer = self.payer, let email = self.payer?.email else {
            return [:]
        }

        self.payer = GroupsPayer(payerId: payer.payerId, email: email, identification: payer.identification, entityType: payer.entityType)
        let blacklabelPaymentObj: [String: Any] = super.toJSON()
        return blacklabelPaymentObj
    }
}

open class MPPaymentFactory {

    open class func createMPPayment(preferenceId: String, publicKey: String, paymentMethodId: String, installments: Int = 0, issuerId: String = "", tokenId: String = "", customerId: String? = nil, isBlacklabelPayment: Bool, transactionDetails: TransactionDetails, payer: Payer, binaryMode: Bool, discount: DiscountCoupon? = nil) -> MPPayment {

        if !String.isNullOrEmpty(customerId) {
            return CustomerPayment(preferenceId: preferenceId, publicKey: publicKey, paymentMethodId: paymentMethodId, installments: installments, issuerId: issuerId, tokenId: tokenId, customerId: customerId!, transactionDetails: transactionDetails, payer: payer, binaryMode: binaryMode)
        } else if isBlacklabelPayment {
            return BlacklabelPayment(preferenceId: preferenceId, publicKey: publicKey, paymentMethodId: paymentMethodId, installments: installments, issuerId: issuerId, tokenId: tokenId, transactionDetails: transactionDetails, payer: payer, binaryMode: binaryMode)
        }

        return MPPayment(preferenceId: preferenceId, publicKey: publicKey, paymentMethodId: paymentMethodId, installments: installments, issuerId: issuerId, tokenId: tokenId, transactionDetails: transactionDetails, payer: payer, binaryMode: binaryMode, discount: discount)

    }

}
