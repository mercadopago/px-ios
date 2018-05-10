//
//  MercadoPagoCheckout+Screens+Hooks.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 12/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
extension MercadoPagoCheckout {
    func showHookScreen(hookStep: PXHookStep) {

        if let targetHook = MercadoPagoCheckoutViewModel.flowPreference.getHookForStep(hookStep: hookStep) {

            let vc = MercadoPagoUIViewController()
            vc.view.backgroundColor = .clear

            targetHook.navigationHandlerForHook?(navigationHandler: PXHookNavigationHandler(withCheckout: self, targetHook: targetHook.hookForStep()))

            vc.callbackCancel = {
                self.viewModel.wentBackFrom(hook: hookStep)
            }

            if self.viewModel.copyViewModelAndAssignToCheckoutStore() {
                targetHook.didReceive?(hookStore: PXCheckoutStore.sharedInstance)
            }

            if let navTitle = targetHook.titleForNavigationBar?() {
                vc.title = navTitle
            }

            if let navBarColor = targetHook.colorForNavigationBar?() {
                vc.setNavBarBackgroundColor(color: navBarColor)
            }

            vc.shouldShowBackArrow = true
            if let shouldShowBackArrow = targetHook.shouldShowBackArrow?() {
                vc.shouldShowBackArrow = shouldShowBackArrow
            }

            if let shouldShowNavigationBar = targetHook.shouldShowNavigationBar?() {
                vc.shouldHideNavigationBar = !shouldShowNavigationBar
            }

            if let hookView = targetHook.render(store: PXCheckoutStore.sharedInstance, theme: ThemeManager.shared.getCurrentTheme()) {
                hookView.removeFromSuperview()
                hookView.frame = vc.view.frame
                vc.view.addSubview(hookView)
            }

            targetHook.renderDidFinish?()

            self.pushViewController(viewController: vc, animated: true)

            self.viewModel.continueFrom(hook: hookStep)
        }
    }
}
