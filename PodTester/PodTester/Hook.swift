//
//  Hook.swift
//  PodTester
//
//  Created by Eden Torres on 11/22/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import Foundation
import UIKit
import MercadoPagoSDK

open class Hook: Hookeable {
    public func renderDidFinish() {

    }

    public func getStep() -> HookStep {
        return HookStep.STEP1
    }

    public func render() -> UIView {

        let label = UILabel(frame: CGRect(x: 200, y: 200, width: 100, height: 100))
        label.text = "Soy un hook"
        return label
    }

    public func didRecive(hookStore: HookStore) {
        
    }

    public func didRecive(action: MPAction) {
    }
}
