//
//  PXHookComponent.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

@objc
public protocol PXHookComponent: PXComponetizable {
    func hookForStep() -> PXHookStep
    func render() -> UIView
    func renderDidFinish()
    func didReceive(hookStore: HookStore)
    func titleForNavigationBar() -> String?
    func colorForNavigationBar() -> UIColor?
    func shouldShowBackArrow() -> Bool
    func shouldShowNavigationBar() -> Bool
}
