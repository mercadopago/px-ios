//
//  MPCustomRowDelegate.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 3/21/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
@objc public protocol MPCustomRowDelegate {

    @objc optional func invokeCallbackWithPaymentData(rowCallback: ((PaymentData) -> Void))

    @objc optional func invokeCallbackWithPaymentResult(rowCallback: ((PaymentResult) -> Void))

}
