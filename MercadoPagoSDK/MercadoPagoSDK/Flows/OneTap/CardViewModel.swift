//
//  NewOneTaoViewModel.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 22/06/21.
//

import MLCardDrawer

protocol CardDelegate: AnyObject {
    func cardDidChange(card: CardViewModel)
}

final class CardViewModel {
    // MARK: - Private properties
    private var oneTapModel: OneTapCardDesignModel
    private let installmentsRowMessageFontSize = PXLayout.XS_FONT
    private lazy var dataSource: [PXCardSliderViewModel] = getDataSource()
    private var applications: [PXOneTapApplication] = []
    
    // MARK: - Initialization
    init(oneTapModel: OneTapCardDesignModel) {
        self.oneTapModel = oneTapModel
    }
    
    // MARK: - Public methods
    private func getDataSource() -> [PXCardSliderViewModel] {
        guard let expressData = oneTapModel.expressData else { return [] }
        var sliderModel: [PXCardSliderViewModel] = []
        
        let reArrangedCards = rearrangeDisabledOption(expressData, disabledOption: oneTapModel.disabledOption)
        for card in reArrangedCards {

            // Add New Card and Offline Payment Methods
            if card.newCard != nil || card.offlineMethods != nil {
                sliderModel.append(createOfflineAndCardCreation(with: card))
            }
            //  Account money
            if let accountMoney = card.accountMoney, let paymentMethodId = card.paymentMethodId {
                sliderModel.append(createAccountMoneyCard(cardData: card, accountMoney: accountMoney, paymentMethodId: paymentMethodId))
                
            //  Credit Card
            } else if let oneTapCard = card.oneTapCard,
                      let cardData = getCardData(oneTapCard: oneTapCard) {
                
                if let applications = card.applications, applications.count > 0 {
                    let viewModelCard = getCardSliderViewModelFor(targetNode: card, oneTapCard: oneTapCard, cardData: cardData, applications: applications)
                    sliderModel.append(viewModelCard)
                } else if let paymentMethodId = card.paymentMethodId {
                    var applications : [PXOneTapApplication] = []
                    
                    applications.append(PXOneTapApplication(paymentMethod: PXApplicationPaymentMethod(id: paymentMethodId, type: card.paymentTypeId), validationPrograms: [], status: card.status))
                    
                    let viewModelCard = getCardSliderViewModelFor(targetNode: card, oneTapCard: oneTapCard, cardData: cardData, applications: applications)
                    sliderModel.append(viewModelCard)
                }
                
            } else if let consumerCredits = card.oneTapCreditsInfo,
                      let paymentMethodId = card.paymentMethodId,
                      let amountConfiguration = oneTapModel.amountHelper.paymentConfigurationService.getAmountConfigurationForPaymentMethod(paymentOptionID: paymentMethodId, paymentMethodId: paymentMethodId, paymentTypeId: card.paymentTypeId) {

                sliderModel.append(createMercadoCreditosCard(cardData: card,
                                                             consumerCredits: consumerCredits,
                                                             paymentMethodId: paymentMethodId,
                                                             amountConfiguration: amountConfiguration)
                )
            } else if card.offlineTapCard != nil, let paymentMethodId = card.paymentMethodId {
                sliderModel.append(createPixCard(cardData: card, paymentMethodId: paymentMethodId) )
            }
        }
        
        return []
    }
    
    
    // MARK: - Private methods
    private func rearrangeDisabledOption(_ oneTapNodes: [PXOneTapDto], disabledOption: PXDisabledOption?) -> [PXOneTapDto] {
        guard let disabledOption = disabledOption else { return oneTapNodes }
        var rearrangedNodes = [PXOneTapDto]()
        var disabledNode: PXOneTapDto?
        for node in oneTapNodes {
            if disabledOption.isCardIdDisabled(cardId: node.oneTapCard?.cardId) || disabledOption.isPMDisabled(paymentMethodId: node.paymentMethodId) {
                disabledNode = node
            } else {
                rearrangedNodes.append(node)
            }
        }

        if let disabledNode = disabledNode {
            rearrangedNodes.append(disabledNode)
        }
        return rearrangedNodes
    }
    
