//
//  PXBusinessResultBodyComponent.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 17/09/2019.
//

import UIKit

class PXBusinessResultBodyComponent: PXComponentizable {
    var paymentMethodComponents: [PXComponentizable]
    var helpMessageComponent: PXComponentizable?
    var creditsExpectationView: UIView?

    init(paymentMethodComponents: [PXComponentizable], helpMessageComponent: PXComponentizable?, creditsExpectationView: UIView?) {
        self.paymentMethodComponents = paymentMethodComponents
        self.helpMessageComponent = helpMessageComponent
        self.creditsExpectationView = creditsExpectationView
    }

    func render() -> UIView {
        let bodyView = UIView()
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        if let helpMessage = self.helpMessageComponent {
            let helpView = helpMessage.render()
            bodyView.addSubview(helpView)
            PXLayout.pinLeft(view: helpView).isActive = true
            PXLayout.pinRight(view: helpView).isActive = true
        }

        for paymentMethodComponent in paymentMethodComponents {
            let pmView = paymentMethodComponent.render()
            pmView.addSeparatorLineToTop(height: 1)
            bodyView.addSubview(pmView)
            PXLayout.put(view: pmView, onBottomOfLastViewOf: bodyView)?.isActive = true
            PXLayout.pinLeft(view: pmView).isActive = true
            PXLayout.pinRight(view: pmView).isActive = true
        }

        if let creditsView = self.creditsExpectationView {
            bodyView.addSubview(creditsView)
            PXLayout.pinLeft(view: creditsView).isActive = true
            PXLayout.pinRight(view: creditsView).isActive = true
            PXLayout.put(view: creditsView, onBottomOfLastViewOf: bodyView)?.isActive = true
        }

        PXLayout.pinFirstSubviewToTop(view: bodyView)?.isActive = true
        PXLayout.pinLastSubviewToBottom(view: bodyView)?.isActive = true
        return bodyView
    }
}

