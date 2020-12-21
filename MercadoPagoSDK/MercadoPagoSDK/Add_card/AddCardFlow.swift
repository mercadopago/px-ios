//
//  AddCardFlow.swift
//  MercadoPagoSDK
//
//  Created by Diego Flores Domenech on 6/9/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

@available(*, deprecated, message: "Old CardForm flow will no longer be available")
@objc public protocol AddCardFlowProtocol {
    func addCardFlowSucceded(result: [String: Any])
    func addCardFlowFailed(shouldRestart: Bool)
}

@available(*, deprecated, message: "Old CardForm flow will no longer be available")
@objcMembers
public class AddCardFlow: NSObject, PXFlow {

    public weak var delegate: AddCardFlowProtocol?

    @available(*, deprecated, message: "Old CardForm flow will no longer be available")
    public convenience init(accessToken: String, locale: String, navigationController: UINavigationController, shouldSkipCongrats: Bool) {
        self.init(accessToken: accessToken, locale: locale, navigationController: navigationController)
    }

    @available(*, deprecated, message: "Old CardForm flow will no longer be available")
    public init(accessToken: String, locale: String, navigationController: UINavigationController) {
        super.init()
    }

    public func setSiteId(_ siteId: String) {
    }

    open func setProductId(_ productId: String) {
    }

    @available(*, deprecated, message: "Old CardForm flow will no longer be available")
    public func start() {
    }

    public func setTheme(theme: PXTheme) {
    }

    func executeNextStep() {
    }

    func cancelFlow() {
    }

    func finishFlow() {
    }

    func exitCheckout() {
    }

    // MARK: steps

    private func finish() {

    }

    private func reset() {
    }

    @objc private func goBack() {
    }

}
