//
//  PxCustomComponentContainer.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 19/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PXCustomComponentContainer: PXCustomComponentizable {
    let customComponent: PXCustomComponentizable

    init(withComponent customComponent: PXCustomComponentizable) {
        self.customComponent = customComponent
    }
    func render(store: PXCheckoutStore, theme: PXTheme) -> UIView? {
        let componentView = UIView()
        componentView.translatesAutoresizingMaskIntoConstraints = false

        guard let customComponentView = customComponent.render(store: store, theme: theme) else {
            return nil
        }

        customComponentView.translatesAutoresizingMaskIntoConstraints = false
        PXLayout.setHeight(owner: customComponentView, height: customComponentView.frame.height).isActive = true
        componentView.addSubview(customComponentView)
        PXLayout.centerHorizontally(view: customComponentView).isActive = true
        PXLayout.pinTop(view: customComponentView).isActive = true
        PXLayout.pinBottom(view: customComponentView).isActive = true
        PXLayout.matchWidth(ofView: customComponentView).isActive = true
        return componentView
    }
}
