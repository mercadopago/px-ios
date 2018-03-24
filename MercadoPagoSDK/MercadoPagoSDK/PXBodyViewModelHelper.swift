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

    func buildBodyComponent() -> PXComponentizable? {
        let bodyProps = getBodyComponentProps()
        return PXBodyComponent(props: bodyProps)
    }
}

// MARK: Build Helpers
extension PXResultViewModel {
    func getBodyAction() -> (() -> Void) {
        return { [weak self]  in self?.executeBodyCallback() }
    }

    func executeBodyCallback() {
        self.callback(PaymentResult.CongratsState.call_FOR_AUTH)
    }

    open func getInstrucion() -> Instruction? {
        guard let instructionsInfo = self.instructionsInfo else {
            return nil
        }
        return instructionsInfo.getInstruction()
    }
}