    private func getStatusConfig(currentStatus: PXStatus, cardId: String?, paymentMethodId: String?) -> PXStatus {
        guard let disabledOption = oneTapModel.disabledOption else { return currentStatus }

        if disabledOption.isCardIdDisabled(cardId: cardId) || disabledOption.isPMDisabled(paymentMethodId: paymentMethodId) {
            return disabledOption.getStatus() ?? currentStatus
        } else {
            return currentStatus
        }
    }

    private func getPayerPaymentMethod(_ paymentTypeId: String?, _ cardID: String?) -> PXCustomOptionSearchItem? {
        guard let paymentTypeId = paymentTypeId else { return nil }
        for payerPaymentMethod in oneTapModel.payerPaymentMethods {
            switch paymentTypeId {
            case PXPaymentTypes.ACCOUNT_MONEY.rawValue,
                 PXPaymentTypes.DIGITAL_CURRENCY.rawValue:
                if paymentTypeId == payerPaymentMethod.paymentTypeId {
                    return payerPaymentMethod
                }
            case PXPaymentTypes.CREDIT_CARD.rawValue,
                 PXPaymentTypes.DEBIT_CARD.rawValue:
                if cardID == payerPaymentMethod.id && paymentTypeId == payerPaymentMethod.paymentTypeId {
                    return payerPaymentMethod
                }
            default:
                printDebug("PayerPaymentMethod not found")
            }
        }
        return nil
    }

    private func getChargeRuleBottomMessage(_ paymentTypeId: String?) -> String? {
        let chargeRule = getChargeRule(paymentTypeId: paymentTypeId)
        return chargeRule?.message
    }
    
    private func getCardData(oneTapCard: PXOneTapCardDto) -> CardData? {
        guard let cardName = oneTapCard.cardUI?.name,
              let cardNumber = oneTapCard.cardUI?.lastFourDigits,
              let cardExpiration = oneTapCard.cardUI?.expiration else {
            return nil
        }
        let cardData = PXCardDataFactory().create(cardName: cardName.uppercased(), cardNumber: cardNumber, cardCode: "", cardExpiration: cardExpiration, cardPattern: oneTapCard.cardUI?.cardPattern)
        return cardData
    }
    
    private func getCardUI(oneTapCard: PXOneTapCardDto) -> CardUI {
        let templateCard = TemplateCard()
        guard let cardUI = oneTapCard.cardUI else {
            return templateCard
        }
        if let cardPattern = cardUI.cardPattern {
            templateCard.cardPattern = cardPattern
        }
        templateCard.securityCodeLocation = cardUI.securityCode?.cardLocation == "front" ? .front : .back
        if let codeLength = cardUI.securityCode?.length {
            templateCard.securityCodePattern = codeLength
        }
        if let cardBackgroundColor = cardUI.color {
            templateCard.cardBackgroundColor = cardBackgroundColor.hexToUIColor()
        }
        if let cardFontColor = cardUI.fontColor {
            templateCard.cardFontColor = cardFontColor.hexToUIColor()
        }
        if let cardLogoImageUrl = cardUI.paymentMethodImageUrl {
            templateCard.cardLogoImageUrl = cardLogoImageUrl
        }
        if let bankImageUrl = cardUI.issuerImageUrl {
            templateCard.bankImageUrl = bankImageUrl
        }
        return templateCard
    }
    
