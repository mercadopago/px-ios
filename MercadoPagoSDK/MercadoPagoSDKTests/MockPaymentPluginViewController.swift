//
//  MockPaymentPluginViewController.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 12/15/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

open class MockPaymentPluginViewController: UIViewController {

    var shouldSkip = false

    init(shouldSkip: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.shouldSkip = shouldSkip
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Plugin implementation delegates.
extension MockPaymentPluginViewController: PXPluginComponent {

    public func render() -> UIView {
        return self.view
    }

    public func shouldSkip(pluginStore: PXCheckoutStore) -> Bool {
        return shouldSkip
    }
}
