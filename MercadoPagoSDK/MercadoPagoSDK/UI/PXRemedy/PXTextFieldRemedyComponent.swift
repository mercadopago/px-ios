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
    var hint: NSAttributedString?

    init(title: NSAttributedString? = nil, hint: NSAttributedString? = nil) {
        self.title = title
        self.hint = hint
    }
}
