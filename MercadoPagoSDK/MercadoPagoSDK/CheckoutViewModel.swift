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
    var shoppingPreference: ShoppingReviewPreference!
    var summaryRows: [SummaryRow]!

    public static var CUSTOMER_ID = ""

    public init(checkoutPreference: CheckoutPreference, paymentData: PaymentData, paymentOptionSelected: PaymentMethodOption, discount: DiscountCoupon? = nil, reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference(), shoppingPreference: ShoppingReviewPreference) {
        CheckoutViewModel.CUSTOMER_ID = ""
        self.preference = checkoutPreference
        self.paymentData = paymentData
        self.discount = discount
        self.paymentOptionSelected = paymentOptionSelected
        self.reviewScreenPreference = reviewScreenPreference
        self.summaryRows = reviewScreenPreference.getSummaryRows()
        self.shoppingPreference = shoppingPreference
        super.init()
        if shoppingPreference.getOneWordDescription() == ShoppingReviewPreference.DEFAULT_ONE_WORD_TITLE {
            setSummaryRows(shortTitle :reviewScreenPreference.getProductsTitle())
        }else {
             setSummaryRows(shortTitle :shoppingPreference.getOneWordDescription())
        }

    }

    func setSummaryRows(shortTitle: String) {

        let productsSummary = SummaryRow(customDescription: shortTitle, descriptionColor: nil, customAmount: self.preference!.getAmount(), amountColor: nil, separatorLine: shouldShowTotal())

        summaryRows.insert(productsSummary, at: 0)

        if MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable(), let discount = self.paymentData.discount {
            let discountSummary = SummaryRow(customDescription: discount.getDiscountReviewDescription(), descriptionColor: UIColor.mpGreenishTeal(), customAmount:-Double(discount.coupon_amount)!, amountColor: UIColor.mpGreenishTeal(), separatorLine: false)
            summaryRows.insert(discountSummary, at: 1)
        }
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
            return self.numberOfRowsInMainSection()
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

    func numberOfRowsInMainSection() -> Int {
        // Productos
        var numberOfRows = 0

        if self.shouldShowInstallmentSummary() {
            numberOfRows +=  1
        }

        if hasPayerCostAddionalInfo() {
            numberOfRows += 1
        }
        // Productos + customSummaryRows
        numberOfRows += summaryRows.count

        numberOfRows += shouldShowTotal() ? 1 : 0

        return numberOfRows

    }

    func heightForRow(_ indexPath: IndexPath) -> CGFloat {
        if isTitleCellFor(indexPath: indexPath) {
            return 60

        } else if self.isProductlCellFor(indexPath: indexPath) {
            return numberOfRowsInMainSection() == 1 ? PurchaseSimpleDetailTableViewCell.PRODUCT_ONLY_ROW_HEIGHT : PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT

        } else if self.isInstallmentsCellFor(indexPath: indexPath) {
            return PurchaseDetailTableViewCell.getCellHeight(payerCost : self.paymentData.getPayerCost())

        } else if self.isTotalCellFor(indexPath: indexPath) {
            return PurchaseSimpleDetailTableViewCell.TOTAL_ROW_HEIGHT

        } else if self.isPayerCostAdditionalInfoFor(indexPath: indexPath) || self.isUnlockCardCellFor(indexPath: indexPath) {
            return ConfirmAdditionalInfoTableViewCell.ROW_HEIGHT

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

    func numberOfSummaryRows() -> Int {
        return summaryRows.count
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

    func isProductlCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.summary.rawValue && indexPath.row < numberOfSummaryRows()
    }

    func isInstallmentsCellFor(indexPath: IndexPath) -> Bool {
        return shouldShowInstallmentSummary() && indexPath.section == Sections.summary.rawValue && indexPath.row == numberOfSummaryRows()

    }
    func isTotalCellFor(indexPath: IndexPath) -> Bool {
        let numberOfRows = numberOfSummaryRows() + (shouldShowInstallmentSummary() ? 1 : 0)
        return shouldShowTotal() && indexPath.section == Sections.summary.rawValue && indexPath.row == numberOfRows
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

    func isPayerCostAdditionalInfoFor(indexPath: IndexPath) -> Bool {
        let numberOfRows = numberOfSummaryRows() + (shouldShowTotal() ? 1 : 0) + (shouldShowInstallmentSummary() ? 1 : 0)
        return hasPayerCostAddionalInfo() && indexPath.section == Sections.summary.rawValue && indexPath.row == numberOfRows
    }

    func isUnlockCardCellFor(indexPath: IndexPath) -> Bool {
        let numberOfRows = numberOfSummaryRows() + (shouldShowTotal() ? 1 : 0) + (shouldShowInstallmentSummary() ? 1 : 0)
        return needUnlockCardCell() && indexPath.section == Sections.summary.rawValue && indexPath.row == numberOfRows
    }

    func isAddtionalCustomCellsFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.additionalCustomCells.rawValue
    }

    func isPaymentMethodCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.paymentMethod.rawValue
    }

    func shouldShowTotal() -> Bool {
        return shouldShowInstallmentSummary() || numberOfSummaryRows() > 1
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
}
