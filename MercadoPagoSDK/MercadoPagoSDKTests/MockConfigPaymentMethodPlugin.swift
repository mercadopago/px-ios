//
//  MockConfigPaymentMethodPlugin.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 12/15/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

open class MockConfigPaymentMethodPlugin: UIViewController {

    var shouldSkip = false

    init(shouldSkip: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.shouldSkip = shouldSkip
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Plugin implementation delegates.
extension MockConfigPaymentMethodPlugin: PXConfigPluginComponent {

    public func render(store: PXCheckoutStore, theme: PXTheme) -> UIView? {
        return self.view
    }

    public func shouldSkip(pluginStore: PXCheckoutStore) -> Bool {
        return shouldSkip
    }
}
