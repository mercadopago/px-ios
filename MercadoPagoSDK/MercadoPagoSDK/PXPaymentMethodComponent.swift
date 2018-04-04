//
//  PXPaymentMethodComponent.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 24/11/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

public class PXPaymentMethodComponent: NSObject, PXComponentizable {

    var props: PXPaymentMethodProps

    init(props: PXPaymentMethodProps) {
       self.props = props
    }

    func getPaymentMethodIconComponent() -> PXPaymentMethodIconComponent {
        let paymentMethodIconProps = PXPaymentMethodIconProps(paymentMethodIcon: self.props.paymentMethodIcon)
        let paymentMethodIconComponent = PXPaymentMethodIconComponent(props: paymentMethodIconProps)
        return paymentMethodIconComponent
    }
    
    func getInstallmentsIconComponent() -> PXPaymentMethodIconComponent {
        let image = MercadoPago.getImage("mercadopago")
        let paymentMethodIconProps = PXPaymentMethodIconProps(paymentMethodIcon: image)
        let paymentMethodIconComponent = PXPaymentMethodIconComponent(props: paymentMethodIconProps)
        return paymentMethodIconComponent
    }

    public func render() -> UIView {
        return PXPaymentMethodComponentRenderer().render(component: self)
    }
    
    public func expressRender() -> UIView {
        return PXPaymentMethodComponentRenderer().expressRender(component: self)
    }
}

class PXPaymentMethodProps: NSObject {

    let paymentMethodIcon: UIImage?
    let title: NSAttributedString
    let subtitle: NSAttributedString?
    let descriptionTitle: NSAttributedString?
    let descriptionDetail: NSAttributedString?
    let disclaimer: NSAttributedString?
    let action: PXComponentAction?
    let backgroundColor: UIColor
    let lightLabelColor: UIColor
    let boldLabelColor: UIColor

    public init(paymentMethodIcon: UIImage?, title: NSAttributedString, subtitle: NSAttributedString?, descriptionTitle: NSAttributedString?, descriptionDetail: NSAttributedString?, disclaimer: NSAttributedString?, action: PXComponentAction? = nil, backgroundColor: UIColor, lightLabelColor: UIColor, boldLabelColor: UIColor) {
        self.paymentMethodIcon = paymentMethodIcon
        self.title = title
        self.subtitle = subtitle
        self.descriptionTitle = descriptionTitle
        self.descriptionDetail = descriptionDetail
        self.disclaimer = disclaimer
        self.action = action
        self.backgroundColor = backgroundColor
        self.lightLabelColor = lightLabelColor
        self.boldLabelColor = boldLabelColor
    }
}
