//
//  PaymentType.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 13/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class PaymentType: NSObject {

    open static let allPaymentIDs : Set<String> = [PaymentTypeId.DEBIT_CARD.rawValue,PaymentTypeId.CREDIT_CARD.rawValue,PaymentTypeId.ACCOUNT_MONEY.rawValue,PaymentTypeId.TICKET.rawValue,PaymentTypeId.BANK_TRANSFER.rawValue,PaymentTypeId.ATM.rawValue,PaymentTypeId.BITCOIN.rawValue,PaymentTypeId.PREPAID_CARD.rawValue]
    
    var paymentTypeId : PaymentTypeId!
    
    override public init(){
        super.init()
    }
    
    public init(paymentTypeId : PaymentTypeId){
        super.init()
        self.paymentTypeId = paymentTypeId
    }
    
    open class func fromJSON(_ json : NSDictionary) -> PaymentType {
        let paymentType = PaymentType()
        
        if let _id = JSONHandler.attemptParseToString(json["id"]){
            paymentType.paymentTypeId = PaymentTypeId(rawValue: _id)
        }
        return paymentType
    }


}

public enum PaymentTypeId :String {
    case DEBIT_CARD = "debit_card"
    case CREDIT_CARD = "credit_card"
    case ACCOUNT_MONEY = "account_money"
    case TICKET = "ticket"
    case BANK_TRANSFER = "bank_transfer"
    case ATM = "atm"
    case BITCOIN = "digital_currency"
    case PREPAID_CARD = "prepaid_card"
    
    public func isCard() -> Bool {
        return self == PaymentTypeId.DEBIT_CARD || self == PaymentTypeId.CREDIT_CARD || self == PaymentTypeId.PREPAID_CARD
    }
    
    public static func offlinePayments() -> [String] {
        return [ATM.rawValue, TICKET.rawValue, BANK_TRANSFER.rawValue]
    }
    
    public func isOfflinePayment() -> Bool {
        return PaymentTypeId.offlinePayments().contains(self.rawValue)
    }
    
    
    
}










