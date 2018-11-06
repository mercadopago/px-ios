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

    override func trackInfo() {
        var properties: [String: Any] = [:]
        properties["available_methods"] = getAvailablePaymentMethodForTracking()
        properties["total_amount"] = amountHelper.amountToPay
        properties["currency_id"] = SiteManager.shared.getSiteId()
        properties["discount"] = amountHelper.getDiscountForTracking()
        var itemsDic: [Any] = []
        for item in amountHelper.preference.items {
            var itemDic: [String: Any] = [:]
            itemDic["id"] = item.id
            itemDic["description"] = item.getDescription()
            itemDic["price"] = item.getUnitPrice()
            itemDic["quantity"] = item.getQuantity()
            itemDic["currency_id"] = SiteManager.shared.getCurrency().id
            itemsDic.append(itemDic)
        }
        properties["items"] = itemsDic

        MPXTracker.sharedInstance.trackScreen(screenName: TrackingPaths.Screens.OneTap.getOneTapPath(), properties: properties)
    }
}

// MARK: ViewModels Publics.
extension PXOneTapViewModel {
    func createCardSliderViewModel() {
        var sliderModel: [PXCardSliderViewModel] = []
        let currency = SiteManager.shared.getCurrency()
        let amTitle: String = "onetap_am_total_balance".localized_beta
        guard let expressNode = expressData else { return }
        for targetNode in expressNode {

            // Caso account money
            if let accountMoney = targetNode.accountMoney {
                let displayAmount = Utils.getAmountFormated(amount: accountMoney.availableBalance, forCurrency: currency)
                let cardData = PXCardDataFactory().create(cardName: "\(amTitle) \(displayAmount)", cardNumber: "", cardCode: "", cardExpiration: "")
                let cardVM = PXCardSliderViewModel(targetNode.paymentMethodId, "", AccountMoneyCard(), cardData, [PXPayerCost](), nil, nil, false)
                cardVM.setAccountMoney(accountMoneyBalance: accountMoney.availableBalance)
                sliderModel.append(cardVM)
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

                    var payerCost: [PXPayerCost] = [PXPayerCost]()
                    if let pCost = targetCardData.payerCosts {
                        payerCost = pCost
                    }

                    var targetIssuerId: String = ""
                    if let issuerId = targetNode.oneTapCard?.cardUI?.issuerId {
                        targetIssuerId = issuerId
                    }

                    var showArrow: Bool = true
                    if let targetPaymentMethodId = targetNode.paymentTypeId, targetPaymentMethodId == PXPaymentTypes.DEBIT_CARD.rawValue {
                        showArrow = false
                    } else if targetCardData.selectedPayerCost == nil {
                        showArrow = false
                    }

                    sliderModel.append(PXCardSliderViewModel(targetNode.paymentMethodId, targetIssuerId, templateCard, cardData, payerCost, targetCardData.selectedPayerCost, nil, showArrow))
                }
            }
        }
        sliderModel.append(PXCardSliderViewModel("", "", EmptyCard(), nil, [PXPayerCost](), nil, nil, false))
        cardSliderViewModel = sliderModel
    }

    func getInstallmentInfoViewModel() -> [PXOneTapInstallmentInfoViewModel] {
        var model: [PXOneTapInstallmentInfoViewModel] = [PXOneTapInstallmentInfoViewModel]()
        let sliderViewModel = getCardSliderViewModel()
        for sliderNode in sliderViewModel {
            let installment = PXInstallment(issuer: nil, payerCosts: sliderNode.payerCost, paymentMethodId: nil, paymentTypeId: nil)
            let selectedPayerCost = sliderNode.selectedPayerCost
            let installmentInfoModel = PXOneTapInstallmentInfoViewModel(text: getInstallmentInfoAttrText(sliderNode.selectedPayerCost), installmentData: installment, selectedPayerCost: selectedPayerCost, shouldShow: sliderNode.shouldShowArrow)
            model.append(installmentInfoModel)
        }
        return model
    }

    func getHeaderViewModel() -> PXOneTapHeaderViewModel {
        let isDefaultStatusBarStyle = ThemeManager.shared.statusBarStyle() == .default
        let summaryColor = isDefaultStatusBarStyle ? UIColor.black : ThemeManager.shared.whiteColor()
        let summaryAlpha: CGFloat = 0.45
        let discountColor = isDefaultStatusBarStyle ? ThemeManager.shared.noTaxAndDiscountLabelTintColor() : ThemeManager.shared.whiteColor()
        let discountAlpha: CGFloat = 1
        let totalColor = isDefaultStatusBarStyle ? UIColor.black : ThemeManager.shared.whiteColor()
        let totalAlpha: CGFloat = 1

        let currency = SiteManager.shared.getCurrency()
        let totalAmountToShow = Utils.getAmountFormated(amount: amountHelper.amountToPayWithoutPayerCost, forCurrency: currency)
        let yourPurchaseToShow = Utils.getAmountFormated(amount: amountHelper.preferenceAmount, forCurrency: currency)
        var customData: [OneTapHeaderSummaryData] = [OneTapHeaderSummaryData]()

        if let discount = amountHelper.discount {
            customData.append(OneTapHeaderSummaryData("onetap_purchase_summary_title".localized_beta, yourPurchaseToShow, summaryColor, summaryAlpha, false, nil))
            let discountToShow = Utils.getAmountFormated(amount: discount.couponAmount, forCurrency: currency)
            let helperImage: UIImage? = isDefaultStatusBarStyle ? ResourceManager.shared.getImage("helper_ico") : ResourceManager.shared.getImage("helper_ico_light")
            customData.append(OneTapHeaderSummaryData(discount.getDiscountDescription(), "- \(discountToShow)", discountColor, discountAlpha, false, helperImage))
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

        let headerVM = PXOneTapHeaderViewModel(icon: headerImage, title: headerTitle, data: customData)
        return headerVM
    }

    func getCardSliderViewModel() -> [PXCardSliderViewModel] {
        return cardSliderViewModel
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
    private func getInstallmentInfoAttrText(_ payerCost: PXPayerCost?) -> NSMutableAttributedString {
        let text: NSMutableAttributedString = NSMutableAttributedString(string: "")

        if let payerCostData = payerCost {
            // First attr
            let currency = SiteManager.shared.getCurrency()
            let firstAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT), NSAttributedStringKey.foregroundColor: ThemeManager.shared.boldLabelTintColor()]
            let amountDisplayStr = Utils.getAmountFormated(amount: payerCostData.installmentAmount, forCurrency: currency).trimmingCharacters(in: .whitespaces)
            let firstText = "\(payerCostData.installments)x \(amountDisplayStr)"
            let firstAttributedString = NSAttributedString(string: firstText, attributes: firstAttributes)
            text.append(firstAttributedString)

            // Second attr
            // if let recommendedMessage = payerCostData.recommendedMessage {
            if payerCostData.installmentRate == 0 {
                let secondAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: Utils.getFont(size: PXLayout.XS_FONT), NSAttributedStringKey.foregroundColor: ThemeManager.shared.noTaxAndDiscountLabelTintColor()]
                let secondText = " Sin interés".localized
                let secondAttributedString = NSAttributedString(string: secondText, attributes: secondAttributes)
                text.append(secondAttributedString)
            }

            // Third attr
            if let cftDisplayStr = payerCostData.getCFTValue(), payerCostData.hasCFTValue() {
                let thirdAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: Utils.getFont(size: PXLayout.XS_FONT), NSAttributedStringKey.foregroundColor: ThemeManager.shared.greyColor()]
                let thirdText = " CFT: \(cftDisplayStr)"
                let thirdAttributedString = NSAttributedString(string: thirdText, attributes: thirdAttributes)
                text.append(thirdAttributedString)
            }
        }
        return text
    }
}

