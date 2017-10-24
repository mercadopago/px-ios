//
//  PXBankDeal.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class PXBankDeal: NSObject {
    open var id: String!
    open var dateExpired: Date!
    open var dateStarted: Date!
    open var installments: [Int]!
    open var issuer: PXIssuer!
    open var legals: String!
    open var picture: PXPicture!
    open var maxInstallments: Int!
    open var paymentMethods: [PXPaymentMethod]!
    open var recommendedMessage: String!
    open var totalFinancialCost: Double!

}
