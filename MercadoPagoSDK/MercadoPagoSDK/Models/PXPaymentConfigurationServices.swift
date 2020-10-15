//
//  PXPaymentConfigurationServices.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 27/11/18.
//

import UIKit

internal class PXPaymentConfigurationServices {

    private var configurations: Set<PXPaymentMethodConfiguration> = []
    private var defaultDiscountConfiguration: PXDiscountConfiguration?

    // Payer Costs for Payment Method
    func getPayerCostsForPaymentMethod(_ id: String, splitPaymentEnabled: Bool = false) -> [PXPayerCost]? {
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(id) {
            if splitPaymentEnabled {
                return paymentOptionConfiguration.amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.payerCosts
            } else {
                return paymentOptionConfiguration.amountConfiguration?.payerCosts
            }
        }
        return nil
    }

    // Amount Configuration for Payment Method
    func getAmountConfigurationForPaymentMethod(_ id: String?) -> PXAmountConfiguration? {
        guard let id = id else {
            return nil
        }
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(id) {
            return paymentOptionConfiguration.amountConfiguration
        }
        return nil
    }

    // Split Configuration for Payment Method
    func getSplitConfigurationForPaymentMethod(_ id: String) -> PXSplitConfiguration? {
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(id) {
            return paymentOptionConfiguration.amountConfiguration?.splitConfiguration
        }
        return nil
    }

    // Selected Payer Cost for Payment Method
    func getSelectedPayerCostsForPaymentMethod(_ id: String, splitPaymentEnabled: Bool = false) -> PXPayerCost? {
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(id) {
            if splitPaymentEnabled {
                return paymentOptionConfiguration.amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.selectedPayerCost
            } else {
                return paymentOptionConfiguration.amountConfiguration?.selectedPayerCost
            }
        }
        return nil
    }

    // Amount to pay without payer cost for Payment Method
    func getAmountToPayWithoutPayerCostForPaymentMethod(_ id: String?) -> Double? {
        guard let id = id else {
            return nil
        }
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(id) {
            return paymentOptionConfiguration.amountConfiguration?.amount
        }
        return nil
    }

    // Discount Info for Payment Method
    func getDiscountInfoForPaymentMethod(_ id: String) -> String? {
        if let configuration = getPaymentMethodConfiguration(id) {
            return configuration.discountInfo
        }
        return nil
    }

    // Credits comment Info for Payment Method
    func getCreditsInfoForPaymentMethod(_ id: String) -> String? {
        if let configuration = getPaymentMethodConfiguration(id) {
            return configuration.getCreditsComment()
        }
        return nil
    }

    // Discount Configuration for Payment Method
    func getDiscountConfigurationForPaymentMethod(_ id: String) -> PXDiscountConfiguration? {
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(id) {
            let discountConfiguration = paymentOptionConfiguration.discountConfiguration
            return discountConfiguration
        }
        return nil
    }

    // Discount Configuration for Payment Method or Default
    func getDiscountConfigurationForPaymentMethodOrDefault(_ id: String?) -> PXDiscountConfiguration? {
        if let id = id, let pmDiscountConfiguration = getDiscountConfigurationForPaymentMethod(id) {
            return pmDiscountConfiguration
        }
        return getDefaultDiscountConfiguration()
    }

    // Default Discount Configuration
    func getDefaultDiscountConfiguration() -> PXDiscountConfiguration? {
        return self.defaultDiscountConfiguration
    }

    // All Configurations
    func getConfigurationsForPaymentMethod(_ id: String) -> [PXPaymentOptionConfiguration]? {
        if let config = getPaymentMethodConfiguration(id) {
            return config.paymentOptionsConfigurations
        }
        return nil
    }

    func getPaymentOptionConfiguration(_ paymentOptionID: String) -> PXPaymentOptionConfiguration? {
        if let configuration = getPaymentMethodConfiguration(paymentOptionID) {
            return configuration.paymentOptionsConfigurations.first(where: { $0.id == configuration.selectedAmountConfiguration })
        }
        return nil
    }

    func getPaymentMethodConfiguration(_ paymentOptionID: String) -> PXPaymentMethodConfiguration? {
        return configurations.first(where: { $0.paymentOptionID == paymentOptionID })
    }

    func setConfigurations(_ configurations: Set<PXPaymentMethodConfiguration>) {
        self.configurations = configurations
    }

    func setDefaultDiscountConfiguration(_ discountConfiguration: PXDiscountConfiguration?) {
        self.defaultDiscountConfiguration = discountConfiguration
    }
}
