//
//  MercadoPagoCheckout+Screens+Plugins.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 12/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
extension MercadoPagoCheckout {

    func showPaymentMethodPluginPaymentScreen() {

        guard let paymentMethodPlugin = self.viewModel.paymentOptionSelected as? PXPaymentMethodPlugin else {
            return
        }

        let containerVC = MercadoPagoUIViewController()

        // By feature definition. Back is not available in make payment plugin.
        containerVC.shouldShowBackArrow = false

        let paymentPluginComponent = paymentMethodPlugin.paymentPlugin

        if self.viewModel.copyViewModelAndAssignToCheckoutStore() {
            paymentPluginComponent.didReceive?(pluginStore: PXCheckoutStore.sharedInstance)
        }
        
        // Create navigation handler.
        paymentPluginComponent.navigationHandlerForPlugin?(navigationHandler: PXPluginNavigationHandler(withCheckout: self))

        if let navTitle = paymentPluginComponent.titleForNavigationBar?() {
            containerVC.title = navTitle
        }

        if let navBarColor = paymentPluginComponent.colorForNavigationBar?() {
            containerVC.setNavBarBackgroundColor(color: navBarColor)
        }

        if let shouldShowNavigationBar = paymentPluginComponent.shouldShowNavigationBar?() {
            containerVC.shouldHideNavigationBar = !shouldShowNavigationBar
        }

        let paymentPluginComponentView = paymentPluginComponent.render()
        paymentPluginComponentView.removeFromSuperview()
        paymentPluginComponentView.frame = containerVC.view.frame
        containerVC.view.addSubview(paymentPluginComponentView)

        paymentPluginComponent.renderDidFinish?()

        self.navigationController.pushViewController(containerVC, animated: true)
    }

    func showPaymentMethodPluginConfigScreen() {
        guard let paymentMethodPlugin = self.viewModel.paymentOptionSelected as? PXPaymentMethodPlugin else {
            return
        }

        let containerVC = MercadoPagoUIViewController()

        guard let paymentMethodConfigPluginComponent = paymentMethodPlugin.paymentMethodConfigPlugin else {
            return
        }

        if self.viewModel.copyViewModelAndAssignToCheckoutStore() {
            paymentMethodConfigPluginComponent.didReceive?(pluginStore: PXCheckoutStore.sharedInstance)
        }
        
        // Create navigation handler.
        paymentMethodConfigPluginComponent.navigationHandlerForPlugin?(navigationHandler: PXPluginNavigationHandler(withCheckout: self))

        if let navTitle = paymentMethodConfigPluginComponent.titleForNavigationBar?() {
            containerVC.title = navTitle
        }

        if let navBarColor = paymentMethodConfigPluginComponent.colorForNavigationBar?() {
            containerVC.setNavBarBackgroundColor(color: navBarColor)
        }

        containerVC.shouldShowBackArrow = true
        if let shouldShowBackArrow = paymentMethodConfigPluginComponent.shouldShowBackArrow?() {
            containerVC.shouldShowBackArrow = shouldShowBackArrow
        }

        if let shouldShowNavigationBar = paymentMethodConfigPluginComponent.shouldShowNavigationBar?() {
            containerVC.shouldHideNavigationBar = !shouldShowNavigationBar
        }

        let paymentMethodConfigPluginComponentView = paymentMethodConfigPluginComponent.render()

        paymentMethodConfigPluginComponentView.removeFromSuperview()
        paymentMethodConfigPluginComponentView.frame = containerVC.view.frame
        containerVC.view.addSubview(paymentMethodConfigPluginComponentView)

        paymentMethodConfigPluginComponent.renderDidFinish?()

        self.navigationController.pushViewController(containerVC, animated: true)
    }
}
