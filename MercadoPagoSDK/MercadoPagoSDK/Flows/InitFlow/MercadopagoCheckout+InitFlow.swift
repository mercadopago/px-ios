//
//  MercadopagoCheckout+InitFlow.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 4/7/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

// MARK: Init flow Protocol
extension MercadoPagoCheckout: InitFlowProtocol {
    func didFailInitFlow(flowError: InitFlowError) {
        if initMode == .lazy {
            initProtocol?.failure(checkout: self)
            trackInitFlowFriction(flowError: flowError)
            #if DEBUG
                print("Error - \(flowError.errorStep.rawValue)")
            #endif
        } else {
            var errorDetail = ""
            #if DEBUG
                errorDetail = flowError.errorStep.rawValue
            #endif
            let customError = MPSDKError(message: "Error".localized, errorDetail: errorDetail, retry: flowError.shouldRetry, requestOrigin: flowError.requestOrigin?.rawValue)
            viewModel.errorInputs(error: customError, errorCallback: { [weak self] in
                if flowError.shouldRetry {
                    if self?.initMode == .normal {
                        self?.viewModel.pxNavigationHandler.presentLoading()
                    }
                    self?.viewModel.initFlow?.setFlowRetry(step: flowError.errorStep)
                    self?.executeNextStep()
                }
            })
            executeNextStep()
        }
    }

    func didFinishInitFlow() {
        if initMode == .lazy && InitFlowRefresh.cardId == nil {
            initProtocol?.didFinish(checkout: self)
        } else {
            executeNextStep()
        }
    }
}
