//
//  MercadoPagoCheckout+RemedyServices.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 17/03/2020.
//

import Foundation

extension MercadoPagoCheckout {

    private func getAlternativePayerPaymentMethods(from customOptionSearchItems: [PXCustomOptionSearchItem]?) -> [PXRemedyPaymentMethod]? {
        guard let customOptionSearchItems = customOptionSearchItems else { return nil }

        var alternativePayerPaymentMethods: [PXRemedyPaymentMethod] = []
        for customOptionSearchItem in customOptionSearchItems {
            let oneTapCard = getOneTapCard(cardId: customOptionSearchItem.id)
            let installments = getInstallments(from: customOptionSearchItem.selectedPaymentOption?.payerCosts)
            let alternativePayerPaymentMethod = PXRemedyPaymentMethod(customOptionId: customOptionSearchItem.id,
                                                                                paymentMethodId: customOptionSearchItem.paymentMethodId,
                                                                                paymentTypeId: customOptionSearchItem.paymentTypeId,
                                                                                escStatus: customOptionSearchItem.escStatus ?? "not_available",
                                                                                issuerName: customOptionSearchItem.issuer?.name,
                                                                                lastFourDigit: customOptionSearchItem.lastFourDigits,
                                                                                securityCodeLocation: oneTapCard?.cardUI?.securityCode?.cardLocation,
                                                                                securityCodeLength: oneTapCard?.cardUI?.securityCode?.length,
                                                                                installmentsList: installments,
                                                                                installment: nil)
            alternativePayerPaymentMethods.append(alternativePayerPaymentMethod)
        }
        return alternativePayerPaymentMethods
    }

    private func getOneTapCard(cardId: String) -> PXOneTapCardDto? {
        return viewModel.search?.oneTap?.first(where: { $0.oneTapCard?.cardId == cardId })?.oneTapCard
    }

    private func getInstallments(from payerCosts: [PXPayerCost]?) -> [PXPaymentMethodInstallment]? {
        guard let payerCosts = payerCosts else { return nil }

        var paymentMethodInstallments: [PXPaymentMethodInstallment] = []
        for payerCost in payerCosts {
            let paymentMethodInstallment = PXPaymentMethodInstallment(installments: payerCost.installments,
                                                                      totalAmount: payerCost.totalAmount)
            paymentMethodInstallments.append(paymentMethodInstallment)
        }
        return paymentMethodInstallments
    }

    func getRemedy() {
        guard let paymentId = viewModel.paymentResult?.paymentId,
            let payerCost = viewModel.paymentResult?.paymentData?.payerCost,
            let cardId = viewModel.paymentResult?.cardId,
            let oneTapCard = getOneTapCard(cardId: cardId) else {
            return
        }

        guard let customOptionSearchItem = viewModel.search?.payerPaymentMethods.first(where: { $0.id == cardId}),
            customOptionSearchItem.isCustomerPaymentMethod() &&
            customOptionSearchItem.paymentTypeId != PXPaymentTypes.ACCOUNT_MONEY.rawValue &&
            customOptionSearchItem.paymentTypeId != PXPaymentTypes.CONSUMER_CREDITS.rawValue else {
            return
        }

        let payerPaymentMethodRejected = PXPayerPaymentMethodRejected(customOptionId: customOptionSearchItem.id,
                                                                      paymentMethodId: customOptionSearchItem.paymentMethodId,
                                                                      paymentTypeId: customOptionSearchItem.paymentTypeId,
                                                                      issuerName: customOptionSearchItem.issuer?.name,
                                                                      lastFourDigit: customOptionSearchItem.lastFourDigits,
                                                                      securityCodeLocation: oneTapCard.cardUI?.securityCode?.cardLocation,
                                                                      securityCodeLength: oneTapCard.cardUI?.securityCode?.length,
                                                                      totalAmount: payerCost.totalAmount,
                                                                      installments: payerCost.installments,
                                                                      escStatus: customOptionSearchItem.escStatus)

        let remainingPayerPaymentMethods = viewModel.search?.payerPaymentMethods.filter { $0.id != cardId }
        let alternativePayerPaymentMethods = getAlternativePayerPaymentMethods(from: remainingPayerPaymentMethods)
        let oneTap = viewModel.search?.oneTap != nil

        viewModel.mercadoPagoServices.getRemedy(for: paymentId, payerPaymentMethodRejected: payerPaymentMethodRejected, alternativePayerPaymentMethods: alternativePayerPaymentMethods, oneTap: oneTap, success: { [weak self] remedy in
            guard let self = self else { return }
            self.viewModel.updateCheckoutModel(remedy: remedy)
            self.executeNextStep()
        }, failure: { [weak self] error in
            guard let self = self else { return }
            printDebug(error)
            self.viewModel.updateCheckoutModel(remedy: PXRemedy(cvv: nil, highRisk: nil, callForAuth: nil, suggestedPaymentMethod: nil, trackingData: nil))
            self.executeNextStep()
        })
    }
}
