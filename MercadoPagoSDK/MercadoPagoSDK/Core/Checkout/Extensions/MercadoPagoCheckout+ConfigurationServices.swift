//
//  MercadoPagoCheckout+ConfigurationServices.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 10/12/18.
//

import Foundation

extension MercadoPagoCheckout {

    func getPayerCostsConfiguration() {
        viewModel.pxNavigationHandler.presentLoading()

        guard let paymentMethod = self.viewModel.paymentData.getPaymentMethod() else {
            return
        }

        let bin = self.viewModel.cardToken?.getBin()

        var diffPricingString: String?
        if let differentialPricing = self.viewModel.checkoutPreference.differentialPricing?.id {
            diffPricingString = String(describing: differentialPricing)
        }

        //summary ammount service should be performed using the processing modes designated by the payment method
        self.viewModel.mercadoPagoServicesAdapter.update(processingModes: paymentMethod.processingModes)
        self.viewModel.mercadoPagoServicesAdapter.getSummaryAmount(bin: bin, amount: self.viewModel.amountHelper.preferenceAmount, issuer: self.viewModel.paymentData.getIssuer(), paymentMethodId: paymentMethod.id, payment_type_id: paymentMethod.paymentTypeId, differentialPricingId: diffPricingString, siteId: self.viewModel.checkoutPreference.siteId, marketplace: self.viewModel.checkoutPreference.marketplace, discountParamsConfiguration: self.viewModel.getAdvancedConfiguration().discountParamsConfiguration, payer: self.viewModel.checkoutPreference.payer, defaultInstallments: self.viewModel.checkoutPreference.getDefaultInstallments(), charges: self.viewModel.amountHelper.chargeRules, maxInstallments: self.viewModel.checkoutPreference.getMaxAcceptedInstallments(), callback: { [weak self] (summaryAmount) in

            guard let strongSelf = self else {
                return
            }
            strongSelf.viewModel.payerCosts = summaryAmount.selectedAmountConfiguration.amountConfiguration?.payerCosts
            if let discountConfig = summaryAmount.selectedAmountConfiguration.discountConfiguration {
                strongSelf.viewModel.attemptToApplyDiscount(discountConfig)
            }
            if let payerCosts = strongSelf.viewModel.payerCosts {
                let defaultPayerCost = strongSelf.viewModel.checkoutPreference.paymentPreference.autoSelectPayerCost(payerCosts)
                if let defaultPC = defaultPayerCost {
                    strongSelf.viewModel.updateCheckoutModel(payerCost: defaultPC)
                }
            }

            strongSelf.executeNextStep()

            }, failure: {[weak self] (error) in

                guard let strongSelf = self else {
                    return
                }

                strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_INSTALLMENTS.rawValue), errorCallback: { [weak self] () in
                    self?.getPayerCostsConfiguration()
                })
                strongSelf.executeNextStep()

        })
    }

}
