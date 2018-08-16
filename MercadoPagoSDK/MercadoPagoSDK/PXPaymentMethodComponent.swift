//
//  PXPaymentMethodComponent.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 24/11/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

/** :nodoc: */
public class PXPaymentMethodComponent: NSObject, PXComponentizable {
    var props: PXPaymentMethodProps

    init(props: PXPaymentMethodProps) {
       self.props = props
    }

    public func render() -> UIView {
        return PXPaymentMethodComponentRenderer().render(component: self)
    }

    public func oneTapRender() -> UIView {
        return PXPaymentMethodComponentRenderer().oneTapRender(component: self)
    }
}

// MARK: - Helper functions
extension PXPaymentMethodComponent {
    func getPaymentMethodIconComponent() -> PXPaymentMethodIconComponent {
        let paymentMethodIconProps = PXPaymentMethodIconProps(paymentMethodIcon: self.props.paymentMethodIcon)
        let paymentMethodIconComponent = PXPaymentMethodIconComponent(props: paymentMethodIconProps)
        return paymentMethodIconComponent
    }
}
