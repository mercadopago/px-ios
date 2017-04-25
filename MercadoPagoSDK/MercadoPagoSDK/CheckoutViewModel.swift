//
//  CheckoutViewModel.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 4/18/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class CheckoutViewModel: NSObject {
    
    var preference : CheckoutPreference?
    var paymentData : PaymentData!
    var paymentOptionSelected : PaymentMethodOption
    
    var discount : DiscountCoupon?
    
    var reviewScreenPreference: ReviewScreenPreference!
    var summaryRows: [SummaryRow]!
    
    public static var CUSTOMER_ID = ""
    
    public init(checkoutPreference : CheckoutPreference, paymentData : PaymentData, paymentOptionSelected : PaymentMethodOption, discount: DiscountCoupon? = nil, reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference()) {
        CheckoutViewModel.CUSTOMER_ID = ""
        self.preference = checkoutPreference
        self.paymentData = paymentData
        self.discount = discount
        self.paymentOptionSelected = paymentOptionSelected
        self.reviewScreenPreference = reviewScreenPreference
        self.summaryRows = reviewScreenPreference.getSummaryRows()
        super.init()
        setSummaryRows()
    }
    
    func setSummaryRows() {
        
        let productsSummary = SummaryRow(customDescription: reviewScreenPreference.getProductsTitle(), descriptionColor: nil, customAmount: self.preference!.getAmount(), amountColor: nil, separatorLine: shouldShowTotal())
        
        summaryRows.insert(productsSummary, at: 0)
        
        if MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable(), let discount = self.paymentData.discount {
            let discountSummary = SummaryRow(customDescription: discount.getDiscountReviewDescription(), descriptionColor: UIColor.mpGreenishTeal(), customAmount:-Double(discount.coupon_amount)!, amountColor: UIColor.mpGreenishTeal(), separatorLine: false)
            summaryRows.insert(discountSummary, at: 1)
        }
    }
    
    func isPaymentMethodSelectedCard() -> Bool {
        return self.paymentData.paymentMethod != nil && self.paymentData.paymentMethod!.isCard()
    }
    
    func numberOfSections() -> Int {
        return self.preference != nil ? 6 : 0
    }
    
    func isPaymentMethodSelected() -> Bool {
        return paymentData.paymentMethod != nil
    }
    
    func isUserLogged() -> Bool {
        return !String.isNullOrEmpty(MercadoPagoContext.payerAccessToken())
    }
    
    func numberOfRowsInSection(section: Int) -> Int{
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
        
        // Boton de confirmar
        numberOfRows += 1
        return numberOfRows
        
    }
    
    func heightForRow(_ indexPath: IndexPath) -> CGFloat {
        if isTitleCellFor(indexPath: indexPath) {
            return 60
            
        } else if self.isProductlCellFor(indexPath: indexPath) {
            return PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT
            
        } else if self.isInstallmentsCellFor(indexPath: indexPath) {
            return PurchaseDetailTableViewCell.getCellHeight(payerCost : self.paymentData.payerCost)
            
        } else if self.isTotalCellFor(indexPath: indexPath) {
            return PurchaseSimpleDetailTableViewCell.TOTAL_ROW_HEIGHT
            
        } else if self.isPayerCostAdditionalInfoFor(indexPath: indexPath) || self.isUnlockCardCellFor(indexPath: indexPath) {
            return ConfirmAdditionalInfoTableViewCell.ROW_HEIGHT
            
        } else if self.isConfirmButtonCellFor(indexPath: indexPath) || isSecondaryConfirmButton(indexPath: indexPath) {
            return ConfirmPaymentTableViewCell.ROW_HEIGHT
            
        } else if self.isItemCellFor(indexPath: indexPath) {
            return hasCustomItemCells() ? reviewScreenPreference.customItemCells[indexPath.row].getHeight() : PurchaseItemDetailTableViewCell.getCellHeight(item: self.preference!.items[indexPath.row])
            
        } else if self.isPaymentMethodCellFor(indexPath: indexPath) {
            if isPaymentMethodSelectedCard() {
                return PaymentMethodSelectedTableViewCell.getCellHeight(payerCost : self.paymentData.payerCost, reviewScreenPreference: reviewScreenPreference)
            }
            return OfflinePaymentMethodCell.ROW_HEIGHT
            
        } else if self.isAddtionalCustomCellsFor(indexPath: indexPath) {
            return reviewScreenPreference.additionalInfoCells[indexPath.row].getHeight()
            
        } else if isTermsAndConditionsViewCellFor(indexPath: indexPath) {
            return TermsAndConditionsViewCell.getCellHeight()
            
        } else if isExitButtonTableViewCellFor(indexPath: indexPath) {
            return ExitButtonTableViewCell.ROW_HEIGHT
        }
        
        return 0
    }
    
    func isTermsAndConditionsViewCellFor(indexPath: IndexPath) -> Bool{
        return indexPath.section == Sections.footer.rawValue && (indexPath.row == 0 && !isUserLogged())
    }
    func isSecondaryConfirmButton(indexPath: IndexPath) -> Bool{
        return indexPath.section == Sections.footer.rawValue && ( (indexPath.row == 1 && !isUserLogged()) || (indexPath.row == 0 && isUserLogged()) )
    }
    func isExitButtonTableViewCellFor(indexPath: IndexPath) -> Bool{
        return indexPath.section == Sections.footer.rawValue && ( (indexPath.row == 2 && !isUserLogged()) || (indexPath.row == 1 && isUserLogged()) )
    }
    func isPreferenceLoaded() -> Bool {
        return self.preference != nil
    }
    
    func shouldDisplayNoRate() -> Bool {
        return self.paymentData.payerCost != nil && !self.paymentData.payerCost!.hasInstallmentsRate() && self.paymentData.payerCost!.installments != 1
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
    
    func numberOfSummaryRows() -> Int{
        return summaryRows.count
    }
    
    func getTotalAmount() -> Double {
        if let payerCost = paymentData.payerCost {
            return payerCost.totalAmount
        }
        if MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable(), let discount = paymentData.discount {
            return discount.newAmount()
        }
        return self.preference!.getAmount()
    }
    
    func hasPayerCostAddionalInfo() -> Bool {
        return self.paymentData.payerCost != nil && self.paymentData.payerCost!.getCFTValue() != nil && self.paymentData.payerCost?.installments != 1
    }
    
    func getUnlockLink() -> URL? {
        let path = MercadoPago.getBundle()!.path(forResource: "UnlockCardLinks", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        let site = MercadoPagoContext.getSite()
        guard let issuerID = self.paymentData.issuer?._id else {
            return nil
        }
        let searchString: String = site + "_" + "\(issuerID)"
        
        if let link = dictionary?.value(forKey: searchString) as? String{
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
    
    func isTitleCellFor(indexPath: IndexPath) -> Bool{
        return indexPath.section == Sections.title.rawValue
    }
    
    func isProductlCellFor(indexPath: IndexPath) -> Bool{
        return indexPath.section == Sections.summary.rawValue && indexPath.row < numberOfSummaryRows()
    }
    
    func isInstallmentsCellFor(indexPath: IndexPath) -> Bool{
        return shouldShowInstallmentSummary() && indexPath.section == Sections.summary.rawValue && indexPath.row == numberOfSummaryRows()
        
    }
    func isTotalCellFor(indexPath: IndexPath) -> Bool {
        let numberOfRows = numberOfSummaryRows() + (shouldShowInstallmentSummary() ? 1 : 0)
        return shouldShowTotal() && indexPath.section == Sections.summary.rawValue && indexPath.row == numberOfRows
    }
    
    func isConfirmButtonCellFor(indexPath: IndexPath) -> Bool {
        var numberOfRows = numberOfSummaryRows()
        numberOfRows += shouldShowTotal() ? 1 : 0
        numberOfRows += shouldShowInstallmentSummary() ? 1 : 0
        numberOfRows += hasConfirmAdditionalInfo() ? 1 : 0
        return indexPath.section == Sections.summary.rawValue && indexPath.row == numberOfRows
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
        return isPaymentMethodSelectedCard() && self.paymentData.paymentMethod.paymentTypeId != "debit_card" && paymentData.payerCost != nil && paymentData.payerCost?.installments != 1
    }
    
    public enum Sections : Int {
        case title = 0
        case summary = 1
        case items = 2
        case paymentMethod = 3
        case additionalCustomCells = 4
        case footer = 5
    }
}