    private func getCardSliderViewModelFor(targetNode: PXOneTapDto, oneTapCard: PXOneTapCardDto, cardData: CardData, applications: [PXOneTapApplication]) -> PXCardSliderViewModel {
        
        self.applications.append(contentsOf: applications)
        
        let targetIssuerId = oneTapCard.cardUI?.issuerId ?? ""
        
        var cardSliderApplications : [PXApplicationId:PXCardSliderApplicationData] = [:]
    
        for application in applications {
                
            guard let paymentMethodId = application.paymentMethod.id else { continue }
            
            guard let paymentMethodType = application.paymentMethod.type else { continue }
            
            let paymentOptionConfiguration = oneTapModel.amountHelper.paymentConfigurationService.getPaymentOptionConfiguration(paymentOptionID: oneTapCard.cardId, paymentMethodId: paymentMethodId, paymentTypeId: paymentMethodType)
            let amountConfiguration = paymentOptionConfiguration?.amountConfiguration
            let splitEnabled = amountConfiguration?.splitConfiguration?.splitEnabled ?? false
            let defaultPayerCost = [PXPayerCost]()
            let payerCosts = splitEnabled ? amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.payerCosts : amountConfiguration?.payerCosts
            let selectedPayerCost = splitEnabled ? amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.selectedPayerCost : amountConfiguration?.selectedPayerCost

            var showArrow: Bool = true
            var displayMessage: NSAttributedString?
            
            if paymentMethodType == PXPaymentTypes.DEBIT_CARD.rawValue {
                showArrow = false
                if let totalAmount = selectedPayerCost?.totalAmount {
                    // If it's debit and has split, update split message
                    displayMessage = getSplitMessageForDebit(amountToPay: totalAmount)
                }
            } else if payerCosts?.count == 1 {
                showArrow = false
            } else if payerCosts == nil {
                showArrow = false
            }
            
            
            let statusConfig = getStatusConfig(currentStatus: application.status, cardId: targetNode.oneTapCard?.cardId, paymentMethodId: targetNode.paymentMethodId)

            let chargeRuleMessage = getCardBottomMessage(paymentTypeId: paymentMethodType, benefits: targetNode.benefits, status: application.status, selectedPayerCost: selectedPayerCost, displayInfo: targetNode.displayInfo)
            
            let payerPaymentMethod = getPayerPaymentMethod(paymentMethodType, oneTapCard.cardId)
            
            var cardUI = getCardUI(oneTapCard: oneTapCard)
            
            if oneTapCard.cardUI?.displayType == .hybrid {
                let cardLogoImageUrl = targetNode.oneTapCard?.cardUI?.issuerImageUrl
                let paymentMethodImageUrl = targetNode.oneTapCard?.cardUI?.paymentMethodImageUrl
                let color = targetNode.oneTapCard?.cardUI?.color
                // TODO: Check gradient colors
                let gradientColors : [String] = []

                if application.paymentMethod.id == PXPaymentTypes.ACCOUNT_MONEY.rawValue {
                    // If it's hybrid and account_money application
                    cardUI = HybridAMCard(isDisabled: application.status.isDisabled(), cardLogoImageUrl: cardLogoImageUrl, paymentMethodImageUrl: nil, color: color, gradientColors: gradientColors)
                } else {
                    // If it's hybrid but credit_card application
                    cardUI = HybridAMCard(isDisabled: application.status.isDisabled(), cardLogoImageUrl: paymentMethodImageUrl, paymentMethodImageUrl: cardLogoImageUrl, color: color, gradientColors: gradientColors)
                }
            }
            
            let behaviours = application.behaviours ?? targetNode.behaviours
            
            let cardSliderApplication = PXCardSliderApplicationData(paymentMethodId: paymentMethodId, paymentTypeId: paymentMethodType, cardData: cardData, cardUI: cardUI, payerCost: payerCosts ?? defaultPayerCost, selectedPayerCost: selectedPayerCost, shouldShowArrow: showArrow, amountConfiguration: amountConfiguration, status: statusConfig, bottomMessage: chargeRuleMessage, benefits: PXPaymentTypes.CREDIT_CARD.rawValue == paymentMethodType ? targetNode.benefits : nil, payerPaymentMethod: payerPaymentMethod, behaviours: behaviours, displayInfo: targetNode.displayInfo, displayMessage: displayMessage)
            
            cardSliderApplications[paymentMethodType] = cardSliderApplication
        }
        
        var selectedApplicationId = applications.first?.paymentMethod.type
        var comboSwitch: ComboSwitchView?
        
        if let switchInfo = targetNode.displayInfo?.switchInfo {
            comboSwitch = ComboSwitchView()
            selectedApplicationId = switchInfo.defaultState
            comboSwitch?.setSwitchModel(switchInfo)
        }
        
        let viewModelCard = PXCardSliderViewModel(cardModel: OneTapCardSliderModel(
                                                    applications: cardSliderApplications,
                                                    selectedApplicationId: selectedApplicationId,
                                                    issuerId: targetIssuerId,
                                                    cardId: oneTapCard.cardId,
                                                    creditsViewModel: nil,
                                                    displayInfo: targetNode.displayInfo,
                                                    comboSwitch: comboSwitch)
        )
          
        return viewModelCard
    }
    
