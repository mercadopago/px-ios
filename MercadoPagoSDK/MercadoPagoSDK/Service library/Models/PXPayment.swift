//
//  PXPayment.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPayment: NSObject {
    open var binaryMode: Bool!
    open var callForAuthorizeId: String!
    open var captured: Bool!
    open var card: PXCard!
    open var collectorId: String!
    open var couponAmount: Double!
    open var currencyId: String!
    open var dateApproved: Date!
    open var dateCreated: Date!
    open var dateLastUpdated: Date!
    open var _description: String!
    open var differentialPricingId: Int64!
    open var externalReference: String!
    open var feeDetails: [PXFeeDetail]!
    open var id: String!
    open var installments: Int!
    open var issuerId: Int!
    open var liveMode: Bool!
    open var metadata: NSDictionary!
    open var moneyReleaseDate: Date!
    open var notificationUrl: String!
    open var operationType: String!
    open var order: PXOrder!
    open var payer: PXPayer!
    open var paymentMethodId: String!
    open var paymentTypeId: String!
    open var refunds: [PXRefund]!
    open var statementDescriptor: String!
    open var status: String!
    open var statusDetail: String!
    open var transactionAmount: Double!
    open var transactionAmountRefunded: Double!
    open var transactionDetails: PXTransactionDetails!
    open var TokenId: String!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["":""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXPayment {
        return PXPayment()
    }
}
