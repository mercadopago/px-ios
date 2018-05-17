//
//  PXReviewViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 27/2/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

final class PXReviewViewModel: NSObject {

    static let ERROR_DELTA = 0.001
    public static var CUSTOMER_ID = ""

    var preference: CheckoutPreference
    var paymentData: PaymentData!
    var paymentOptionSelected: PaymentMethodOption
    var discount: DiscountCoupon?
    var reviewScreenPreference: ReviewScreenPreference

    public init(checkoutPreference: CheckoutPreference, paymentData: PaymentData, paymentOptionSelected: PaymentMethodOption, discount: DiscountCoupon? = nil, reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference()) {
        PXReviewViewModel.CUSTOMER_ID = ""
        self.preference = checkoutPreference
        self.paymentData = paymentData
        self.discount = discount
        self.paymentOptionSelected = paymentOptionSelected
        self.reviewScreenPreference = reviewScreenPreference
        super.init()
    }
}

// MARK: - Logic.
extension PXReviewViewModel {

    // Logic.
    func isPaymentMethodSelectedCard() -> Bool {
        return self.paymentData.hasPaymentMethod() && self.paymentData.getPaymentMethod()!.isCard
    }

    func isPaymentMethodSelected() -> Bool {
        return paymentData.hasPaymentMethod()
    }

    func isUserLogged() -> Bool {
        return !String.isNullOrEmpty(MercadoPagoContext.payerAccessToken())
    }

    func shouldShowTermsAndCondition() -> Bool {
        return !isUserLogged()
    }

    func shouldShowInstallmentSummary() -> Bool {
        return isPaymentMethodSelectedCard() && self.paymentData.getPaymentMethod()!.paymentTypeId != "debit_card" && paymentData.hasPayerCost() && paymentData.getPayerCost()!.installments != 1
    }

    func shouldDisplayNoRate() -> Bool {
        return self.paymentData.hasPayerCost() && !self.paymentData.getPayerCost()!.hasInstallmentsRate() && self.paymentData.getPayerCost()!.installments != 1
    }

    func hasPayerCostAddionalInfo() -> Bool {
        return self.paymentData.hasPayerCost() && self.paymentData.getPayerCost()!.getCFTValue() != nil && self.paymentData.getPayerCost()!.installments > 0
    }

    func hasConfirmAdditionalInfo() -> Bool {
        return hasPayerCostAddionalInfo() || needUnlockCardComponent()
    }

    func needUnlockCardComponent() -> Bool {
        return getUnlockLink() != nil
    }
}

// MARK: - Getters
extension PXReviewViewModel {

    func getTotalAmount() -> Double {
        if let payerCost = paymentData.getPayerCost() {
            return payerCost.totalAmount
        }
        if MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable(), let discount = paymentData.discount {
            return discount.newAmount()
        }
        return self.preference.getAmount()
    }

