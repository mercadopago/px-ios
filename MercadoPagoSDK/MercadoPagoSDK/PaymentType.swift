//
//  PaymentType.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 13/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers open class PaymentType: NSObject {

    open static let allPaymentIDs: Set<String> = [PaymentTypeId.DEBIT_CARD.rawValue, PaymentTypeId.CREDIT_CARD.rawValue, PaymentTypeId.ACCOUNT_MONEY.rawValue, PaymentTypeId.TICKET.rawValue, PaymentTypeId.BANK_TRANSFER.rawValue, PaymentTypeId.ATM.rawValue, PaymentTypeId.BITCOIN.rawValue, PaymentTypeId.PREPAID_CARD.rawValue, PaymentTypeId.BOLBRADESCO.rawValue]

    var paymentTypeId: PaymentTypeId!

    override public init() {
        super.init()
    }

    public init(paymentTypeId: PaymentTypeId) {
        super.init()
        self.paymentTypeId = paymentTypeId
    }
}

public enum PaymentTypeId: String {
    case DEBIT_CARD = "debit_card"
    case CREDIT_CARD = "credit_card"
    case ACCOUNT_MONEY = "account_money"
    case TICKET = "ticket"
    case BANK_TRANSFER = "bank_transfer"
    case ATM = "atm"
    case BITCOIN = "digital_currency"
    case PREPAID_CARD = "prepaid_card"
    case BOLBRADESCO = "bolbradesco"
    case PAYMENT_METHOD_PLUGIN = "payment_method_plugin"

    public static func fromJSON(_ json: NSDictionary) -> PaymentType {
                let paymentType = PaymentType()
                if let _id = JSONHandler.attemptParseToString(json["id"]) {
                        paymentType.paymentTypeId = PaymentTypeId(rawValue: _id)
                    }
                return paymentType
            }

    public func isCard() -> Bool {
        return self == PaymentTypeId.DEBIT_CARD || self == PaymentTypeId.CREDIT_CARD || self == PaymentTypeId.PREPAID_CARD
    }

    public func isCreditCard() -> Bool {
        return self == PaymentTypeId.CREDIT_CARD
    }

    public func isPrepaidCard() -> Bool {
        return self == PaymentTypeId.PREPAID_CARD
    }

    public func isDebitCard() -> Bool {
        return self == PaymentTypeId.DEBIT_CARD
    }

    public func isOnlinePaymentType() -> Bool {
        return PaymentTypeId.onlinePaymentTypes().contains(self.rawValue)
    }

    public func isOfflinePaymentType() -> Bool {
        return PaymentTypeId.offlinePaymentTypes().contains(self.rawValue)

    }

    public static func onlinePaymentTypes() -> [String] {
        return [DEBIT_CARD.rawValue, CREDIT_CARD.rawValue, ACCOUNT_MONEY.rawValue, PREPAID_CARD.rawValue, PAYMENT_METHOD_PLUGIN.rawValue]
    }

    public static func offlinePaymentTypes() -> [String] {
        return [ATM.rawValue, TICKET.rawValue, BANK_TRANSFER.rawValue]
    }

    public static func isCard(paymentTypeId: String) -> Bool {
        guard let paymentTypeIdEnum = PaymentTypeId(rawValue: paymentTypeId)
            else {
                return false
            }
        return paymentTypeIdEnum.isCard()
    }

    public static func isOnlineType(paymentTypeId: String) -> Bool {

        guard let paymentTypeIdEnum = PaymentTypeId(rawValue: paymentTypeId)
            else {
                return false
        }
        return paymentTypeIdEnum.isOnlinePaymentType()
    }

    public static func isOfflineType(paymentTypeId: String) -> Bool {

        guard let paymentTypeIdEnum = PaymentTypeId(rawValue: paymentTypeId)
            else {
                return false
        }
        return paymentTypeIdEnum.isOfflinePaymentType()
    }
}
