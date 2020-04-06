//
//  MercadoPagoCheckout+RemedyServices.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 17/03/2020.
//

import Foundation

extension MercadoPagoCheckout {
    func getRemedy() {
        guard let paymentId = viewModel.paymentResult?.paymentId,
            let payerCost = viewModel.paymentResult?.paymentData?.payerCost,
            let paymentOptionSelected = viewModel.paymentOptionSelected as? CustomerPaymentMethod else {
            return
        }

        let paymentOptionSelectedId = paymentOptionSelected.getId()
        let isCustomerCard = paymentOptionSelected.isCustomerPaymentMethod() &&
            paymentOptionSelectedId != PXPaymentTypes.ACCOUNT_MONEY.rawValue &&
            paymentOptionSelectedId != PXPaymentTypes.CONSUMER_CREDITS.rawValue

        guard isCustomerCard,
            let customOptionSearchItem = viewModel.search?.payerPaymentMethods.first(where: { $0.id == paymentOptionSelectedId}) else {
            return
        }

        let payerPaymentMethodRejected = PXPayerPaymentMethodRejected(paymentMethodId: customOptionSearchItem.paymentMethodId,
                                                                      paymentTypeId: customOptionSearchItem.paymentTypeId,
                                                                      issuerName: customOptionSearchItem.issuer?.name,
                                                                      lastFourDigit: customOptionSearchItem.lastFourDigits,
                                                                      securityCodeLocation: paymentOptionSelected.securityCode?.cardLocation,
                                                                      securityCodeLength: paymentOptionSelected.securityCode?.length,
                                                                      totalAmount: payerCost.totalAmount,
                                                                      installments: payerCost.installments,
                                                                      esc: viewModel.hasSavedESC())

        //viewModel.pxNavigationHandler.presentLoading()
        viewModel.mercadoPagoServices.getRemedy(for: paymentId, payerPaymentMethodRejected: payerPaymentMethodRejected, success: { [weak self] remedy in
            guard let self = self else { return }
            self.viewModel.updateCheckoutModel(remedy: remedy)
            self.executeNextStep()
        }, failure: { [weak self] error in
            guard let self = self else { return }
            self.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_REMEDY.rawValue), errorCallback: { [weak self] () in
                self?.getRemedy()
            })
            self.executeNextStep()
        })
    }
}
