//
//  PXPluginComponent.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 12/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
@objc
public protocol PXPluginComponent: PXComponetizable {
    func render() -> UIView
    @objc optional func shouldSkip(pluginStore: PXCheckoutStore) -> Bool
    @objc optional func didReceive(pluginStore: PXCheckoutStore)
    @objc optional func renderDidFinish()
    @objc optional func navigationHandlerForPlugin(navigationHandler: PXPluginNavigationHandler)
    @objc optional func titleForNavigationBar() -> String?
    @objc optional func colorForNavigationBar() -> UIColor?
    @objc optional func shouldShowBackArrow() -> Bool
    @objc optional func shouldShowNavigationBar() -> Bool
}