    private func getOfflineCardUI(oneTap: PXOneTapDto) -> CardUI {
        let template = TemplatePIX()
        
        template.cardBackgroundColor = oneTap.offlineTapCard?.displayInfo?.color?.hexToUIColor() ?? .white
        template.titleName = oneTap.offlineTapCard?.displayInfo?.title?.message ?? ""
        template.titleWeight = oneTap.offlineTapCard?.displayInfo?.title?.weight ?? ""
        template.titleTextColor = oneTap.offlineTapCard?.displayInfo?.title?.textColor ?? ""
        template.subtitleName = oneTap.offlineTapCard?.displayInfo?.subtitle?.message ?? ""
        template.subtitleWeight = oneTap.offlineTapCard?.displayInfo?.title?.weight ?? ""
        template.subtitleTextColor = oneTap.offlineTapCard?.displayInfo?.subtitle?.textColor ?? ""
        template.labelName = oneTap.displayInfo?.tag?.message?.uppercased() ?? ""
        template.labelWeight = oneTap.displayInfo?.tag?.weight ?? ""
        template.labelTextColor = oneTap.displayInfo?.tag?.textColor ?? ""
        template.labelBackgroundColor = oneTap.displayInfo?.tag?.backgroundColor ?? ""
        template.logoImageURL = oneTap.offlineTapCard?.displayInfo?.paymentMethodImageUrl ?? ""
        
        return template
    }
    
    // MARK: - Public methods
    func setBottomMessage(at index: Int, bottomMessage: PXCardBottomMessage?) {
        dataSource[index].getSelectedApplication()?.bottomMessage = bottomMessage
    }
    
    func setSplitPayment(isEnable: Bool) {
        oneTapModel.splitPaymentEnabled = isEnable
    }
    
    func setDataSource(dataSource: [PXCardSliderViewModel]) {
        self.dataSource = dataSource
    }
    
    func setSplitPaymentEnabled(isEnabled: Bool) {
        oneTapModel.splitPaymentEnabled = isEnabled
    }
    
    func getCards() -> [PXCardSliderViewModel] {
        return dataSource
    }
    
    func getAmountHelper() -> PXAmountHelper {
        return oneTapModel.amountHelper
    }
    
    func getItem() -> PXItem? {
        return oneTapModel.items.first
    }
    
    func getAdditionalInfoSummary() -> PXAdditionalInfoSummary? {
        return oneTapModel.additionalInfoSummary
    }
    
    func getChargeRule(paymentTypeId: String?) -> PXPaymentTypeChargeRule? {
        guard let rules = oneTapModel.amountHelper.chargeRules, let paymentTypeId = paymentTypeId else {
            return nil
        }
        let filteredRules = rules.filter({
            $0.paymentTypeId == paymentTypeId
        })
        return filteredRules.first
    }
    
    func getAmoutHelper() -> PXAmountHelper {
        return oneTapModel.amountHelper
    }
    
    func getSelectedApplication(at index: Int) -> PXCardSliderApplicationData? {
        return dataSource[index].getSelectedApplication()
    }
    
    func getPaymentMethods() -> [PXPaymentMethod] {
        return oneTapModel.paymentMethods
    }
    
    func getExpressData() -> [PXOneTapDto]? {
        return oneTapModel.expressData
    }
    
    func getApplications() -> [PXOneTapApplication] {
        return applications
    }
    
    func getDisabledOption() -> PXDisabledOption? {
        return oneTapModel.disabledOption
    }
    
    func getPayerCompliance() -> PXPayerCompliance? {
        return oneTapModel.payerCompliance
    }
    
    func getModal(modalKey: String) -> PXModal? {
        return oneTapModel.modals?[modalKey]
    }
    
    func getIsSplitPaymentEnabled() -> Bool {
        return oneTapModel.splitPaymentEnabled
    }
    
    func getSplitMessageForDebit(amountToPay: Double) -> NSAttributedString {
        var amount: String = ""
        let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: UIFont.ml_regularSystemFont(ofSize: installmentsRowMessageFontSize), NSAttributedString.Key.foregroundColor: ThemeManager.shared.boldLabelTintColor()]

