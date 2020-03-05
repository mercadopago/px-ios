//
//  PXTextFieldRemedyComponent.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 05/03/2020.
//

import Foundation

internal class PXTextFieldRemedyComponent: PXComponentizable {
    var props: PXTextFieldRemedyProps

    init(props: PXTextFieldRemedyProps) {
        self.props = props
    }
    func render() -> UIView {
        return PXTextFieldRemedyRenderer().render(component: self)
    }
}

internal class PXTextFieldRemedyProps {
    var title: NSAttributedString?
    var message: NSAttributedString?
    var secondaryTitle: NSAttributedString?
    var action: PXAction?

    init(title: NSAttributedString? = nil, message: NSAttributedString? = nil, secondaryTitle: NSAttributedString? = nil, action: PXAction? = nil) {
        self.title = title
        self.message = message
        self.action = action
        self.secondaryTitle = secondaryTitle
    }
}
