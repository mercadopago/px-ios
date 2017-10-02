//
//  PayerInfoFlowViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

public enum PayerInfoFlowStep: String {
    case START
    case SCREEN_ERROR
}
class PayerInfoFlowViewModel: NSObject {
    var paymenData: PaymentData
    var payer: Payer
    init(paymenData: PaymentData) {
        self.paymenData = paymenData
        self.payer = paymenData.payer
    }
    public func nextStep() -> PayerInfoFlowStep {
        return PayerInfoFlowStep.START
    }
}
