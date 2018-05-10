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
        showPaymentPluginComponent(paymentPluginComponent: paymentMethodPlugin.paymentPlugin)
    }

    func showPaymentMethodPluginConfigScreen() {
        guard let paymentMethodPlugin = self.viewModel.paymentOptionSelected as? PXPaymentMethodPlugin else {
            return
        }

        let containerVC = PXPluginConfigViewController()

        guard let paymentMethodConfigPluginComponent = paymentMethodPlugin.paymentMethodConfigPlugin else {
            return
        }
        containerVC.pluginComponentInterface = paymentMethodConfigPluginComponent
        containerVC.paymentMethodId = paymentMethodPlugin.getId()
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

        if let paymentMethodConfigPluginComponentView = paymentMethodConfigPluginComponent.render(store: PXCheckoutStore(), theme: ThemeManager.shared.getCurrentTheme()) {
            paymentMethodConfigPluginComponentView.removeFromSuperview()
            paymentMethodConfigPluginComponentView.frame = containerVC.view.frame
            containerVC.view.addSubview(paymentMethodConfigPluginComponentView)
        }

        paymentMethodConfigPluginComponent.renderDidFinish?()

        self.pushViewController(viewController: containerVC, animated: true)
    }

    fileprivate func showPaymentPluginComponent(paymentPluginComponent: PXPluginComponent) {
        let containerVC = MercadoPagoUIViewController()

        // By feature definition. Back is not available in make payment plugin.
        containerVC.shouldShowBackArrow = false

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

        if let paymentPluginComponentView = paymentPluginComponent.render(store: PXCheckoutStore.sharedInstance, theme: ThemeManager.shared.getCurrentTheme()) {
            paymentPluginComponentView.removeFromSuperview()
            paymentPluginComponentView.frame = containerVC.view.frame
            paymentPluginComponentView.backgroundColor = ThemeManager.shared.highlightBackgroundColor()
            containerVC.view.addSubview(paymentPluginComponentView)
        }

        //TODO: Change in Q2 - Payment processor by block. Not a view.
        containerVC.view.backgroundColor = ThemeManager.shared.highlightBackgroundColor()
        paymentPluginComponent.renderDidFinish?()

        self.navigationController.pushViewController(containerVC, animated: false)
    }
}

// MARK: Payment Plugin
extension MercadoPagoCheckout {
    func showPaymentPluginScreen() {
        guard let paymentPluginComponent = self.viewModel.paymentPlugin else {
            return
        }
        showPaymentPluginComponent(paymentPluginComponent: paymentPluginComponent)
    }
}
