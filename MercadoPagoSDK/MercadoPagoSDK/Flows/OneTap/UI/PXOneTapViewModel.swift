//
//  PXOneTapViewModel.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 15/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class PXOneTapViewModel: PXReviewViewModel {
    // Privates
    private var cardSliderViewModel: [PXCardSliderViewModel] = [PXCardSliderViewModel]()
    // Publics
    var expressData: [PXOneTapDto]?
    var paymentMethods: [PXPaymentMethod] = [PXPaymentMethod]()
    var paymentMethodPlugins: [PXPaymentMethodPlugin]?
    var items: [PXItem] = [PXItem]()

    var splitPaymentEnabled: Bool = false
    var splitPaymentSelectionByUser: Bool?
    var disabledOption: PXDisabledOption? = nil

    public init(amountHelper: PXAmountHelper, paymentOptionSelected: PaymentMethodOption, advancedConfig: PXAdvancedConfiguration, userLogged: Bool, disabledOption: PXDisabledOption? = nil) {
        self.disabledOption = disabledOption
        super.init(amountHelper: amountHelper, paymentOptionSelected: paymentOptionSelected, advancedConfig: advancedConfig, userLogged: userLogged)
    }

}

// MARK: ViewModels Publics.
extension PXOneTapViewModel {
    func createCardSliderViewModel() {
        var sliderModel: [PXCardSliderViewModel] = []
        guard let expressNode = expressData else { return }
        for targetNode in expressNode {
            //  Account money
            if let accountMoney = targetNode.accountMoney {
                let displayTitle = accountMoney.cardTitle ?? ""
                let cardData = PXCardDataFactory().create(cardName: displayTitle, cardNumber: "", cardCode: "", cardExpiration: "")
                let amountConfiguration = amountHelper.paymentConfigurationService.getAmountConfigurationForPaymentMethod(accountMoney.getId())

                let isDisabled = self.disabledOption?.isAccountMoneyDisabled() ?? false
                let viewModelCard = PXCardSliderViewModel(targetNode.paymentMethodId, targetNode.paymentTypeId, "", AccountMoneyCard(), cardData, [PXPayerCost](), nil, accountMoney.getId(), false, amountConfiguration: amountConfiguration, isDisabled: isDisabled)
                viewModelCard.setAccountMoney(accountMoneyBalance: accountMoney.availableBalance)
                let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: Utils.getFont(size: PXLayout.XS_FONT), NSAttributedString.Key.foregroundColor: ThemeManager.shared.greyColor()]
                viewModelCard.displayMessage = NSAttributedString(string: accountMoney.sliderTitle ?? "", attributes: attributes)
                sliderModel.append(viewModelCard)
            } else if let targetCardData = targetNode.oneTapCard {
                if let cardName = targetCardData.cardUI?.name, let cardNumber = targetCardData.cardUI?.lastFourDigits, let cardExpiration = targetCardData.cardUI?.expiration {

                    let cardData = PXCardDataFactory().create(cardName: cardName.uppercased(), cardNumber: cardNumber, cardCode: "", cardExpiration: cardExpiration, cardPattern: targetCardData.cardUI?.cardPattern)

                    let templateCard = TemplateCard()
                    if let cardPattern = targetCardData.cardUI?.cardPattern {
                        templateCard.cardPattern = cardPattern
                    }

                    if let cardBackgroundColor = targetCardData.cardUI?.color {
                        templateCard.cardBackgroundColor = cardBackgroundColor.hexToUIColor()
                    }

                    if let cardFontColor = targetCardData.cardUI?.fontColor {
                        templateCard.cardFontColor = cardFontColor.hexToUIColor()
                    }

                    if let paymentMethodImage = ResourceManager.shared.getPaymentMethodCardImage(paymentMethodId: targetNode.paymentMethodId.lowercased()) {
                        templateCard.cardLogoImage = paymentMethodImage
                    }

                    let amountConfiguration = amountHelper.paymentConfigurationService.getAmountConfigurationForPaymentMethod(targetCardData.cardId)
                    let defaultEnabledSplitPayment: Bool = amountConfiguration?.splitConfiguration?.splitEnabled ?? false

                    var payerCost: [PXPayerCost] = [PXPayerCost]()
                    if let pCost = amountHelper.paymentConfigurationService.getPayerCostsForPaymentMethod(targetCardData.cardId, splitPaymentEnabled: defaultEnabledSplitPayment) {
                        payerCost = pCost
                    }

                    var targetIssuerId: String = ""
                    if let issuerId = targetNode.oneTapCard?.cardUI?.issuerId {
                        targetIssuerId = issuerId
                    }

                    if let issuerImageName = targetNode.oneTapCard?.cardUI?.issuerImage {
                        templateCard.bankImage = ResourceManager.shared.getIssuerCardImage(issuerImageName: issuerImageName)
                    }

                    var showArrow: Bool = true
                    var displayMessage: NSAttributedString?
                    if let targetPaymentMethodId = targetNode.paymentTypeId, targetPaymentMethodId == PXPaymentTypes.DEBIT_CARD.rawValue {
                        showArrow = false
                        if let splitConfiguration = amountHelper.paymentConfigurationService.getSplitConfigurationForPaymentMethod(targetCardData.cardId), let totalAmount = amountHelper.paymentConfigurationService.getSelectedPayerCostsForPaymentMethod(targetCardData.cardId, splitPaymentEnabled: splitConfiguration.splitEnabled)?.totalAmount {
                            // If it's debit and has split, update split message
                            displayMessage = getSplitMessageForDebit(amountToPay: totalAmount)
                        }
                    } else if payerCost.count == 1 {
                        showArrow = false
                    } else if amountHelper.paymentConfigurationService.getPayerCostsForPaymentMethod(targetCardData.cardId) == nil {
                        showArrow = false
                    }

                    let selectedPayerCost = amountHelper.paymentConfigurationService.getSelectedPayerCostsForPaymentMethod(targetCardData.cardId, splitPaymentEnabled: defaultEnabledSplitPayment)

                    let isDisabled = self.disabledOption?.getDisabledCardId() == targetCardData.cardId
                    let viewModelCard = PXCardSliderViewModel(targetNode.paymentMethodId, targetNode.paymentTypeId, targetIssuerId, templateCard, cardData, payerCost, selectedPayerCost, targetCardData.cardId, showArrow, amountConfiguration: amountConfiguration, isDisabled: isDisabled)

                    viewModelCard.displayMessage = displayMessage
                    sliderModel.append(viewModelCard)
                }
            }
        }
        sliderModel.append(PXCardSliderViewModel("", "", "", EmptyCard(), nil, [PXPayerCost](), nil, nil, false, amountConfiguration: nil, isDisabled: false))
        cardSliderViewModel = sliderModel
    }

    func getInstallmentInfoViewModel() -> [PXOneTapInstallmentInfoViewModel] {
        var model: [PXOneTapInstallmentInfoViewModel] = [PXOneTapInstallmentInfoViewModel]()
        let sliderViewModel = getCardSliderViewModel()
        for sliderNode in sliderViewModel {
            let payerCost = sliderNode.payerCost
            let selectedPayerCost = sliderNode.selectedPayerCost
            let installment = PXInstallment(issuer: nil, payerCosts: payerCost, paymentMethodId: nil, paymentTypeId: nil)
            if sliderNode.isDisabled {
                let disabledInfoModel = PXOneTapInstallmentInfoViewModel(text: getDisabledOptionMessage(),
                                                                            installmentData: nil,
                                                                            selectedPayerCost: nil,
                                                                            shouldShowArrow: false)
                model.append(disabledInfoModel)
            } else if sliderNode.paymentTypeId == PXPaymentTypes.DEBIT_CARD.rawValue {
                // If it's debit and has split, update split message
                if let amountToPay = sliderNode.selectedPayerCost?.totalAmount {
                    let displayMessage = getSplitMessageForDebit(amountToPay: amountToPay)
                    let installmentInfoModel = PXOneTapInstallmentInfoViewModel(text: displayMessage, installmentData: installment, selectedPayerCost: selectedPayerCost, shouldShowArrow: sliderNode.shouldShowArrow)
                    model.append(installmentInfoModel)
                }

            } else {
                if let displayMessage = sliderNode.displayMessage {
                    let installmentInfoModel = PXOneTapInstallmentInfoViewModel(text: displayMessage, installmentData: installment, selectedPayerCost: selectedPayerCost, shouldShowArrow: sliderNode.shouldShowArrow)
                    model.append(installmentInfoModel)
                } else {
                    let installmentInfoModel = PXOneTapInstallmentInfoViewModel(text: getInstallmentInfoAttrText(selectedPayerCost), installmentData: installment, selectedPayerCost: selectedPayerCost, shouldShowArrow: sliderNode.shouldShowArrow)
                    model.append(installmentInfoModel)
                }
            }
        }
        return model
    }

    func getHeaderViewModel(selectedCard: PXCardSliderViewModel?) -> PXOneTapHeaderViewModel {
        let isDefaultStatusBarStyle = ThemeManager.shared.statusBarStyle() == .default
        let summaryColor = isDefaultStatusBarStyle ? UIColor.black : ThemeManager.shared.whiteColor()
        let summaryAlpha: CGFloat = 0.45
        let discountColor = isDefaultStatusBarStyle ? ThemeManager.shared.noTaxAndDiscountLabelTintColor() : ThemeManager.shared.whiteColor()
        let discountAlpha: CGFloat = 1
        let discountDisclaimerAlpha: CGFloat = isDefaultStatusBarStyle ? 0.45 : 1.0
        let totalColor = isDefaultStatusBarStyle ? UIColor.black : ThemeManager.shared.whiteColor()
        let totalAlpha: CGFloat = 1

        let splitConfiguration = selectedCard?.amountConfiguration?.splitConfiguration
        let currency = SiteManager.shared.getCurrency()
        var totalAmountToShow = Utils.getAmountFormated(amount: amountHelper.getAmountToPayWithoutPayerCost(selectedCard?.cardId), forCurrency: currency)
        var yourPurchaseToShow = Utils.getAmountFormated(amount: amountHelper.preferenceAmount, forCurrency: currency)
        var customData: [OneTapHeaderSummaryData] = [OneTapHeaderSummaryData]()

        if let discountConfiguration = amountHelper.paymentConfigurationService.getDiscountConfigurationForPaymentMethodOrDefault(selectedCard?.cardId), let campaign = discountConfiguration.getDiscountConfiguration().campaign {

            let discount = discountConfiguration.getDiscountConfiguration().discount
            let consumedDiscount = discountConfiguration.getDiscountConfiguration().isNotAvailable

            amountHelper.getPaymentData().setDiscount(discount, withCampaign: campaign, consumedDiscount: consumedDiscount)

            if consumedDiscount {
                customData.append(OneTapHeaderSummaryData("onetap_purchase_summary_title".localized_beta, yourPurchaseToShow, summaryColor, summaryAlpha, false, nil))
                let helperImage: UIImage? = isDefaultStatusBarStyle ? ResourceManager.shared.getImage("helper_ico_gray") : ResourceManager.shared.getImage("helper_ico_light")
                customData.append(OneTapHeaderSummaryData("total_row_consumed_discount".localized_beta, "", summaryColor, discountDisclaimerAlpha, false, helperImage))

                totalAmountToShow = Utils.getAmountFormated(amount: amountHelper.getAmountToPayWithoutPayerCost(selectedCard?.cardId), forCurrency: currency)
                yourPurchaseToShow = Utils.getAmountFormated(amount: amountHelper.preferenceAmount, forCurrency: currency)
            } else if let discount = discount {
                customData.append(OneTapHeaderSummaryData("onetap_purchase_summary_title".localized_beta, yourPurchaseToShow, summaryColor, summaryAlpha, false, nil))
                let discountToShow = Utils.getAmountFormated(amount: discount.couponAmount, forCurrency: currency)
                let helperImage: UIImage? = isDefaultStatusBarStyle ? ResourceManager.shared.getImage("helper_ico") : ResourceManager.shared.getImage("helper_ico_light")
                customData.append(OneTapHeaderSummaryData(discount.getDiscountDescription(), "- \(discountToShow)", discountColor, discountAlpha, false, helperImage))

                totalAmountToShow = Utils.getAmountFormated(amount: amountHelper.getAmountToPayWithoutPayerCost(selectedCard?.cardId), forCurrency: currency)
                yourPurchaseToShow = Utils.getAmountFormated(amount: amountHelper.preferenceAmount, forCurrency: currency)
            }
        } else {
            amountHelper.getPaymentData().clearDiscount()
            totalAmountToShow = Utils.getAmountFormated(amount: amountHelper.getAmountToPayWithoutPayerCost(selectedCard?.cardId), forCurrency: currency)
            yourPurchaseToShow = Utils.getAmountFormated(amount: amountHelper.preferenceAmount, forCurrency: currency)
        }

        customData.append(OneTapHeaderSummaryData("onetap_purchase_summary_total".localized_beta, totalAmountToShow, totalColor, totalAlpha, true, nil))

        // HeaderImage
        var headerImage: UIImage = UIImage()
        var headerTitle: String = ""
        if let headerUrl = items.first?.getPictureURL() {
            headerImage = PXUIImage(url: headerUrl)
        } else {
            if let defaultImage = ResourceManager.shared.getImage("MPSDK_review_iconoCarrito_white") {
                headerImage = defaultImage
            }
        }

        // HeaderTitle
        if let headerTitleStr = items.first?._description {
            headerTitle = headerTitleStr
        } else if let headerTitleStr = items.first?.title {
            headerTitle = headerTitleStr
        }

        let headerVM = PXOneTapHeaderViewModel(icon: headerImage, title: headerTitle, data: customData, splitConfiguration: splitConfiguration)
        return headerVM
    }

    func getCardSliderViewModel() -> [PXCardSliderViewModel] {
        return cardSliderViewModel
    }

    func updateAllCardSliderModels(splitPaymentEnabled: Bool) {
        for index in cardSliderViewModel.indices {
            _ = updateCardSliderSplitPaymentPreference(splitPaymentEnabled: splitPaymentEnabled, forIndex: index)
        }
    }

    func updateCardSliderSplitPaymentPreference(splitPaymentEnabled: Bool, forIndex: Int) -> Bool {
        if cardSliderViewModel.indices.contains(forIndex) {
            if splitPaymentEnabled {
                cardSliderViewModel[forIndex].payerCost = cardSliderViewModel[forIndex].amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.payerCosts ?? []
                cardSliderViewModel[forIndex].selectedPayerCost = cardSliderViewModel[forIndex].amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.selectedPayerCost
                cardSliderViewModel[forIndex].amountConfiguration?.splitConfiguration?.splitEnabled = splitPaymentEnabled

                // Show arrow to switch installments
                if cardSliderViewModel[forIndex].payerCost.count > 1 {
                    cardSliderViewModel[forIndex].shouldShowArrow = true
                } else {
                    cardSliderViewModel[forIndex].shouldShowArrow = false
                }

            } else {
                cardSliderViewModel[forIndex].payerCost = cardSliderViewModel[forIndex].amountConfiguration?.payerCosts ?? []
                cardSliderViewModel[forIndex].selectedPayerCost = cardSliderViewModel[forIndex].amountConfiguration?.selectedPayerCost
                cardSliderViewModel[forIndex].amountConfiguration?.splitConfiguration?.splitEnabled = splitPaymentEnabled

                // Show arrow to switch installments
                if cardSliderViewModel[forIndex].payerCost.count > 1 {
                    cardSliderViewModel[forIndex].shouldShowArrow = true
                } else {
                    cardSliderViewModel[forIndex].shouldShowArrow = false
                }
            }
            return true
        }
        return false
    }

    func updateCardSliderViewModel(newPayerCost: PXPayerCost?, forIndex: Int) -> Bool {
        if cardSliderViewModel.indices.contains(forIndex) {
            cardSliderViewModel[forIndex].selectedPayerCost = newPayerCost
            return true
        }
        return false
    }

    func getPaymentMethod(targetId: String) -> PXPaymentMethod? {
        if let plugins = paymentMethodPlugins, let pluginsPms = plugins.filter({return $0.getId() == targetId}).first {
            return pluginsPms.toPaymentMethod()
        }
        return paymentMethods.filter({return $0.id == targetId}).first
    }
}

