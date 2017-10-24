//
//  PXPaymentTypes.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPaymentTypes: NSObject {
    open static let CREDIT_CARD = "credit_card"
    open static let DEBIT_CARD = "debit_card"
    open static let PREPAID_CARD = "prepaid_card"
    open static let TICKET = "ticket"
    open static let ATM = "atm"
    open static let DIGITAL_CURRENCY = "digital_currency"
    open static let BANK_TRANSFER = "bank_transfer"
    open static let ACCOUNT_MONEY = "account_money"
}
