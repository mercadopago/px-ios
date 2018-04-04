//
//  PXPluginConfigViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/2/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

internal class PXPluginConfigViewController: MercadoPagoUIViewController {
    override open var screenName: String { return "CONFIG_PAYMENT_METHOD_" + paymentMethodId }
    override open var screenId: String { return "CONFIG_PAYMENT_METHOD_" + paymentMethodId }

    open var paymentMethodId: String = ""
}