        amount = Utils.getAmountFormated(amount: amountToPay, forCurrency: SiteManager.shared.getCurrency())
        return NSAttributedString(string: amount, attributes: attributes)
    }
    
    func getCardBottomMessage(paymentTypeId: String?, benefits: PXBenefits?, status: PXStatus?, selectedPayerCost: PXPayerCost?, displayInfo: PXOneTapDisplayInfo?) -> PXCardBottomMessage? {
        let defaultTextColor = UIColor.white
        let defaultBackgroundColor = ThemeManager.shared.noTaxAndDiscountLabelTintColor()

        if let displayInfoMessage = displayInfo?.bottomDescription {
            return PXCardBottomMessage(text: displayInfoMessage, fixed: true)
        }

        if let chargeRuleMessage = getChargeRuleBottomMessage(paymentTypeId), (status?.isUsable() ?? true) {
            let text = PXText(message: chargeRuleMessage, backgroundColor: nil, textColor: nil, weight: nil)
            text.defaultTextColor = defaultTextColor
            text.defaultBackgroundColor = defaultBackgroundColor
            return PXCardBottomMessage(text: text, fixed: false)
        }

        guard let selectedInstallments = selectedPayerCost?.installments else {
            return nil
        }

        guard let reimbursementAppliedInstallments = benefits?.reimbursement?.appliedInstallments else {
            return nil
        }

        if reimbursementAppliedInstallments.contains(selectedInstallments), (status?.isUsable() ?? true) {
            let text = PXText(message: benefits?.reimbursement?.card?.message, backgroundColor: nil, textColor: nil, weight: nil)
            text.defaultTextColor = defaultTextColor
            text.defaultBackgroundColor = defaultBackgroundColor
            return PXCardBottomMessage(text: text, fixed: false)
        }

        return nil
    }
    
}

// MARK: - InitializationTypes
extension CardViewModel {
    private func createPixCard(cardData: PXOneTapDto, paymentMethodId: String) -> PXCardSliderViewModel {
        let statusConfig = getStatusConfig(
            currentStatus: cardData.status,
            cardId: cardData.oneTapCard?.cardId,
            paymentMethodId: cardData.paymentMethodId
        )
        let templateCard = getOfflineCardUI(oneTap: cardData)
        let card = PXCardDataFactory().create(cardName: "", cardNumber: "", cardCode: "", cardExpiration: "")
        var cardSliderApplications : [PXApplicationId:PXCardSliderApplicationData] = [:]
        let applicationName = cardData.paymentTypeId ?? PXPaymentTypes.BANK_TRANSFER.rawValue
        
        cardSliderApplications[applicationName] = PXCardSliderApplicationData(
            paymentMethodId: paymentMethodId,
            paymentTypeId: cardData.paymentTypeId,
            cardData: card,
            cardUI: templateCard,
            payerCost: [],
            selectedPayerCost: nil,
            shouldShowArrow: false,
            amountConfiguration: nil,
            status: statusConfig,
            bottomMessage: nil,
            benefits: cardData.benefits,
            payerPaymentMethod: nil,
            behaviours: cardData.behaviours,
            displayInfo: cardData.displayInfo,
            displayMessage: nil)
        
        return PXCardSliderViewModel(cardModel: OneTapCardSliderModel(
                                                    applications: cardSliderApplications,
                                                    selectedApplicationId: applicationName,
                                                    issuerId: "",
                                                    cardId: "",
                                                    creditsViewModel: nil,
                                                    displayInfo: nil,
                                                    comboSwitch: nil)
        )
    }
    
