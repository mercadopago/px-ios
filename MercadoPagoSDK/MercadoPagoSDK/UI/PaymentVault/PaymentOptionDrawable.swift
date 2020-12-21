//
//  PaymentOptionDrawable.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objc
internal protocol PaymentOptionDrawable {
    func getId() -> String

    func getTitle() -> String

    func isDisabled() -> Bool
}

@objc
internal protocol PaymentMethodOption {
    func getId() -> String

    func hasChildren() -> Bool

    func getChildren() -> [PaymentMethodOption]?

    func isCard() -> Bool

    func isCustomerPaymentMethod() -> Bool

    func getPaymentType() -> String

    @objc optional func additionalInfoNeeded() -> Bool
}
