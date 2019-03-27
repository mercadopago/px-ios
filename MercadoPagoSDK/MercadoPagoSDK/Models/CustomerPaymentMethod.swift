//
//  CustomerPaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 4/8/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers internal class CustomerPaymentMethod: NSObject, PXCardInformation, PaymentMethodOption {
    func setDisabled(_ disabled: Bool) {
        disabledOption = disabled
    }

    func isDisabled() -> Bool {
        return disabledOption
    }


    var customerPaymentMethodId: String!
    var customerPaymentMethodDescription: String!
    var paymentMethodId: String!
    var paymentMethodTypeId: String!
    var firstSixDigits: String!
    var disabledOption: Bool = false

    var securityCode: PXSecurityCode?
    var paymentMethod: PXPaymentMethod?
    var card: PXCard?

    public override init() {
        super.init()
    }

    init(cPaymentMethodId: String, paymentMethodId: String, paymentMethodTypeId: String, description: String) {
        self.customerPaymentMethodId = cPaymentMethodId
        self.paymentMethodId = paymentMethodId
        self.paymentMethodTypeId = paymentMethodTypeId
        self.customerPaymentMethodDescription = description
    }

    func getIssuer() -> PXIssuer? {
        return card?.issuer
    }

    func getFirstSixDigits() -> String {
        return card?.getCardBin() ?? ""
    }

    func isSecurityCodeRequired() -> Bool {
        return true
    }

    func getCardId() -> String {
        return self.customerPaymentMethodId
    }

    func getCardSecurityCode() -> PXSecurityCode? {
        return securityCode
    }

    func getCardDescription() -> String {
        return self.customerPaymentMethodDescription
    }

    func getPaymentMethod() -> PXPaymentMethod? {
        return paymentMethod
    }

    func getPaymentMethodId() -> String {
        return self.paymentMethodId
    }

    func getPaymentTypeId() -> String {
        return self.paymentMethodTypeId
    }

    func getCardBin() -> String? {
        return card?.getCardBin()
    }

    func getCardLastForDigits() -> String? {
        return card?.getCardLastForDigits()
    }

    func setupPaymentMethod(_ paymentMethod: PXPaymentMethod) {
        self.paymentMethod = paymentMethod
    }

    func setupPaymentMethodSettings(_ settings: [PXSetting]) {
        self.securityCode = settings[0].securityCode
    }

    func isIssuerRequired() -> Bool {
        return false
    }

    /** PaymentOptionDrawable implementation */

    func getTitle() -> String {
        return getCardDescription()
    }

    func getSubtitle() -> String? {
        return nil
    }

    func getImage() -> UIImage? {
        return ResourceManager.shared.getImageForPaymentMethod(withDescription: self.getPaymentMethodId())
    }

    /** PaymentMethodOption  implementation */

    func hasChildren() -> Bool {
        return false
    }

    func getChildren() -> [PaymentMethodOption]? {
        return nil
    }

    func getId() -> String {
        return self.customerPaymentMethodId
    }

    func isCustomerPaymentMethod() -> Bool {
        return true
    }

    func isCard() -> Bool {

        return PXPaymentTypes.isCard(paymentTypeId: self.paymentMethodTypeId)
    }

    func getDescription() -> String {
        return self.customerPaymentMethodDescription
    }

    func getComment() -> String {
        return ""
    }

    func canBeClone() -> Bool {
        return false
    }

    func getPaymentType() -> String {
        return paymentMethodTypeId
    }
}