    func getUnlockLink() -> URL? {
        let path = MercadoPago.getBundle()!.path(forResource: "UnlockCardLinks", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        let site = MercadoPagoContext.getSite()
        guard let issuerID = self.paymentData.getIssuer()?.issuerId else {
            return nil
        }
        let searchString: String = site + "_" + "\(issuerID)"

        if let link = dictionary?.value(forKey: searchString) as? String {
            return URL(string: link)
        }

        return nil
    }

    func getClearPaymentData() -> PaymentData {
        let newPaymentData: PaymentData = paymentData
        newPaymentData.clearCollectedData()
        return newPaymentData
    }

    func getFloatingConfirmViewHeight() -> CGFloat {
        return 82 + PXLayout.getSafeAreaBottomInset()/2
    }

    func getSummaryViewModel(amount: Double) -> Summary {

        var summary: Summary

        // TODO: Check Double type precision.
        if abs(amount - self.reviewScreenPreference.getSummaryTotalAmount()) <= PXReviewViewModel.ERROR_DELTA {
            summary = Summary(details: self.reviewScreenPreference.details)
            if self.reviewScreenPreference.details[SummaryType.PRODUCT]?.details.count == 0 { //Si solo le cambio el titulo a Productos
                summary.addAmountDetail(detail: SummaryItemDetail(amount: preference.getAmount()), type: SummaryType.PRODUCT)
            }
        } else {
            summary = getDefaultSummary()
            if self.reviewScreenPreference.details[SummaryType.PRODUCT]?.details.count == 0 { //Si solo le cambio el titulo a Productos
                if let title = self.reviewScreenPreference.details[SummaryType.PRODUCT]?.title {
                    summary.updateTitle(type: SummaryType.PRODUCT, oneWordTitle: title)
                }
            }
        }

        if let discount = self.paymentData.discount {
            let discountAmountDetail = SummaryItemDetail(name: discount.description, amount: Double(discount.coupon_amount)!)

            if summary.details[SummaryType.DISCOUNT] != nil {
                summary.addAmountDetail(detail: discountAmountDetail, type: SummaryType.DISCOUNT)
            } else {
                let discountSummaryDetail = SummaryDetail(title: self.reviewScreenPreference.summaryTitles[SummaryType.DISCOUNT]!, detail: discountAmountDetail)
                summary.addSummaryDetail(summaryDetail: discountSummaryDetail, type: SummaryType.DISCOUNT)
            }
            summary.details[SummaryType.DISCOUNT]?.titleColor = ThemeManager.shared.noTaxAndDiscountLabelTintColor()
            summary.details[SummaryType.DISCOUNT]?.amountColor = ThemeManager.shared.noTaxAndDiscountLabelTintColor()
        }
        if let payerCost = self.paymentData.payerCost {
            var interest = 0.0

            if let discountAmount = self.paymentData.discount?.coupon_amount, let discountValue = Double(discountAmount) {
                interest = payerCost.totalAmount - (amount - discountValue)
            } else {
                interest = payerCost.totalAmount - amount
            }

            if interest > 0 {
                let interestAmountDetail = SummaryItemDetail(amount: interest)
                if summary.details[SummaryType.CHARGE] != nil {
                    summary.addAmountDetail(detail: interestAmountDetail, type: SummaryType.CHARGE)
                } else {
                    let interestSummaryDetail = SummaryDetail(title: self.reviewScreenPreference.summaryTitles[SummaryType.CHARGE]!, detail: interestAmountDetail)
                    summary.addSummaryDetail(summaryDetail: interestSummaryDetail, type: SummaryType.CHARGE)
                }
            }
        }
        if let disclaimer = self.reviewScreenPreference.getDisclaimerText() {
            summary.disclaimer = disclaimer
            summary.disclaimerColor = self.reviewScreenPreference.getDisclaimerTextColor()
        }
        return summary
    }

    func getDefaultSummary() -> Summary {
        let productSummaryDetail = SummaryDetail(title: self.reviewScreenPreference.summaryTitles[SummaryType.PRODUCT]!, detail: SummaryItemDetail(amount: preference.getAmount()))

        return Summary(details: [SummaryType.PRODUCT: productSummaryDetail])
    }
}

// MARK: - Components builders.
extension PXReviewViewModel {

    func buildPaymentMethodComponent(withAction: PXComponentAction?) -> PXPaymentMethodComponent? {

        guard let pm = paymentData.getPaymentMethod() else {
            return nil
        }

        let issuer = paymentData.getIssuer()
        let paymentMethodName = pm.name ?? ""
        let paymentMethodIssuerName = issuer?.name ?? ""

        let image = PXImageService.getIconImageFor(paymentMethod: pm)
        var title = NSAttributedString(string: "")
        var subtitle: NSAttributedString? = nil
        var accreditationTime: NSAttributedString? = nil
        var action = withAction
        let backgroundColor = ThemeManager.shared.detailedBackgroundColor()
        let lightLabelColor = ThemeManager.shared.labelTintColor()
        let boldLabelColor = ThemeManager.shared.boldLabelTintColor()

        if pm.isCard {
            if let lastFourDigits = (paymentData.token?.lastFourDigits) {
                let text = paymentMethodName + " " + "terminada en ".localized + lastFourDigits
                title = text.toAttributedString()
            }
        } else {
            title = paymentMethodName.toAttributedString()
            if paymentOptionSelected.getComment().isNotEmpty {
                accreditationTime = Utils.getAccreditationTimeAttributedString(from: paymentOptionSelected.getComment())
            }
        }

        if paymentMethodIssuerName.lowercased() != paymentMethodName.lowercased() && !paymentMethodIssuerName.isEmpty {
            subtitle = paymentMethodIssuerName.toAttributedString()
        }

        if !self.reviewScreenPreference.isChangeMethodOptionEnabled() {
            action = nil
        }

        let props = PXPaymentMethodProps(paymentMethodIcon: image, title: title, subtitle: subtitle, descriptionTitle: nil, descriptionDetail: accreditationTime, disclaimer: nil, action: action, backgroundColor: backgroundColor, lightLabelColor: lightLabelColor, boldLabelColor: boldLabelColor)

        return PXPaymentMethodComponent(props: props)
    }

