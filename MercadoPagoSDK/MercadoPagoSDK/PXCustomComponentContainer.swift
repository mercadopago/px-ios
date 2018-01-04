//
//  PxCustomComponentContainer.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 19/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PXCustomComponentContainer: PXComponentizable {
    let customComponent: PXComponentizable

    init(withComponent customComponent: PXComponentizable) {
        self.customComponent = customComponent
    }
    func render() -> UIView {
        let componentView = UIView()
        componentView.translatesAutoresizingMaskIntoConstraints = false
        let customComponentView = customComponent.render()
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
