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

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Plugin implementation delegates.
extension MockPaymentPluginViewController: PXPaymentPluginComponent {

    public func render(store: PXCheckoutStore, theme: PXTheme) -> UIView? {
        return self.view
    }
}
