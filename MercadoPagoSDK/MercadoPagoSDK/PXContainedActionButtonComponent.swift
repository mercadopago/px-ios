//
//  PXContainedActionButtonComponent.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 23/1/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXContainedActionButtonComponent: PXComponentizable {
    public func render() -> UIView {
        return PXContainedActionButtonRenderer().render(self)
    }

    var props: PXContainedActionButtonProps

    init(props: PXContainedActionButtonProps) {
        self.props = props
    }
}

/** :nodoc: */
open class PXContainedActionButtonProps: NSObject {
    let title: String
    let action : (() -> Void)
    let backgroundColor: UIColor
    var animationDelegate: PXAnimatedButtonDelegate?
    init(title: String, action:  @escaping (() -> Void), animationDelegate: PXAnimatedButtonDelegate? = nil) {
        self.title = title
        self.action = action
        self.backgroundColor = .white
        self.animationDelegate = animationDelegate
    }
}
