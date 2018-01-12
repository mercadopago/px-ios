//
//  PXPaymentMethodPlugin.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 12/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPaymentMethodPlugin: NSObject {

    @objc public enum RemotePaymentStatus: Int {
        case APPROVED
        case REJECTED
    }

    @objc public enum DisplayOrder: Int {
        case TOP
        case BOTTOM
    }

    static let PAYMENT_METHOD_TYPE_ID = PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue

    var id: String
    var name: String
    var _description: String?
    var image: UIImage
    var paymentPlugin: PXPluginComponent
    var paymentMethodConfigPlugin: PXPluginComponent?
    var displayOrder = DisplayOrder.TOP

    public init (id: String, name: String, image: UIImage, description: String?, paymentPlugin: PXPluginComponent) {
        self.id = id
        self.name = name
        self.image = image
        self._description = description
        self.paymentPlugin = paymentPlugin
    }

    open func setPaymentMethodConfig(plugin: PXPluginComponent) {
        self.paymentMethodConfigPlugin = plugin
    }

    open func setDisplayOrder(order: DisplayOrder) {
        self.displayOrder = order
    }
}

// MARK: PXPaymentMethodPlugin as PaymentOptionDrawable/PaymentMethodOption
extension PXPaymentMethodPlugin: PaymentMethodOption, PaymentOptionDrawable {
    public func getId() -> String {
        return id
    }

    public func getDescription() -> String {
        return name
    }

    public func getComment() -> String {
        return ""
    }

    public func hasChildren() -> Bool {
        return false
    }

    public func getChildren() -> [PaymentMethodOption]? {
        return nil
    }

    public func isCard() -> Bool {
        return false
    }

    public func isCustomerPaymentMethod() -> Bool {
        return false
    }

    public func getImage() -> UIImage? {
        return image
    }

    public func getTitle() -> String {
        return name
    }

    public func getSubtitle() -> String? {
        return _description
    }
}