// MARK: Privates.
extension PXOneTapViewModel {

    private func getDisplayMessageAttrText(_ displayMessage: String) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: Utils.getFont(size: PXLayout.XS_FONT), NSAttributedString.Key.foregroundColor: ThemeManager.shared.greyColor()]
        let attributedString = NSAttributedString(string: displayMessage, attributes: attributes)
        return attributedString
    }

    private func getInstallmentInfoAttrText(_ payerCost: PXPayerCost?) -> NSMutableAttributedString {
        let text: NSMutableAttributedString = NSMutableAttributedString(string: "")

        if let payerCostData = payerCost {
            // First attr
            let currency = SiteManager.shared.getCurrency()
            let firstAttributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT), NSAttributedString.Key.foregroundColor: ThemeManager.shared.boldLabelTintColor()]
            let amountDisplayStr = Utils.getAmountFormated(amount: payerCostData.installmentAmount, forCurrency: currency).trimmingCharacters(in: .whitespaces)
            let firstText = "\(payerCostData.installments)x \(amountDisplayStr)"
            let firstAttributedString = NSAttributedString(string: firstText, attributes: firstAttributes)
            text.append(firstAttributedString)

            // Second attr
            if payerCostData.installmentRate == 0, payerCostData.installments != 1 {
                let secondAttributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: Utils.getFont(size: PXLayout.XS_FONT), NSAttributedString.Key.foregroundColor: ThemeManager.shared.noTaxAndDiscountLabelTintColor()]
                let secondText = " Sin interés".localized
                let secondAttributedString = NSAttributedString(string: secondText, attributes: secondAttributes)
                text.append(secondAttributedString)
            }

            // Third attr
            if let cftDisplayStr = payerCostData.getCFTValue(), payerCostData.hasCFTValue(), payerCostData.installments != 1 {
                let thirdAttributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: Utils.getFont(size: PXLayout.XS_FONT), NSAttributedString.Key.foregroundColor: ThemeManager.shared.greyColor()]
                let thirdText = " CFT: \(cftDisplayStr)"
                let thirdAttributedString = NSAttributedString(string: thirdText, attributes: thirdAttributes)
                text.append(thirdAttributedString)
            }
        }
        return text
    }

    internal func getSplitMessageForDebit(amountToPay: Double) -> NSAttributedString {
        var amount: String = ""
        let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT), NSAttributedString.Key.foregroundColor: ThemeManager.shared.boldLabelTintColor()]

        amount = Utils.getAmountFormated(amount: amountToPay, forCurrency: SiteManager.shared.getCurrency())
        return NSAttributedString(string: amount, attributes: attributes)
    }

    internal func getDisabledOptionMessage() -> NSAttributedString {
        let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT), NSAttributedString.Key.foregroundColor: ThemeManager.shared.boldLabelTintColor()]
        let text = "No podes usar esta tarjeta"
        return NSAttributedString(string: text, attributes: attributes)
    }
}
