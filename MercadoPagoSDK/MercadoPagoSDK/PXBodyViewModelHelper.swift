//
//  PXBodyViewModelHelper.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 11/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

extension PXResultViewModel {

    open func getBodyComponentProps() -> PXBodyProps {
        let props = PXBodyProps(paymentResult: self.paymentResult, amount: self.amount, instruction: getInstrucion(), callback: getBodyAction())
        return props
    }

    open func getInstrucion() -> Instruction? {
        guard let instructionsInfo = self.instructionsInfo else {
            return nil
        }
        return instructionsInfo.getInstruction()
    }

    func getBodyAction() -> (() -> Void) {
        return { self.executeBodyCallback() }
    }

    open func getTopCustomComponent() -> PXComponentizable? {
        if let customComponent = preference.getApprovedTopCustomComponent(), self.paymentResult.isApproved() {
            return PXCustomComponentContainer(withComponent: customComponent)
        }else {
            return nil
        }
    }

    open func getBottomCustomComponent() -> PXComponentizable? {
        if let customComponent = preference.getApprovedBottomCustomComponent(), self.paymentResult.isApproved() {
            return PXCustomComponentContainer(withComponent: customComponent)
        }else {
            return nil
        }
    }

    func executeBodyCallback() {
        self.callback(PaymentResult.CongratsState.call_FOR_AUTH)
    }
}
