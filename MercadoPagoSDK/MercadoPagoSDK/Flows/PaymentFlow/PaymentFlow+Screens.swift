//
//  PaymentFlow+Screens.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 18/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
extension PXPaymentFlow {
    func showPaymentPluginComponent(paymentPluginComponent: PXPaymentPluginComponent?) {

        guard let paymentPluginComponent = paymentPluginComponent else {
            return
        }

        let containerVC = PXPaymentPluginViewController()

        // By feature definition. Back is not available in make payment plugin.
        containerVC.shouldShowBackArrow = false

        model.assignToCheckoutStore()
        paymentPluginComponent.didReceive?(pluginStore: PXCheckoutStore.sharedInstance)

        // Create navigation handler.
        paymentPluginComponent.navigationHandlerForPaymentPlugin?(navigationHandler: PXPaymentPluginNavigationHandler(flow: self))

        if let navTitle = paymentPluginComponent.titleForNavigationBar?() {
            containerVC.title = navTitle
        }

        if let navBarColor = paymentPluginComponent.colorForNavigationBar?() {
            containerVC.setNavBarBackgroundColor(color: navBarColor)
        }

        if let shouldShowNavigationBar = paymentPluginComponent.shouldShowNavigationBar?() {
            containerVC.shouldHideNavigationBar = !shouldShowNavigationBar
        }

        if let paymentPluginComponentView = paymentPluginComponent.render(store: PXCheckoutStore.sharedInstance, theme: ThemeManager.shared.getCurrentTheme()) {
            paymentPluginComponentView.removeFromSuperview()
            paymentPluginComponentView.frame = containerVC.view.frame
            paymentPluginComponentView.backgroundColor = ThemeManager.shared.highlightBackgroundColor()
            containerVC.view.addSubview(paymentPluginComponentView)
        }

        containerVC.view.backgroundColor = ThemeManager.shared.highlightBackgroundColor()
        paymentPluginComponent.renderDidFinish?()

        self.pxNavigationHandler.navigationController.pushViewController(containerVC, animated: false)
    }
}
