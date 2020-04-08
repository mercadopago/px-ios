//
//  MercadoPagoCheckout+RemedyServices.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 17/03/2020.
//

import Foundation

extension MercadoPagoCheckout {

    private func getAlternativePayerPaymentMethods(from payerPaymentMethods: [PXCustomOptionSearchItem]?) -> [PXAlternativePayerPaymentMethod]? {
        guard let payerPaymentMethods = payerPaymentMethods else { return nil }
        
        var alternativePayerPaymentMethods: [PXAlternativePayerPaymentMethod] = []
        for payerPaymentMethod in payerPaymentMethods {
            if let paymentMethodId = payerPaymentMethod.paymentMethodId,
                let paymentTypeId = payerPaymentMethod.paymentTypeId {
                let installments = getInstallments(from: payerPaymentMethod.selectedPaymentOption?.payerCosts)
                let alternativePayerPaymentMethod = PXAlternativePayerPaymentMethod(paymentMethodId: paymentMethodId,
                                                                                    paymentTypeId: paymentTypeId,
                                                                                    installments: installments,
                                                                                    selectedPayerCostIndex: payerPaymentMethod.selectedPaymentOption?.selectedPayerCostIndex ?? 0,
                                                                                    esc: hasSavedESC(customOptionSearchItem: payerPaymentMethod))
                alternativePayerPaymentMethods.append(alternativePayerPaymentMethod)
            }
        }
        return alternativePayerPaymentMethods
    }

    private func getInstallments(from payerCosts: [PXPayerCost]?) -> [PXPaymentMethodInstallment]? {
        guard let payerCosts = payerCosts else { return nil }

        var paymentMethodInstallments: [PXPaymentMethodInstallment] = []
        for payerCost in payerCosts {
            let paymentMethodInstallment = PXPaymentMethodInstallment(installments: payerCost.installments,
                                                                      totalAmount: payerCost.totalAmount,
                                                                      labels: payerCost.labels,
                                                                      recommendedMessage: payerCost.recommendedMessage)
            paymentMethodInstallments.append(paymentMethodInstallment)
        }
        return paymentMethodInstallments
    }

    private func hasSavedESC(customOptionSearchItem: PXCustomOptionSearchItem) -> Bool {
        let customerPaymentMethod = customOptionSearchItem.getCustomerPaymentMethod()
        guard customerPaymentMethod.isCard() else {
            return false
        }
        return viewModel.escManager?.getESC(cardId: customerPaymentMethod.getCardId(), firstSixDigits: customerPaymentMethod.getFirstSixDigits(), lastFourDigits: customerPaymentMethod.getCardLastForDigits()) == nil ? false : true
    }

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

        let remainingPayerPaymentMethods = viewModel.search?.payerPaymentMethods.filter { $0.id != paymentOptionSelectedId }
        let alternativePayerPaymentMethods = getAlternativePayerPaymentMethods(from: remainingPayerPaymentMethods)

        //viewModel.pxNavigationHandler.presentLoading()
        viewModel.mercadoPagoServices.getRemedy(for: paymentId, payerPaymentMethodRejected: payerPaymentMethodRejected, alternativePayerPaymentMethods: alternativePayerPaymentMethods, success: { [weak self] remedy in
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
