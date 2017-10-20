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
    open var card: Card
    open var collectorId: String!
    open var couponAmount: Double!
    open var currencyId: String!
    open var dateApproved: Date!
    open var dateCreated: Date!
    open var dateLastUpdated: Date!
    open var _description: Strin!
    open var differentialPricingId: Int64!
    open var externalReference: String!
    open var feeDetails: [PXFeesDetail]!
    open var id: String!
    open var installments: Integer!
    open var issuerId: Integer!
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
    open var transactionAmountRefunded: Dounble!
    open var transactionDetails: PXTransactionDetails
    open var TokenId: String!
}
