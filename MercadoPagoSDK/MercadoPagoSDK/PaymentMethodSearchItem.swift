//
//  PaymentMethodSearchItem.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class PaymentMethodSearchItem: NSObject, PaymentOptionDrawable, PaymentMethodOption {

    open var idPaymentMethodSearchItem: String!
    open var type: PaymentMethodSearchItemType!
    open var paymentMethodSearchItemDescription: String!
    open var comment: String?
    open var childrenHeader: String?
    open var children: [PaymentMethodSearchItem] = []
    open var showIcon: Bool = false

    open func isOfflinePayment() -> Bool {
        return PaymentTypeId.offlinePaymentTypes().contains(self.idPaymentMethodSearchItem)
    }

    open func isBitcoin() -> Bool {
        return self.idPaymentMethodSearchItem.lowercased() == "bitcoin"
    }

    open func isPaymentMethod() -> Bool {
        return self.type == PaymentMethodSearchItemType.PAYMENT_METHOD
    }

    open func isPaymentType() -> Bool {
        return self.type == PaymentMethodSearchItemType.PAYMENT_TYPE
    }

    /*
     * PaymentOptionDrawable implementation
     */

    public func getTitle() -> String {
        return self.paymentMethodSearchItemDescription
    }

    public func getSubtitle() -> String? {
        if self.idPaymentMethodSearchItem == PaymentTypeId.CREDIT_CARD.rawValue || self.idPaymentMethodSearchItem == PaymentTypeId.DEBIT_CARD.rawValue || self.idPaymentMethodSearchItem == PaymentTypeId.PREPAID_CARD.rawValue {
            return nil
        }
        return self.comment
    }

    public func getImage() -> UIImage? {
        return MercadoPago.getImageForPaymentMethod(withDescription: self.idPaymentMethodSearchItem)
    }

    /*
     * PaymentMethodOption implementation
     */

    public func hasChildren() -> Bool {
        return !Array.isNullOrEmpty(self.children)
    }

    public func getChildren() -> [PaymentMethodOption]? {
        return self.children
    }

    public func isCard() -> Bool {
        return PaymentTypeId.isCard(paymentTypeId: self.idPaymentMethodSearchItem.lowercased())
    }

    public func getId() -> String {
        return self.idPaymentMethodSearchItem
    }

    public func isCustomerPaymentMethod() -> Bool {
        return false
    }

    public func getDescription() -> String {
        return self.paymentMethodSearchItemDescription
    }

    public func getComment() -> String {
        return self.comment ?? ""
    }
}

public enum PaymentMethodSearchItemType: String {
    case GROUP = "group"
    case PAYMENT_TYPE = "payment_type"
    case PAYMENT_METHOD = "payment_method"
}
