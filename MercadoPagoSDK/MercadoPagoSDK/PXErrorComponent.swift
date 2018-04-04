//
//  PXErrorComponent.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 12/4/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoServices

public class PXErrorComponent: NSObject, PXComponentizable {
    var props: PXErrorProps

    init(props: PXErrorProps) {
        self.props = props
    }
    public func render() -> UIView {
        return PXErrorRenderer().render(component: self)
    }
}

class PXErrorProps: NSObject {
    var title: NSAttributedString?
    var message: NSAttributedString?
    var secondaryTitle: NSAttributedString?
    var action: PXComponentAction?

    init(title: NSAttributedString? = nil, message: NSAttributedString? = nil, secondaryTitle: NSAttributedString? = nil, action: PXComponentAction? = nil) {
        self.title = title
        self.message = message
        self.action = action
        self.secondaryTitle = secondaryTitle
    }
}
