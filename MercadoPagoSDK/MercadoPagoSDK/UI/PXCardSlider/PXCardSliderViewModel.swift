//
//  PXCardSliderViewModel.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 31/10/18.
//

import UIKit
import MLCardDrawer

typealias PXApplicationId = String

final class PXCardSliderViewModel {
    
    private var cardModel: CardModel
    private var accountMoneyBalance: Double?
    
    init(cardModel: CardModel) {
        self.cardModel = cardModel
    }
    
    // MARK: - Public methods
    func trackCard(state: String) {
        MPXTracker.sharedInstance.trackEvent(event: PXCardSliderTrackingEvents.comboSwitch(state))
    }
}

extension PXCardSliderViewModel: PaymentMethodOption {
    func getPaymentType() -> String {
        return cardModel.selectedApplication?.paymentTypeId ?? ""
    }

    func getId() -> String {
        return cardModel.selectedApplication?.paymentMethodId ?? ""
    }

    func hasChildren() -> Bool {
        return false
    }

    func getChildren() -> [PaymentMethodOption]? {
        return nil
    }

    func isCard() -> Bool {
        return PXPaymentTypes.ACCOUNT_MONEY.rawValue != cardModel.selectedApplication?.paymentMethodId
    }

    func isCustomerPaymentMethod() -> Bool {
        return PXPaymentTypes.ACCOUNT_MONEY.rawValue != cardModel.selectedApplication?.paymentMethodId
    }

    func shouldShowInstallmentsHeader() -> Bool {
        guard let selectedApplication = cardModel.selectedApplication else { return false }
        return !selectedApplication.userDidSelectPayerCost && selectedApplication.status.isUsable()
    }

    func getReimbursement() -> PXInstallmentsConfiguration? {
        guard let selectedApplication = cardModel.selectedApplication else { return nil }
        return selectedApplication.benefits?.reimbursement
    }

    func getInterestFree() -> PXInstallmentsConfiguration? {
        guard let selectedApplication = cardModel.selectedApplication else { return nil }
        return selectedApplication.benefits?.interestFree
    }
    
    func getCardUI() -> CardUI? {
        return cardModel.cardUI
    }
    
    func getCardData() -> CardData? {
        return cardModel.selectedApplication?.cardData
    }
    
    func getProgramId() -> String? {
        return cardModel.selectedApplication?.paymentMethodId
    }
    
    func getSelectedApplication() -> PXCardSliderApplicationData? {
        return cardModel.selectedApplication
    }
    
    func getCardId() -> String? {
        return cardModel.cardId
    }
    
    func getIssuerId() -> String {
        return cardModel.issuerId
    }
    
    func getCreditsViewModel() -> PXCreditsViewModel? {
        return cardModel.creditsViewModel
    }
    
    func getComboSwitch() -> ComboSwitchView? {
        return cardModel.comboSwitch
    }
    
    func setSelectedApplication(id: String) {
        cardModel.selectedApplicationId = id
    }
    
    func getDisplayInfo() -> PXOneTapDisplayInfo? {
        return cardModel.displayInfo
    }
}

// MARK: Setters
extension PXCardSliderViewModel {
    func setAccountMoney(accountMoneyBalance: Double) {
        self.accountMoneyBalance = accountMoneyBalance
    }
}