// MARK: Tracking
extension PXOneTapViewModel {
    func getAvailablePaymentMethodForTracking() -> [Any] {
        var dic: [Any] = []
        if let expressData = expressData {
            let cardIdsEsc = PXTrackingStore.sharedInstance.getData(forKey: PXTrackingStore.cardIdsESC) as? [String] ?? []
            for expressItem in expressData {
                if let savedCard = expressItem.oneTapCard {
                    var savedCardDic: [String: Any] = [:]
                    savedCardDic["payment_method_type"] = expressItem.paymentMethodId
                    savedCardDic["payment_method_id"] = expressItem.paymentTypeId
                    var extraInfo: [String: Any] = [:]
                    extraInfo["card_id"] = savedCard.cardId
                    extraInfo["has_esc"] = cardIdsEsc.contains(savedCard.cardId)
                    extraInfo["selected_installment"] = savedCard.selectedPayerCost?.getPayerCostForTracking()
                    savedCardDic["extra_info"] = extraInfo
                    dic.append(savedCardDic)
                } else if let accountMoney = expressItem.accountMoney {
                    var accountMoneyDic: [String: Any] = [:]
                    accountMoneyDic["payment_method_type"] = expressItem.paymentMethodId
                    accountMoneyDic["payment_method_id"] = expressItem.paymentTypeId
                    var extraInfo: [String: Any] = [:]
                    extraInfo["balance"] = accountMoney.availableBalance
                    accountMoneyDic["extra_info"] = extraInfo
                    dic.append(accountMoneyDic)
                }
            }
        }
        return dic
    }

