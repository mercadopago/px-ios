//
//  PXComponentizable.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
@objc public protocol PXComponentizable {
    func render() -> UIView
    @objc optional func oneTapRender() -> UIView
}

/** :nodoc: */
@objc public protocol PXCustomComponentizable {
    func render(store: PXCheckoutStore, theme: PXTheme) -> UIView?
}

/** :nodoc: */
@objc public protocol PXXibComponentizable {
    func xibName() -> String
    func containerView() -> UIView
    func render() -> UIView
}
