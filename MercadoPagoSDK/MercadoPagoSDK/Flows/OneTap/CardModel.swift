//
//  CardSliderModel.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 28/06/21.
//

import MLCardDrawer

struct CardModel {
    // MARK: - Constants
    let applications: [PXApplicationId: PXCardSliderApplicationData]?
    let issuerId: String
    let cardId: String?
    let creditsViewModel: PXCreditsViewModel?
    let displayInfo: PXOneTapDisplayInfo?
    let comboSwitch: ComboSwitchView?
    
    // MARK: - Variables
    var cardUI: CardUI?
    
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
    
    init(
        applications: [PXApplicationId: PXCardSliderApplicationData],
        selectedApplicationId: String?,
        issuerId: String,
        cardId: String? = nil,
        creditsViewModel: PXCreditsViewModel? = nil,
        displayInfo: PXOneTapDisplayInfo?,
        comboSwitch: ComboSwitchView?
    ) {
        self.issuerId = issuerId
        self.cardId = cardId
        self.creditsViewModel = creditsViewModel
        self.displayInfo = displayInfo
        self.comboSwitch = comboSwitch
        self.applications = applications
        self.selectedApplicationId = selectedApplicationId
        
        if let selectedApplicationId = selectedApplicationId {
            self.cardUI = applications[selectedApplicationId]?.cardUI
        }
    }

}
