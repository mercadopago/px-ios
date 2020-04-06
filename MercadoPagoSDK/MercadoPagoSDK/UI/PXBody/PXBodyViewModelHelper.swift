//
//  PXBodyViewModelHelper.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 11/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

internal extension PXResultViewModel {
    func buildBodyComponent() -> PXComponentizable? {
        let instruction = instructionsInfo?.getInstruction() ?? nil
        let props = PXBodyProps(paymentResult: paymentResult, amountHelper: amountHelper, instruction: instruction)
        return PXBodyComponent(props: props)
    }
}