    func buildSummaryComponent(width: CGFloat) -> PXSummaryComponent {

        var customTitle = "Productos".localized
        let totalAmount: Double = self.preference.getAmount()

        if let prefDetail = reviewScreenPreference.details[SummaryType.PRODUCT], !prefDetail.title.isEmpty {
            customTitle = prefDetail.title
        } else {
            if preference.items.count == 1 {
                if let itemTitle = preference.items.first?.title, itemTitle.count > 0 {
                    customTitle = itemTitle
                }
            }
        }

        let props = PXSummaryComponentProps(summaryViewModel: getSummaryViewModel(amount: totalAmount), paymentData: paymentData, total: totalAmount, width: width, customTitle: customTitle, textColor: ThemeManager.shared.boldLabelTintColor(), backgroundColor: ThemeManager.shared.highlightBackgroundColor())

        return PXSummaryComponent(props: props)
    }

    func buildTitleComponent() -> PXReviewTitleComponent {
        let props = PXReviewTitleComponentProps(titleColor: ThemeManager.shared.getTitleColorForReviewConfirmNavigation(), backgroundColor: ThemeManager.shared.highlightBackgroundColor())
        return PXReviewTitleComponent(props: props)
    }
}

// MARK: Item component
extension PXReviewViewModel {

    func buildItemComponents() -> [PXItemComponent] {
        var pxItemComponents = [PXItemComponent]()
        if reviewScreenPreference.isItemsEnable() { // Items can be disable
            for item in self.preference.items {
                if let itemComponent = buildItemComponent(item: item) {
                    pxItemComponents.append(itemComponent)
                }
            }
        }
        return pxItemComponents
    }

    fileprivate func shouldShowQuantity(item: Item) -> Bool {
        return item.quantity > 1 // Quantity must not be shown if it is 1
    }

    fileprivate func shouldShowPrice(item: Item) -> Bool {
        return preference.hasMultipleItems() || item.quantity > 1 // Price must not be shown if quantity is 1 and there are no more products
    }

    fileprivate func shouldShowCollectorIcon() -> Bool {
        return !preference.hasMultipleItems() && reviewScreenPreference.getCollectorIcon() != nil
    }

    fileprivate func buildItemComponent(item: Item) -> PXItemComponent? {
        if item.quantity == 1 && String.isNullOrEmpty(item.itemDescription) && !preference.hasMultipleItems() { // Item must not be shown if it has no description and it's one
            return nil
        }

        let itemQuantiy = getItemQuantity(item: item)
        let itemPrice = getItemPrice(item: item)
        let itemTitle = getItemTitle(item: item)
        let itemDescription = getItemDescription(item: item)
        let collectorIcon = getCollectorIcon()
        let amountTitle = reviewScreenPreference.getAmountTitle()
        let quantityTile = reviewScreenPreference.getQuantityLabel()

        let itemTheme: PXItemComponentProps.ItemTheme = (backgroundColor: ThemeManager.shared.detailedBackgroundColor(), boldLabelColor: ThemeManager.shared.boldLabelTintColor(), lightLabelColor: ThemeManager.shared.labelTintColor())

        let itemProps = PXItemComponentProps(imageURL: item.pictureUrl, title: itemTitle, description: itemDescription, quantity: itemQuantiy, unitAmount: itemPrice, amountTitle: amountTitle, quantityTitle: quantityTile, collectorImage: collectorIcon, itemTheme: itemTheme)
        return PXItemComponent(props: itemProps)
    }
}

// MARK: Item getters
extension PXReviewViewModel {
    fileprivate func getItemTitle(item: Item) -> String? { // Return item real title if it has multiple items, if not return description
        if preference.hasMultipleItems() {
            return item.title
        }
        return item.itemDescription
    }

    fileprivate func getItemDescription(item: Item) -> String? { // Returns only if it has multiple items
        if preference.hasMultipleItems() {
            return item.itemDescription
        }
        return nil
    }

    fileprivate func getItemQuantity(item: Item) -> Int? {
        if  !shouldShowQuantity(item: item) {
            return nil
        }
        return item.quantity
    }

    fileprivate func getItemPrice(item: Item) -> Double? {
        if  !shouldShowPrice(item: item) {
            return nil
        }
        return item.unitPrice
    }

    fileprivate func getCollectorIcon() -> UIImage? {
        if !shouldShowCollectorIcon() {
            return nil
        }
        return reviewScreenPreference.getCollectorIcon()
    }
}

// MARK: Custom Components
extension PXReviewViewModel {

    func buildTopCustomComponent() -> PXCustomComponentizable? {
        if let customComponent = reviewScreenPreference.getTopComponent() {
            return PXCustomComponentContainer(withComponent: customComponent)
        }
        return nil
    }

    func buildBottomCustomComponent() -> PXCustomComponentizable? {
        if let customComponent = reviewScreenPreference.getBottomComponent() {
            return PXCustomComponentContainer(withComponent: customComponent)
        }
        return nil
    }

}
