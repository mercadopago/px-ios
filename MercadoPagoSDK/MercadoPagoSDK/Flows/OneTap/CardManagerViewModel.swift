//
//  NewOneTaoViewModel.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 22/06/21.
//

import MLCardDrawer

protocol OneTapRedirects: AnyObject {
    func goToCongrats()
    func goToBiometric()
    func goToCVV()
    func goToCardForm()
}

final class CardManagerViewModel {
    // MARK: - Private properties
    private let oneTapModel: OneTapModel
    private let installmentsRowMessageFontSize = PXLayout.XS_FONT
    private var dataSource: [PXCardSliderViewModel] {
        return getDataSource()
    }
    
    // MARK: - Public properties
    weak var coordinator: OneTapRedirects?
    
    // MARK: - Initialization
    init(
        oneTapModel: OneTapModel,
        coordinator: OneTapRedirects? = nil
    ) {
        self.oneTapModel = oneTapModel
        self.coordinator = coordinator
    }
    
    // MARK: - Public methods
    private func getDataSource() -> [PXCardSliderViewModel] {
        guard let expressData = oneTapModel.expressData else { return [] }
        var sliderModel: [PXCardSliderViewModel] = []
        
        let reArrangedCards = rearrangeDisabledOption(expressData, disabledOption: oneTapModel.disabledOption)
        for card in reArrangedCards {

            //Charge rule message when amount is zero
            var chargeRuleMessage = getCardBottomMessage(
                paymentTypeId: card.paymentTypeId,
                benefits: card.benefits,
                status: card.status,
                selectedPayerCost: nil,
                displayInfo: card.displayInfo
            )
            let benefits = card.benefits

            let statusConfig = getStatusConfig(currentStatus: card.status, cardId: card.oneTapCard?.cardId, paymentMethodId: card.paymentMethodId)

            // Add New Card and Offline Payment Methods
            if card.newCard != nil || card.offlineMethods != nil {
                sliderModel.append(createOfflineAndCardCreation(with: card))
            }
            //  Account money
            if let accountMoney = card.accountMoney, let paymentMethodId = card.paymentMethodId {
                
                    sliderModel.append(viewModelCard)
                
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
                      let amountConfiguration = amountHelper.paymentConfigurationService.getAmountConfigurationForPaymentMethod(paymentOptionID: paymentMethodId, paymentMethodId: paymentMethodId, paymentTypeId: card.paymentTypeId) {

                let cardData = PXCardDataFactory().create(cardName: "", cardNumber: "", cardCode: "", cardExpiration: "")
                let creditsViewModel = PXCreditsViewModel(consumerCredits)
                
                let cardSliderApplication = PXCardSliderApplicationData(paymentMethodId: paymentMethodId, paymentTypeId: card.paymentTypeId, cardData: cardData, cardUI: ConsumerCreditsCard(creditsViewModel, isDisabled: card.status.isDisabled()), payerCost: amountConfiguration.payerCosts ?? [], selectedPayerCost: amountConfiguration.selectedPayerCost, shouldShowArrow: true, amountConfiguration: amountConfiguration, status: statusConfig, bottomMessage: chargeRuleMessage, benefits: benefits, payerPaymentMethod: getPayerPaymentMethod(card.paymentTypeId, nil), behaviours: card.behaviours, displayInfo: card.displayInfo, displayMessage: nil)
                
                var cardSliderApplications : [PXApplicationId:PXCardSliderApplicationData] = [:]
                
                cardSliderApplications[card.paymentTypeId ?? PXPaymentTypes.CONSUMER_CREDITS.rawValue] = cardSliderApplication
                
                let viewModelCard = PXCardSliderViewModel(cardModel: CardModel(
                                                            applications: cardSliderApplications,
                                                            selectedApplicationId: card.paymentTypeId,
                                                            issuerId: "",
                                                            cardId: PXPaymentTypes.CONSUMER_CREDITS.rawValue,
                                                            creditsViewModel: creditsViewModel,
                                                            displayInfo: card.displayInfo,
                                                            comboSwitch: nil)
                )


                sliderModel.append(viewModelCard)
            } else if card.offlineTapCard != nil,
                      let paymentMethodId = card.paymentMethodId {
                let templateCard = getOfflineCardUI(oneTap: card)
                let cardData = PXCardDataFactory().create(cardName: "", cardNumber: "", cardCode: "", cardExpiration: "")
                var cardSliderApplications : [PXApplicationId:PXCardSliderApplicationData] = [:]
                let applicationName = card.paymentTypeId ?? PXPaymentTypes.BANK_TRANSFER.rawValue
                
                cardSliderApplications[applicationName] = PXCardSliderApplicationData(paymentMethodId: paymentMethodId, paymentTypeId: card.paymentTypeId, cardData: cardData, cardUI: templateCard, payerCost: [], selectedPayerCost: nil, shouldShowArrow: false, amountConfiguration: nil, status: statusConfig, bottomMessage: nil, benefits: card.benefits, payerPaymentMethod: nil, behaviours: card.behaviours, displayInfo: card.displayInfo, displayMessage: nil)
                
                let viewModelCard = PXCardSliderViewModel(cardModel: CardModel(
                                                            applications: cardSliderApplications,
                                                            selectedApplicationId: applicationName,
                                                            issuerId: "",
                                                            cardId: "",
                                                            creditsViewModel: nil,
                                                            displayInfo: nil,
                                                            comboSwitch: nil)
                )

                        
                sliderModel.append(viewModelCard)
            }
        }
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
    
    func getStatusConfig(currentStatus: PXStatus, cardId: String?, paymentMethodId: String?) -> PXStatus {
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

    func getChargeRuleBottomMessage(_ paymentTypeId: String?) -> String? {
        let chargeRule = getChargeRule(paymentTypeId: paymentTypeId)
        return chargeRule?.message
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
    
    func getSplitMessageForDebit(amountToPay: Double) -> NSAttributedString {
        var amount: String = ""
        let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: UIFont.ml_regularSystemFont(ofSize: installmentsRowMessageFontSize), NSAttributedString.Key.foregroundColor: ThemeManager.shared.boldLabelTintColor()]

        amount = Utils.getAmountFormated(amount: amountToPay, forCurrency: SiteManager.shared.getCurrency())
        return NSAttributedString(string: amount, attributes: attributes)
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
    
    func getCardSliderViewModelFor(targetNode: PXOneTapDto, oneTapCard: PXOneTapCardDto, cardData: CardData, applications: [PXOneTapApplication]) -> PXCardSliderViewModel {
        
//        self.applications.append(contentsOf: applications)
        
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
                let gradientColors : [String] = []//["#101820"]

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
        
        let viewModelCard = PXCardSliderViewModel(cardModel: CardModel(
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
    
}

// MARK: - InitializationTypes
extension CardManagerViewModel {
    private func createPixCard(cardData: PXOneTapDto) -> PXCardSliderViewModel {
        
    }
    
    private func createAccountMoneyCard(cardData: PXOneTapDto) -> PXCardSliderViewModel {
        let payerPaymentMethod = getPayerPaymentMethod(cardData.paymentTypeId, cardData.oneTapCard?.cardId)
            
        if let applications = cardData.applications, applications.count > 0, let oneTapCard = cardData.oneTapCard,
           let cardData = getCardData(oneTapCard: oneTapCard) {
            let viewModelCard = getCardSliderViewModelFor(targetNode: cardData, oneTapCard: oneTapCard, cardData: cardData, applications: applications)
            sliderModel.append(viewModelCard)
        } else {
            let displayTitle = accountMoney.cardTitle ?? ""
            let cardData = PXCardDataFactory().create(cardName: displayTitle, cardNumber: "", cardCode: "", cardExpiration: "")
            let amountConfiguration = amountHelper.paymentConfigurationService.getAmountConfigurationForPaymentMethod(paymentOptionID: accountMoney.getId(), paymentMethodId: paymentMethodId, paymentTypeId: card.paymentTypeId)

            let isDefaultCardType = accountMoney.cardType == .defaultType
            let isDisabled = card.status.isDisabled()
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
                cardData: cardData,
                cardUI: cardUI,
                payerCost: [PXPayerCost](),
                selectedPayerCost: nil,
                shouldShowArrow: false,
                amountConfiguration: amountConfiguration,
                status: statusConfig,
                bottomMessage: chargeRuleMessage,
                benefits: benefits,
                payerPaymentMethod: payerPaymentMethod,
                behaviours: cardData.behaviours,
                displayInfo: card.displayInfo,
                displayMessage: displayMessage)
            
            var cardSliderApplications : [PXApplicationId:PXCardSliderApplicationData] = [:]
            
            cardSliderApplications[card.paymentTypeId ?? PXPaymentTypes.ACCOUNT_MONEY.rawValue] = cardSliderApplication
            
            let viewModelCard = PXCardSliderViewModel(cardModel: CardModel(
                                                        applications: cardSliderApplications,
                                                        selectedApplicationId: cardData.paymentTypeId ?? PXPaymentTypes.ACCOUNT_MONEY.rawValue,
                                                        issuerId: "",
                                                        cardId: accountMoney.getId(),
                                                        creditsViewModel: nil,
                                                        displayInfo: cardData.displayInfo,
                                                        comboSwitch: nil)
            )
            
            viewModelCard.setAccountMoney(accountMoneyBalance: accountMoney.availableBalance)
        }
            
            return viewModelCard

    }
    
    private func createCreditCard(cardData: PXOneTapDto) -> PXCardSliderViewModel {
        
    }
    
    private func createMercadoCreditosCard(cardData: PXOneTapDto) -> PXCardSliderViewModel {
        
    }
    
    private func createOfflineAndCardCreation(with cardData: PXOneTapDto) -> PXCardSliderViewModel {
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
            benefits: benefits,
            payerPaymentMethod: nil,
            behaviours: targetNode.behaviours,
            displayInfo: targetNode.displayInfo,
            displayMessage: nil)
        
        var cardSliderApplications : [PXApplicationId:PXCardSliderApplicationData] = [:]
        
        cardSliderApplications[""] = cardSliderApplication
        
        return PXCardSliderViewModel(cardModel: CardModel(
                                                    applications: cardSliderApplications,
                                                    selectedApplicationId: "",
                                                    issuerId: "",
                                                    cardId: nil,
                                                    creditsViewModel: nil,
                                                    displayInfo: cardData.displayInfo,
                                                    comboSwitch: nil)
        )
    }
    
    private func createAdNewCard(cardData: PXOneTapDto) -> PXCardSliderViewModel {
        
    }
}
