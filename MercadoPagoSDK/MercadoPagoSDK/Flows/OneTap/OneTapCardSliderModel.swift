//
//  CardSliderModel.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 28/06/21.
//

import MLCardDrawer

struct OneTapCardSliderModel {
    // MARK: - Constants
    let applications: [PXApplicationId: PXCardSliderApplicationData]?
    let issuerId: String
    let cardId: String?
    let creditsViewModel: PXCreditsViewModel?
    let displayInfo: PXOneTapDisplayInfo?
    let comboSwitch: ComboSwitchView?
    
    // MARK: - Variables
    var cardUI: CardUI?
    var accountMoneyBalance: Double?
    
    // MARK: - Stored properties
    var selectedApplicationId: String? {
        didSet {
            self.cardUI = self.selectedApplication?.cardUI
        }
    }
    
    var selectedApplication: PXCardSliderApplicationData? {
        guard let applicationsData = applications, applicationsData.count > 0,
              let selectedApplicationId = selectedApplicationId else { return nil }
        
        return applicationsData[selectedApplicationId] ?? nil
    }
    
    var isCredits: Bool {
        return self.selectedApplication?.paymentMethodId == PXPaymentTypes.CONSUMER_CREDITS.rawValue
    }
    
    init(
        applications: [PXApplicationId: PXCardSliderApplicationData],
        selectedApplicationId: String?,
        issuerId: String,
        cardId: String? = nil,
        creditsViewModel: PXCreditsViewModel? = nil,
        displayInfo: PXOneTapDisplayInfo?,
        comboSwitch: ComboSwitchView?,
        accountMoneyBalance: Double? = nil
    ) {
        self.issuerId = issuerId
        self.cardId = cardId
        self.creditsViewModel = creditsViewModel
        self.displayInfo = displayInfo
        self.comboSwitch = comboSwitch
        self.applications = applications
        self.selectedApplicationId = selectedApplicationId
        self.accountMoneyBalance = accountMoneyBalance
        
        if let selectedApplicationId = selectedApplicationId {
            self.cardUI = applications[selectedApplicationId]?.cardUI
        }
    }
}
