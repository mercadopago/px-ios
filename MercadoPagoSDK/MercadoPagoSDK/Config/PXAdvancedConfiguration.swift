//
//  PXAdvancedConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 30/7/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

/**
 Advanced configuration provides you support for custom checkout functionality/configure special behaviour when checkout is running.
 */
@objcMembers
open class PXAdvancedConfiguration: NSObject {
    /**
     Advanced UI color customization. Use this config to create your custom UI colors based on PXTheme protocol. Also you can use this protocol to customize your fonts.
     */
    open var theme: PXTheme?

    /**
     Add the possibility to configure ESC behaviour.
     If set as true, then saved cards will try to use ESC feature.
     If set as false, then security code will be always asked.
     */
    open var escEnabled: Bool = false

    /**
    Instores usage / money in usage. - Use case: Not all bank deals apply right now to all preferences.
     */
    open var bankDealsEnabled: Bool = true

    /**
     Enable to preset configurations to customize visualization on the 'Review and Confirm screen'
     */
    open var reviewConfirmConfiguration: PXReviewConfirmConfiguration = PXReviewConfirmConfiguration()

    /**
     Enable to preset configurations to customize visualization on the 'Congrats' screen / 'PaymentResult' screen.
     */
    open var paymentResultConfiguration: PXPaymentResultConfiguration = PXPaymentResultConfiguration()

    /**
     Internal use. To force binary mode.
     */
    internal var binaryModeForced: Bool = false
}

extension PXAdvancedConfiguration {
    /**
     Use this method to force the binary mode. (Set binary mode to `TRUE`). If you use this method, you can override any backend configuration related to binary mode flag.
     */
    open func forceBinaryMode() {
        binaryModeForced = true
    }
}
