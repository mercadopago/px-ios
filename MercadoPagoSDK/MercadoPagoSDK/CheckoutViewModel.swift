//
//  CheckoutViewModel.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 4/18/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class CheckoutViewModel: NSObject {

    var preference: CheckoutPreference?
    var paymentData: PaymentData!
    var paymentOptionSelected: PaymentMethodOption

    var discount: DiscountCoupon?

    var reviewScreenPreference: ReviewScreenPreference!

    var summaryComponent: SummaryComponent!

    public static var CUSTOMER_ID = ""

    public init(checkoutPreference: CheckoutPreference, paymentData: PaymentData, paymentOptionSelected: PaymentMethodOption, discount: DiscountCoupon? = nil, reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference()) {
        CheckoutViewModel.CUSTOMER_ID = ""
        self.preference = checkoutPreference
        self.paymentData = paymentData
        self.discount = discount
        self.paymentOptionSelected = paymentOptionSelected
        self.reviewScreenPreference = reviewScreenPreference
        super.init()
        let screenWidth = UIScreen.main.bounds.width
        self.summaryComponent = SummaryComponent(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 0), summary: self.getValidSummary(amount: checkoutPreference.getAmount()), paymentData: self.paymentData, totalAmount:(self.preference?.getAmount())!)

    }

    func isPaymentMethodSelectedCard() -> Bool {
        return self.paymentData.hasPaymentMethod() && self.paymentData.getPaymentMethod()!.isCard()
    }

    func numberOfSections() -> Int {
        return self.preference != nil ? 6 : 0
    }

    func isPaymentMethodSelected() -> Bool {
        return paymentData.hasPaymentMethod()
    }

    func isUserLogged() -> Bool {
        return !String.isNullOrEmpty(MercadoPagoContext.payerAccessToken())
    }

    func numberOfRowsInSection(section: Int) -> Int {
        switch section {
        case Sections.title.rawValue:
            return 1
        case Sections.summary.rawValue:
            return 1
        case Sections.items.rawValue:
            return self.hasCustomItemCells() ? self.numberOfCustomItemCells() : self.preference!.items.count
        case Sections.paymentMethod.rawValue:
            return 1
        case Sections.additionalCustomCells.rawValue:
            return self.numberOfCustomAdditionalCells()
        case Sections.footer.rawValue:
            return isUserLogged() ? 2 : 3
        default:
            return 0
        }
    }

    func heightForRow(_ indexPath: IndexPath) -> CGFloat {
        //TODO borrar
        if indexPath.section == Sections.summary.rawValue {
            return summaryComponent.requiredHeight
        }
        if isTitleCellFor(indexPath: indexPath) {
            return 60

        } else if self.isConfirmButtonCellFor(indexPath: indexPath) {
            return ConfirmPaymentTableViewCell.ROW_HEIGHT

        } else if self.isItemCellFor(indexPath: indexPath) {
            return hasCustomItemCells() ? reviewScreenPreference.customItemCells[indexPath.row].getHeight() : PurchaseItemDetailTableViewCell.getCellHeight(item: self.preference!.items[indexPath.row])

        } else if self.isPaymentMethodCellFor(indexPath: indexPath) {
            if isPaymentMethodSelectedCard() {
                return PaymentMethodSelectedTableViewCell.getCellHeight(payerCost : self.paymentData.getPayerCost(), reviewScreenPreference: reviewScreenPreference)
            }
            return OfflinePaymentMethodCell.getCellHeight(paymentMethodOption: self.paymentOptionSelected, reviewScreenPreference: reviewScreenPreference)

        } else if self.isAddtionalCustomCellsFor(indexPath: indexPath) {
            return reviewScreenPreference.additionalInfoCells[indexPath.row].getHeight()

        } else if isTermsAndConditionsViewCellFor(indexPath: indexPath) {
            return TermsAndConditionsViewCell.getCellHeight()

        } else if isExitButtonTableViewCellFor(indexPath: indexPath) {
            return ExitButtonTableViewCell.ROW_HEIGHT
        }

        return 0
    }

    func isTermsAndConditionsViewCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.footer.rawValue && (indexPath.row == 0 && !isUserLogged())
    }
    func isExitButtonTableViewCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.footer.rawValue && ( (indexPath.row == 2 && !isUserLogged()) || (indexPath.row == 1 && isUserLogged()) )
    }
    func isPreferenceLoaded() -> Bool {
        return self.preference != nil
    }

    func shouldDisplayNoRate() -> Bool {
        return self.paymentData.hasPayerCost() && !self.paymentData.getPayerCost()!.hasInstallmentsRate() && self.paymentData.getPayerCost()!.installments != 1
    }

    func numberOfCustomAdditionalCells() -> Int {
        if !Array.isNullOrEmpty(reviewScreenPreference.additionalInfoCells) {
            return reviewScreenPreference.additionalInfoCells.count
        }
        return 0
    }

    func numberOfCustomItemCells() -> Int {
        if hasCustomItemCells() {
            return reviewScreenPreference.customItemCells.count
        }
        return 0
    }

    func hasCustomItemCells() -> Bool {
        return !Array.isNullOrEmpty(reviewScreenPreference.customItemCells)
    }

    func getTotalAmount() -> Double {
        if let payerCost = paymentData.getPayerCost() {
            return payerCost.totalAmount
        }
        if MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable(), let discount = paymentData.discount {
            return discount.newAmount()
        }
        return self.preference!.getAmount()
    }

    func hasPayerCostAddionalInfo() -> Bool {
        return self.paymentData.hasPayerCost() && self.paymentData.getPayerCost()!.getCFTValue() != nil && self.paymentData.getPayerCost()!.installments != 1
    }

    func getUnlockLink() -> URL? {
        let path = MercadoPago.getBundle()!.path(forResource: "UnlockCardLinks", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        let site = MercadoPagoContext.getSite()
        guard let issuerID = self.paymentData.getIssuer()?._id else {
            return nil
        }
        let searchString: String = site + "_" + "\(issuerID)"

        if let link = dictionary?.value(forKey: searchString) as? String {
            UnlockCardTableViewCell.unlockCardLink = URL(string:link)
            return URL(string:link)
        }
        return nil
    }

    func needUnlockCardCell() -> Bool {
        if getUnlockLink() != nil {
            return true
        }
        return false
    }

    func isTitleCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.title.rawValue
    }
    func isSummaryCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.summary.rawValue
    }

    func isConfirmButtonCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.footer.rawValue && ( (indexPath.row == 1 && !isUserLogged()) || (indexPath.row == 0 && isUserLogged()) )
    }

    func hasConfirmAdditionalInfo() -> Bool {
        return hasPayerCostAddionalInfo() || needUnlockCardCell()
    }

    func isItemCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.items.rawValue
    }

    func isAddtionalCustomCellsFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.additionalCustomCells.rawValue
    }

    func isPaymentMethodCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.paymentMethod.rawValue
    }

    func shouldShowInstallmentSummary() -> Bool {
        return isPaymentMethodSelectedCard() && self.paymentData.getPaymentMethod()!.paymentTypeId != "debit_card" && paymentData.hasPayerCost() && paymentData.getPayerCost()!.installments != 1
    }

    func getClearPaymentData() -> PaymentData {
        let newPaymentData: PaymentData = paymentData
        newPaymentData.clearCollectedData()
        return newPaymentData
    }

    func getFloatingConfirmButtonHeight() -> CGFloat {
        return 80
    }

    func getFloatingConfirmButtonViewFrame() -> CGRect {
        let height = self.getFloatingConfirmButtonHeight()
        let width = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.maxY - height, width: width, height: height)
        return frame
    }

    func getFloatingConfirmButtonCellFrame() -> CGRect {
        let height = self.getFloatingConfirmButtonHeight()
        let width = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        return frame
    }

    public enum Sections: Int {
        case title = 0
        case summary = 1
        case items = 2
        case paymentMethod = 3
        case additionalCustomCells = 4
        case footer = 5
    }

    func getValidSummary(amount: Double) -> Summary {
        var summary: Summary
        guard let choPref = self.preference else {
            return Summary(details: [:])
        }
        if amount == self.reviewScreenPreference.getSummaryTotalAmount() {
            summary = Summary(details: self.reviewScreenPreference.details)
            if self.reviewScreenPreference.details[SummaryType.PRODUCT]?.details.count == 0 { //Si solo le cambio el titulo a Productos
                summary.addAmountDetail(detail: SummaryItemDetail(amount: choPref.getAmount()), type: SummaryType.PRODUCT)
            }
        }else {
            summary = defaultSummary()
            if self.reviewScreenPreference.details[SummaryType.PRODUCT]?.details.count == 0 { //Si solo le cambio el titulo a Productos
                if let title = self.reviewScreenPreference.details[SummaryType.PRODUCT]?.title {
                    summary.updateTitle(type: SummaryType.PRODUCT, oneWordTitle:title)
                }
            }

        }
        var amountPref = amount
        if let discount = self.paymentData.discount {
            let discountAmountDetail = SummaryItemDetail(name: discount.description, amount: Double(discount.coupon_amount)!)
            amountPref = discount.newAmount()
            if summary.details[SummaryType.DISCOUNT] != nil {
                 summary.addAmountDetail(detail: discountAmountDetail, type: SummaryType.DISCOUNT)
            }else {
                let discountSummaryDetail = SummaryDetail(title: self.reviewScreenPreference.summaryTitles[SummaryType.DISCOUNT]!, detail: discountAmountDetail)
                summary.addSummaryDetail(summaryDetail:discountSummaryDetail, type: SummaryType.DISCOUNT)
            }
            summary.details[SummaryType.DISCOUNT]?.titleColor = UIColor.mpGreenishTeal()
            summary.details[SummaryType.DISCOUNT]?.amountColor = UIColor.mpGreenishTeal()
        }
        if let payerCost = self.paymentData.payerCost {
            let interest = payerCost.totalAmount - amount
            if interest > 0 {
                let interestAmountDetail = SummaryItemDetail(amount: interest)
                if summary.details[SummaryType.CHARGE] != nil {
                    summary.addAmountDetail(detail: interestAmountDetail, type: SummaryType.CHARGE)
                }else {
                    let interestSummaryDetail = SummaryDetail(title: self.reviewScreenPreference.summaryTitles[SummaryType.CHARGE]!, detail: interestAmountDetail)
                    summary.addSummaryDetail(summaryDetail:interestSummaryDetail, type: SummaryType.CHARGE)
                }
            }
        }
        if let disclaimer = self.reviewScreenPreference.disclaimer {
            summary.disclaimer = disclaimer
            summary.disclaimerColor = self.reviewScreenPreference.disclaimerColor
        }
        return summary
    }

    func defaultSummary() -> Summary {
        guard let choPref = self.preference else {
            return Summary(details: [:])
        }
        let productSummaryDetail = SummaryDetail(title: self.reviewScreenPreference.summaryTitles[SummaryType.PRODUCT]!, detail: SummaryItemDetail(amount: choPref.getAmount()))
        return Summary(details:[SummaryType.PRODUCT: productSummaryDetail])
    }

}
