//
//  PXBodyRenderer.swift
//  TestAutolayout
//
//  Created by Demian Tejo on 10/19/17.
//  Copyright © 2017 Demian Tejo. All rights reserved.
//

import UIKit

class PXBodyRenderer: NSObject {

    func render(_ body: PXBodyComponent) -> UIView {
        if body.hasInstructions(), let instructionsComponent = body.getInstructionsComponent() {
            return instructionsComponent.render()
        } else if body.props.paymentResult.isApproved() {
            return body.getPaymentMethodComponent().render()
        } else if body.hasBodyError() {
            return body.getBodyErrorComponent().render()
        }
        let bodyView = UIView()
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        return bodyView
    }
}

class PXBodyView: PXComponentView {
}
