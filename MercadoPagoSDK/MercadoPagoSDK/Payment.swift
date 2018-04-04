//
//  Payment.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
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

open class Payment: NSObject {
    open var binaryMode: Bool!
    open var callForAuthorizeId: String!
    open var captured: Bool!
    open var card: Card!
    open var currencyId: String!
    open var dateApproved: Date!
    open var dateCreated: Date!
    open var dateLastUpdated: Date!
    open var paymentDescription: String!
    open var externalReference: String!
    open var feesDetails: [FeesDetail]!
    open var paymentId: String = ""
    open var installments: Int = 0
    open var liveMode: Bool!
    open var metadata: NSObject!
    open var moneyReleaseDate: Date!
    open var notificationUrl: String!
    open var order: Order!
    open var payer: Payer!
    open var paymentMethodId: String!
    open var paymentTypeId: String!
    open var refunds: [Refund]!
    open var statementDescriptor: String!
    open var status: String!
    open var statusDetail: String!
    open var transactionAmount: Double = 0
    open var transactionAmountRefunded: Double = 0
    open var transactionDetails: TransactionDetails!
    open var collectorId: String!
    open var couponAmount: Double = 0
    open var differentialPricingId: NSNumber = 0
    open var issuerId: Int = 0
    open var tokenId: String?

    override public init() {
        super.init()
    }

    open func toJSONString() -> String {
        let obj: [String: Any] = [
            "id": String(describing: self.paymentId),
            "transaction_amount": self.transactionAmount,
            "tokenId": self.tokenId == nil ? "" : self.tokenId!,
            "issuerId": self.issuerId,
            "description": self.paymentDescription,
            "installments": self.installments == 0 ? 0 : self.installments,
            "payment_method_id": self.paymentMethodId,
            "status": self.status,
            "status_detail": self.statusDetail,
            "card": card == nil ? "" : card.toJSONString()
        ]

        return JSONHandler.jsonCoding(obj)
    }

    open func isRejected() -> Bool {
        return self.status == PaymentStatus.REJECTED
    }
}