    private func createAccountMoneyCard(cardData: PXOneTapDto, accountMoney: PXAccountMoneyDto, paymentMethodId: String) -> PXCardSliderViewModel {
        let statusConfig = getStatusConfig(currentStatus: cardData.status,
                                           cardId: cardData.oneTapCard?.cardId,
                                           paymentMethodId: cardData.paymentMethodId)
        
        let chargeRuleMessage = getCardBottomMessage(paymentTypeId: cardData.paymentTypeId,
                                                     benefits: cardData.benefits,
                                                     status: cardData.status,
                                                     selectedPayerCost: nil,
                                                     displayInfo: cardData.displayInfo)
        
            let payerPaymentMethod = getPayerPaymentMethod(cardData.paymentTypeId, cardData.oneTapCard?.cardId)
                
            if let applications = cardData.applications, applications.count > 0, let oneTapCard = cardData.oneTapCard,
               let card = getCardData(oneTapCard: oneTapCard) {
                let viewModelCard = getCardSliderViewModelFor(targetNode: cardData, oneTapCard: oneTapCard, cardData: card, applications: applications)
                return viewModelCard
            } else {
                let displayTitle = accountMoney.cardTitle ?? ""
                let card = PXCardDataFactory().create(cardName: displayTitle, cardNumber: "", cardCode: "", cardExpiration: "")
                let amountConfiguration = oneTapModel.amountHelper.paymentConfigurationService.getAmountConfigurationForPaymentMethod(paymentOptionID: accountMoney.getId(), paymentMethodId: paymentMethodId, paymentTypeId: cardData.paymentTypeId)

                let isDefaultCardType = accountMoney.cardType == .defaultType
                let isDisabled = cardData.status.isDisabled()
                let cardLogoImageUrl = accountMoney.paymentMethodImageURL
                let color = accountMoney.color
                let gradientColors = accountMoney.gradientColors

                let cardUI: CardUI = isDefaultCardType ?
                                    AccountMoneyCard(isDisabled: isDisabled, cardLogoImageUrl: cardLogoImageUrl, color: color, gradientColors: gradientColors) :
                                    HybridAMCard(isDisabled: isDisabled, cardLogoImageUrl: cardLogoImageUrl, paymentMethodImageUrl: nil, color: color, gradientColors: gradientColors)
                
                let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: UIFont.ml_regularSystemFont(ofSize: installmentsRowMessageFontSize), NSAttributedString.Key.foregroundColor: ThemeManager.shared.greyColor()]
                let displayMessage = NSAttributedString(string: accountMoney.sliderTitle ?? "", attributes: attributes)
                
                let cardSliderApplication = PXCardSliderApplicationData(
                    paymentMethodId: paymentMethodId,
                    paymentTypeId: cardData.paymentTypeId,
                    cardData: card,
                    cardUI: cardUI,
                    payerCost: [PXPayerCost](),
                    selectedPayerCost: nil,
                    shouldShowArrow: false,
                    amountConfiguration: amountConfiguration,
                    status: statusConfig,
                    bottomMessage: chargeRuleMessage,
                    benefits: cardData.benefits,
                    payerPaymentMethod: payerPaymentMethod,
                    behaviours: cardData.behaviours,
                    displayInfo: cardData.displayInfo,
                    displayMessage: displayMessage)
                
                var cardSliderApplications : [PXApplicationId:PXCardSliderApplicationData] = [:]
                
                cardSliderApplications[cardData.paymentTypeId ?? PXPaymentTypes.ACCOUNT_MONEY.rawValue] = cardSliderApplication
                
                let viewModelCard = PXCardSliderViewModel(cardModel: OneTapCardSliderModel(
                                                            applications: cardSliderApplications,
                                                            selectedApplicationId: cardData.paymentTypeId ?? PXPaymentTypes.ACCOUNT_MONEY.rawValue,
                                                            issuerId: "",
                                                            cardId: accountMoney.getId(),
                                                            creditsViewModel: nil,
                                                            displayInfo: cardData.displayInfo,
                                                            comboSwitch: nil)
                )
                
                viewModelCard.setAccountMoney(accountMoneyBalance: accountMoney.availableBalance)

                return viewModelCard
            }

    }
    
    private func createMercadoCreditosCard(cardData: PXOneTapDto, consumerCredits: PXOneTapCreditsDto, paymentMethodId: String, amountConfiguration: PXAmountConfiguration) -> PXCardSliderViewModel {
        let chargeRuleMessage = getCardBottomMessage(paymentTypeId: cardData.paymentTypeId,
                                                     benefits: cardData.benefits,
                                                     status: cardData.status,
                                                     selectedPayerCost: nil,
                                                     displayInfo: cardData.displayInfo)
        
        let statusConfig = getStatusConfig(currentStatus: cardData.status,
                                           cardId: cardData.oneTapCard?.cardId,
                                           paymentMethodId: cardData.paymentMethodId)
        
        let card = PXCardDataFactory().create(cardName: "", cardNumber: "", cardCode: "", cardExpiration: "")
        let creditsViewModel = PXCreditsViewModel(consumerCredits)
        
        let cardSliderApplication = PXCardSliderApplicationData(
            paymentMethodId: paymentMethodId,
            paymentTypeId: cardData.paymentTypeId,
            cardData: card,
            cardUI: ConsumerCreditsCard(creditsViewModel,
                                        isDisabled: cardData.status.isDisabled()),
            payerCost: amountConfiguration.payerCosts ?? [],
            selectedPayerCost: amountConfiguration.selectedPayerCost,
            shouldShowArrow: true,
            amountConfiguration: amountConfiguration,
            status: statusConfig,
            bottomMessage: chargeRuleMessage,
            benefits: cardData.benefits,
            payerPaymentMethod: getPayerPaymentMethod(cardData.paymentTypeId, nil),
            behaviours: cardData.behaviours,
            displayInfo: cardData.displayInfo,
            displayMessage: nil)
        
        var cardSliderApplications : [PXApplicationId:PXCardSliderApplicationData] = [:]
        
        cardSliderApplications[cardData.paymentTypeId ?? PXPaymentTypes.CONSUMER_CREDITS.rawValue] = cardSliderApplication
        
        return PXCardSliderViewModel(cardModel: OneTapCardSliderModel(
                                                    applications: cardSliderApplications,
                                                    selectedApplicationId: cardData.paymentTypeId,
                                                    issuerId: "",
                                                    cardId: PXPaymentTypes.CONSUMER_CREDITS.rawValue,
                                                    creditsViewModel: creditsViewModel,
                                                    displayInfo: cardData.displayInfo,
                                                    comboSwitch: nil)
        )
    }
    
    private func createOfflineAndCardCreation(with cardData: PXOneTapDto) -> PXCardSliderViewModel {
        let statusConfig = getStatusConfig(currentStatus: cardData.status,
                                           cardId: cardData.oneTapCard?.cardId,
                                           paymentMethodId: cardData.paymentMethodId)
        
        let chargeRuleMessage = getCardBottomMessage(paymentTypeId: cardData.paymentTypeId,
                                                     benefits: cardData.benefits,
                                                     status: cardData.status,
                                                     selectedPayerCost: nil,
                                                     displayInfo: cardData.displayInfo)
        
        var newCardData: PXAddNewMethodData?
        if let newCard = cardData.newCard {
            newCardData = PXAddNewMethodData(title: newCard.label, subtitle: newCard.descriptionText)
        }
        var newOfflineData: PXAddNewMethodData?
        if let offlineMethods = cardData.offlineMethods {
            newOfflineData = PXAddNewMethodData(title: offlineMethods.label, subtitle: offlineMethods.descriptionText)
        }
        let emptyCard = EmptyCard(newCardData: newCardData, newOfflineData: newOfflineData)

        let cardSliderApplication = PXCardSliderApplicationData(
            paymentMethodId: "",
            paymentTypeId: "",
            cardData: nil,
            cardUI: emptyCard,
            payerCost: [PXPayerCost](),
            selectedPayerCost: nil,
            shouldShowArrow: false,
            amountConfiguration: nil,
            status: statusConfig,
            bottomMessage: chargeRuleMessage,
            benefits: cardData.benefits,
            payerPaymentMethod: nil,
            behaviours: cardData.behaviours,
            displayInfo: cardData.displayInfo,
            displayMessage: nil)
        
        var cardSliderApplications : [PXApplicationId:PXCardSliderApplicationData] = [:]
        
        cardSliderApplications[""] = cardSliderApplication
        
        return PXCardSliderViewModel(cardModel: OneTapCardSliderModel(
                                                    applications: cardSliderApplications,
                                                    selectedApplicationId: "",
                                                    issuerId: "",
                                                    cardId: nil,
                                                    creditsViewModel: nil,
                                                    displayInfo: cardData.displayInfo,
                                                    comboSwitch: nil)
        )
    }
}
