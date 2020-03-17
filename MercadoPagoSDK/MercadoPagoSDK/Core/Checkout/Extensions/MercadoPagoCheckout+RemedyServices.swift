//
//  MercadoPagoCheckout+RemedyServices.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 17/03/2020.
//

import Foundation

extension MercadoPagoCheckout {
    func getRemedy() {
        viewModel.pxNavigationHandler.presentLoading()

        viewModel.mercadoPagoServices.getRemedy(success: { [weak self] remedy in
            guard let self = self else { return }
            self.viewModel.updateCheckoutModel(remedy: remedy)
            self.executeNextStep()
        }, failure: { [weak self] error in
            guard let self = self else { return }

            self.executeNextStep()
        })
    }
}
