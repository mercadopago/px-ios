//
//  CustomerPaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 4/8/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers open class CustomerPaymentMethod: NSObject, CardInformation, PaymentMethodOption {

    var customerPaymentMethodId: String!
    var customerPaymentMethodDescription: String!
    var paymentMethodId: String!
    var paymentMethodTypeId: String!
    var firstSixDigits: String!

    var securityCode: SecurityCode = SecurityCode()
    var paymentMethod: PaymentMethod?
    var card: Card?

    open class func fromJSON(_ json: NSDictionary) -> CustomerPaymentMethod {
                let customerPaymentMethod = CustomerPaymentMethod()

                if json["id"] != nil && !(json["id"]! is NSNull) {
                       if let cPaymentMethodId = json["id"] as? String {
                                customerPaymentMethod.customerPaymentMethodId = cPaymentMethodId
                            }
                    }

                if json["description"] != nil && !(json["description"]! is NSNull) {
                        if let cPaymentMethodDesc = json["description"] as? String {
                                customerPaymentMethod.customerPaymentMethodDescription = cPaymentMethodDesc
                            }
                   }

                if json["payment_method_id"] != nil && !(json["payment_method_id"]! is NSNull) {
                        if let paymentMethodId = json["payment_method_id"] as? String {
                                customerPaymentMethod.paymentMethodId = paymentMethodId
                            }
                    }

                if json["payment_method_type"] != nil && !(json["payment_method_type"]! is NSNull) {
                        if let cPaymentMethodTypeId = json["payment_method_type"] as? String {
                                customerPaymentMethod.paymentMethodTypeId = cPaymentMethodTypeId
                            }
                    }

                if json["first_six_digits"] != nil && !(json["first_six_digits"]! is NSNull) {
                        if let cFirstSixDigits = json["first_six_digits"] as? String {
                                customerPaymentMethod.firstSixDigits = cFirstSixDigits
                            }
                    }

                return customerPaymentMethod
            }

    public override init() {
        super.init()
    }

    public init(cPaymentMethodId: String, paymentMethodId: String, paymentMethodTypeId: String, description: String) {
        self.customerPaymentMethodId = cPaymentMethodId
        self.paymentMethodId = paymentMethodId
        self.paymentMethodTypeId = paymentMethodTypeId
        self.customerPaymentMethodDescription = description
    }

    public func getIssuer() -> Issuer? {

        return card?.issuer
    }

    open func toJSON() -> [String: Any] {
        let obj: [String: Any] = [
            "_id": self.customerPaymentMethodId,
            "_description": self.customerPaymentMethodDescription == nil ? "" : self.customerPaymentMethodDescription!,
            "payment_method_id": self.paymentMethodId,
            "payment_method_type": self.paymentMethodTypeId
        ]

        return obj
    }

    public func getFirstSixDigits() -> String? {
        return card?.getCardBin()
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func isSecurityCodeRequired() -> Bool {
        return true
    }

    open func getCardId() -> String {
        return self.customerPaymentMethodId
    }

    open func getCardSecurityCode() -> SecurityCode {
        return self.securityCode
    }

    open func getCardDescription() -> String {
        return self.customerPaymentMethodDescription
    }

    open func getPaymentMethod() -> PaymentMethod? {
        return paymentMethod
    }

    open func getPaymentMethodId() -> String {
        return self.paymentMethodId
    }

    open func getPaymentTypeId() -> String {
        return self.paymentMethodTypeId
    }

    open func getCardBin() -> String? {
        return card?.getCardBin()
    }

    open func getCardLastForDigits() -> String? {
        return card?.getCardLastForDigits()
    }

    open func setupPaymentMethod(_ paymentMethod: PaymentMethod) {
        self.paymentMethod = paymentMethod
    }

    open func setupPaymentMethodSettings(_ settings: [Setting]) {
        self.securityCode = settings[0].securityCode
    }

    public func isIssuerRequired() -> Bool {
        return false
    }

    /** PaymentOptionDrawable implementation */

    public func getTitle() -> String {
        return getCardDescription()
    }

    public func getSubtitle() -> String? {
        return nil
    }

    public func getImage() -> UIImage? {
        return MercadoPago.getImageForPaymentMethod(withDescription: self.getPaymentMethodId())
    }

    /** PaymentMethodOption  implementation */

    public func hasChildren() -> Bool {
        return false
    }

    public func getChildren() -> [PaymentMethodOption]? {
        return nil
    }

    public func getId() -> String {
        return self.customerPaymentMethodId
    }

    public func isCustomerPaymentMethod() -> Bool {
        return true
    }

    public func isCard() -> Bool {

        return PaymentTypeId.isCard(paymentTypeId: self.paymentMethodTypeId)
    }

    public func getDescription() -> String {
        return self.customerPaymentMethodDescription
    }

    public func getComment() -> String {
        return ""
    }

    public func canBeClone() -> Bool {
        return false
    }
}
