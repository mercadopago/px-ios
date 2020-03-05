//
//  PXRemedyViewModelHelper.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 05/03/2020.
//

import Foundation

internal extension PXResultViewModel {
    func buildRemedyComponent() -> PXComponentizable? {
        let props = PXRemedyProps(paymentResult: paymentResult, amountHelper: amountHelper)
        return PXRemedyComponent(props: props)
    }
}
