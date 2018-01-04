//
//  TestComponent.swift
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Demian Tejo on 19/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoSDK

@objc public class TestComponent: NSObject, PXComponentizable {

    static public func getPreference() -> PaymentResultScreenPreference {
        let top = TestComponent()
        let bottom = TestComponent()
        let preference = PaymentResultScreenPreference()
        preference.disableApprovedReceipt()
       // preference.setApprovedTopCustomComponent(top)
        //        preference.setApprovedBottomCustomComponent(bottom)
        return preference
    }

    public func render() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 100))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }
}
