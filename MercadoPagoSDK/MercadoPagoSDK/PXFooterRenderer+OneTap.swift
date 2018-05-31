//
//  PXFooterRenderer+OneTap.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 16/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension PXFooterRenderer {
    func oneTapRender(_ footer: PXFooterComponent) -> PXFooterView {
        let fooView = PXFooterView()
        fooView.translatesAutoresizingMaskIntoConstraints = false
        fooView.backgroundColor = .clear
        if let principalAction = footer.props.buttonAction {
            let principalButton = self.buildPrincipalButton(with: principalAction, color: footer.props.primaryColor)
            fooView.principalButton = principalButton
            fooView.addSubview(principalButton)
            PXLayout.pinTop(view: principalButton, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.pinLeft(view: principalButton, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.pinRight(view: principalButton, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.setHeight(owner: fooView, height: BUTTON_HEIGHT+PXLayout.XXL_MARGIN).isActive = true
            PXLayout.setHeight(owner: principalButton, height: BUTTON_HEIGHT).isActive = true
        }
        return fooView
    }
}
