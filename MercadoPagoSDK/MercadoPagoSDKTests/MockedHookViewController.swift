//
//  MockedHookViewController.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

open class MockedHookViewController: UIViewController {

    var hookStep: PXHookStep?
    var shouldSkipHook = false

    init(hookStep: PXHookStep, shouldSkipHook: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.hookStep = hookStep
        self.shouldSkipHook = shouldSkipHook
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Hooks implementation delegates.
extension MockedHookViewController: PXHookComponent {

    public func hookForStep() -> PXHookStep {
        return hookStep!
    }

    public func render() -> UIView {
        return self.view
    }

    public func shouldSkipHook(hookStore: PXCheckoutStore) -> Bool {
        return shouldSkipHook
    }
}
