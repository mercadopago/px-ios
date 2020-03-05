//
//  PXRemedyRenderer.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 05/03/2020.
//

import Foundation

class PXRemedyRenderer: NSObject {

    func render(_ component: PXRemedyComponent) -> UIView {
        if component.isRejectedWithBadFilledSecurityCode() {
            return component.getTextFieldRemedyComponent().render()
        }
        let remedyView = UIView()
        remedyView.translatesAutoresizingMaskIntoConstraints = false
        return remedyView
    }
}
