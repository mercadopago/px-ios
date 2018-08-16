//
//  PXPluginComponent.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 12/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
@objc public protocol PXConfigPluginComponent: PXPluginComponent {
    @objc optional func shouldSkip(pluginStore: PXCheckoutStore) -> Bool
    @objc optional func shouldShowBackArrow() -> Bool
}

/** :nodoc: */
@objc public protocol PXPaymentPluginComponent: PXPluginComponent {
    @objc optional func support(pluginStore: PXCheckoutStore) -> Bool
    @objc optional func createPayment(pluginStore: PXCheckoutStore, handler: PXPaymentFlowHandlerProtocol, successWithBusinessResult: @escaping ((PXBusinessResult) -> Void), successWithPaymentResult: @escaping  ((PXPaymentPluginResult) -> Void))
    @objc optional func navigationHandlerForPaymentPlugin(navigationHandler: PXPaymentPluginNavigationHandler)
    @objc optional func paymentTimeOut() -> Double
}

/** :nodoc: */
@objc public protocol PXPluginComponent: PXCustomComponentizable {
    func render(store: PXCheckoutStore, theme: PXTheme) -> UIView?
    @objc optional func didReceive(pluginStore: PXCheckoutStore)
    @objc optional func renderDidFinish()
    @objc optional func viewWillAppear()
    @objc optional func viewWillDisappear()
    @objc optional func navigationHandlerForPlugin(navigationHandler: PXPluginNavigationHandler)
    @objc optional func titleForNavigationBar() -> String?
    @objc optional func colorForNavigationBar() -> UIColor?
    @objc optional func shouldShowNavigationBar() -> Bool
}
