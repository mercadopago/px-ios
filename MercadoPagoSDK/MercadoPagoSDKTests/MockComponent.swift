//
//  MockComponent.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
@objc public class TestComponent: NSObject, PXComponentizable {

    static public func getPreference() -> PaymentResultScreenPreference {
        let top = TestComponent()
        let bottom = TestComponent()
        let preference = PaymentResultScreenPreference()
        preference.setApprovedTopCustomComponent(top)
        return preference
    }

    public func render() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 100))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }
}
