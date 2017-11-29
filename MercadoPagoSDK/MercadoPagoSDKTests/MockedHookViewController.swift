//
//  MockedHookViewController.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

open class MockedHookViewController: UIViewController, PXHookComponent {

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

    public func hookForStep() -> PXHookStep {
        return hookStep!
    }

    public func render() -> UIView {
        return self.view
    }

    public func renderDidFinish() {

    }
    
    public func shouldSkipHook(hookStore: PXHookStore) -> Bool {
        return shouldSkipHook
    }

    public func titleForNavigationBar() -> String? {
        return nil
    }

    public func colorForNavigationBar() -> UIColor? {
        return nil
    }

    public func shouldShowBackArrow() -> Bool {
        return true
    }

    public func shouldShowNavigationBar() -> Bool {
        return true
    }
}
