//
//  PaymentOptionDrawable.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objc
public protocol PaymentOptionDrawable {
    func getImage() -> UIImage?

    func getTitle() -> String

    func getSubtitle() -> String?
}

@objc
public protocol PaymentMethodOption {
    func getId() -> String

    func getDescription() -> String

    func getComment() -> String

    func hasChildren() -> Bool

    func getChildren() -> [PaymentMethodOption]?

    func isCard() -> Bool

    func isCustomerPaymentMethod() -> Bool
}
