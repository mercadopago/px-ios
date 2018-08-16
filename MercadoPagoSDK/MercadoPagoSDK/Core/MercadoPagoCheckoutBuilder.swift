//
//  MercadoPagoCheckoutBuilder.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 9/8/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

@objcMembers
open class MercadoPagoCheckoutBuilder: NSObject {
    internal let publicKey: String
    internal var preferenceId: String?
    internal var checkoutPreference: CheckoutPreference?

    internal var privateKey: String?

    internal var paymentConfig: PXPaymentConfiguration?
    internal var advancedConfig: PXAdvancedConfiguration?

    internal var defaultUIColor: UIColor?

    public init(publicKey: String, preferenceId: String) {
        self.publicKey = publicKey
        self.preferenceId = preferenceId
    }

    public init(publicKey: String, checkoutPreference: CheckoutPreference, paymentConfiguration: PXPaymentConfiguration) {
        self.publicKey = publicKey
        self.checkoutPreference = checkoutPreference
        self.paymentConfig = paymentConfiguration
    }
}

// MARK: - Builder
extension MercadoPagoCheckoutBuilder {
    open func setPrivateKey(key: String) -> MercadoPagoCheckoutBuilder {
        self.privateKey = key
        return self
    }

    open func setAdvancedConfiguration(config: PXAdvancedConfiguration) -> MercadoPagoCheckoutBuilder {
        self.advancedConfig = config
        return self
    }

    open func setColor(checkoutColor: UIColor) -> MercadoPagoCheckoutBuilder {
        self.defaultUIColor = checkoutColor
        return self
    }

    open func setLanguage(string: String) -> MercadoPagoCheckoutBuilder {
        MercadoPagoContext.setLanguage(string: string) //TODO: MercadoPagoContext (Internal refactor)
        return self
    }

    /*
     open func setPaymentConfiguration(config: PXPaymentConfiguration) -> MercadoPagoCheckoutBuilder {
     self.paymentConfig = config
     return self
     }*/
}
