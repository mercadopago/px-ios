//
//  PXOneTapItemComponent.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 16/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class PXOneTapItemComponent: PXComponentizable {

    var props: PXOneTapItemComponentProps

    init(props: PXOneTapItemComponentProps) {
        self.props = props
    }

    public func render() -> UIView {
        return PXOneTapItemRenderer().oneTapRender(self)
    }
}
