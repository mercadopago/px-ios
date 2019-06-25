//
//  MercadoPagoCheckoutServices.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/18/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

extension MercadoPagoCheckout {

    func getIssuers() {
        viewModel.pxNavigationHandler.presentLoading()
        guard let paymentMethod = self.viewModel.paymentData.getPaymentMethod() else {
            return
        }
        let bin = self.viewModel.cardToken?.getBin()
        
        //issuers service should be performed using the processing modes designated by the payment method
        self.viewModel.mercadoPagoServicesAdapter.update(processingModes: paymentMethod.processingModes)
        self.viewModel.mercadoPagoServicesAdapter.getIssuers(paymentMethodId: paymentMethod.id, bin: bin, callback: { [weak self] (issuers) in

            self?.viewModel.issuers = issuers
            if issuers.count == 1 {
                self?.viewModel.updateCheckoutModel(issuer: issuers[0])
            }
            self?.executeNextStep()

            }, failure: { [weak self] (error) in

                self?.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_ISSUERS.rawValue), errorCallback: { [weak self] () in
                    self?.getIssuers()
                })
                self?.executeNextStep()
        })
    }

    func createPayment() {
        viewModel.invalidESC = false
        let paymentFlow = viewModel.createPaymentFlow(paymentErrorHandler: self)
        paymentFlow.setData(amountHelper: viewModel.amountHelper, checkoutPreference: viewModel.checkoutPreference, resultHandler: self)
        paymentFlow.start()
    }

    func getIdentificationTypes() {
        viewModel.pxNavigationHandler.presentLoading()
        self.viewModel.mercadoPagoServicesAdapter.getIdentificationTypes(callback: { [weak self] (identificationTypes) in

            self?.viewModel.updateCheckoutModel(identificationTypes: identificationTypes)
            self?.executeNextStep()

            }, failure: { [weak self] (error) in

                self?.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_IDENTIFICATION_TYPES.rawValue), errorCallback: { [weak self] () in
                    self?.getIdentificationTypes()
                })
                self?.executeNextStep()
        })
    }
}