    func trackSwipe() {
        MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.OneTap.getSwipePath())
    }

    func trackTapBackEvent() {
        MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.OneTap.getAbortPath())
    }

    func trackInstallmentsView(installmentData: PXInstallment, selectedCard: PXCardSliderViewModel) {
        var properties: [String: Any] = [:]
        properties["payment_method_id"] = amountHelper.paymentData.paymentMethod?.id
        properties["payment_method_type"] = amountHelper.paymentData.paymentMethod?.paymentTypeId
        properties["card_id"] =  selectedCard.cardId
        properties["issuer_id"] = amountHelper.paymentData.issuer?.id
        properties["total_amount"] = amountHelper.amountToPay
        var dic: [Any] = []
        for payerCost in installmentData.payerCosts {
            dic.append(payerCost.getPayerCostForTracking())
        }
        properties["available_installments"] = dic
        MPXTracker.sharedInstance.trackScreen(screenName: TrackingPaths.Screens.OneTap.getOneTapInstallmentsPath())
    }

    func trackConfirmEvent(selectedCard: PXCardSliderViewModel) {
        guard let paymentMethod = amountHelper.paymentData.paymentMethod else {
            return
        }
        let cardIdsEsc = PXTrackingStore.sharedInstance.getData(forKey: PXTrackingStore.cardIdsESC) as? [String] ?? []

        var properties: [String: Any] = [:]
        if paymentMethod.isCard {
            properties["payment_method_type"] = paymentMethod.id
            properties["payment_method_id"] = paymentMethod.paymentTypeId
            var extraInfo: [String: Any] = [:]
            extraInfo["card_id"] = selectedCard.cardId
            extraInfo["has_esc"] = cardIdsEsc.contains(selectedCard.cardId ?? "")
            extraInfo["selected_installment"] = amountHelper.paymentData.payerCost?.getPayerCostForTracking()
            properties["extra_info"] = extraInfo
        } else {
            properties["payment_method_type"] = paymentMethod.id
            properties["payment_method_id"] = paymentMethod.id
            var extraInfo: [String: Any] = [:]
            extraInfo["balance"] = selectedCard.accountMoneyBalance
            properties["extra_info"] = extraInfo
        }
        MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.getConfirmPath(), properties: properties)
    }
}
