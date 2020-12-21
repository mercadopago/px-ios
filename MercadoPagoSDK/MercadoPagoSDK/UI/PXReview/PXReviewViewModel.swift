//
//  PXReviewViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 27/2/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXReviewViewModel: NSObject {

    static let ERROR_DELTA = 0.001
    public static var CUSTOMER_ID = ""

    internal var amountHelper: PXAmountHelper
    var paymentOptionSelected: PaymentMethodOption?
    var advancedConfiguration: PXAdvancedConfiguration
    var userLogged: Bool

    public init(amountHelper: PXAmountHelper, paymentOptionSelected: PaymentMethodOption?, advancedConfig: PXAdvancedConfiguration, userLogged: Bool) {
        PXReviewViewModel.CUSTOMER_ID = ""
        self.amountHelper = amountHelper
        self.paymentOptionSelected = paymentOptionSelected
        self.advancedConfiguration = advancedConfig
        self.userLogged = userLogged
    }

    func shouldValidateWithBiometric(withCardId: String? = nil) -> Bool {
        // Validation is mandatory for payment methods != (credit or debit card).
        if !isPaymentMethodDebitOrCredit() { return true }

        if PXConfiguratorManager.escProtocol.hasESCEnable() {
            let savedCardIds = PXConfiguratorManager.escProtocol.getSavedCardIds(config: PXConfiguratorManager.escConfig)
            // If we found cardId in ESC, we should validate with biometric.
            if let targetCardId = withCardId {
                return savedCardIds.contains(targetCardId)
            } else if let currentCard = paymentOptionSelected as? PXCardInformation {
                return savedCardIds.contains(currentCard.getCardId())
            }
        }

        // ESC is not enabled or cardId not found.
        // We should´t validate with Biometric.
        return false
    }

    func validateWithBiometric(onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        let config = PXConfiguratorManager.biometricConfig
        config.setAmount(NSDecimalNumber(value: amountHelper.amountToPay))
        PXConfiguratorManager.biometricProtocol.validate(config: PXConfiguratorManager.biometricConfig, onSuccess: onSuccess, onError: onError)
    }
}

// MARK: - Logic.
extension PXReviewViewModel {
    // Logic.
    func isPaymentMethodDebitOrCredit() -> Bool {
        guard let pMethod = amountHelper.getPaymentData().getPaymentMethod() else { return false }
        return pMethod.isDebitCard || pMethod.isCreditCard
    }

    func shouldShowCreditsTermsAndConditions() -> Bool {
        guard let termsAndConditions = amountHelper.getPaymentData().getPaymentMethod()?.creditsDisplayInfo?.termsAndConditions as PXTermsDto?, termsAndConditions.text.isNotEmpty else { return false }
        return true
    }
}

// MARK: - Getters
extension PXReviewViewModel {
    func getClearPaymentData() -> PXPaymentData {
        let newPaymentData: PXPaymentData = self.amountHelper.getPaymentData().copy() as? PXPaymentData ?? self.amountHelper.getPaymentData()
        newPaymentData.clearCollectedData()
        return newPaymentData
    }
}

// MARK: Item component
extension PXReviewViewModel {

    // HotFix: TODO - Move to OneTapViewModel
    func buildOneTapItemComponents() -> [PXItemComponent] {
        var pxItemComponents = [PXItemComponent]()
        if advancedConfiguration.reviewConfirmConfiguration.hasItemsEnabled() {
            for item in self.amountHelper.preference.items {
                if let itemComponent = buildOneTapItemComponent(item: item) {
                    pxItemComponents.append(itemComponent)
                }
            }
        }
        return pxItemComponents
    }

    // HotFix: TODO - Move to OneTapViewModel
    private func buildOneTapItemComponent(item: PXItem) -> PXItemComponent? {
        let itemQuantiy = item.quantity
        let itemPrice = item.unitPrice
        let itemTitle = item.title
        let itemDescription = item._description

        let itemTheme: PXItemComponentProps.ItemTheme = (backgroundColor: ThemeManager.shared.detailedBackgroundColor(), boldLabelColor: ThemeManager.shared.boldLabelTintColor(), lightLabelColor: ThemeManager.shared.labelTintColor())

        let itemProps = PXItemComponentProps(imageURL: item.pictureUrl, title: itemTitle, description: itemDescription, quantity: itemQuantiy, unitAmount: itemPrice, amountTitle: "", quantityTitle: "", collectorImage: nil, itemTheme: itemTheme)
        return PXItemComponent(props: itemProps)
    }
}
