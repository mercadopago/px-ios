//
//  PXCustomComponent.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXCustomComponent: PXCustomComponentizable, PXComponentizable {

    let view: UIView

    func render() -> UIView {
        return view
    }

    func render(store: PXCheckoutStore, theme: PXTheme) -> UIView? {
        return self.render()
    }

    init(view: UIView) {
        self.view = view
    }
}
