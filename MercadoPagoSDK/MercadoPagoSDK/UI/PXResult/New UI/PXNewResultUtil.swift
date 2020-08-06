//
//  PXNewResultUtil.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/09/2019.
//

import Foundation
import MLBusinessComponents
import AndesUI

class PXNewResultUtil {
    
    //RECEIPT DATA
    class func getDataForReceiptView(paymentId: String?) -> PXNewCustomViewData? {
        guard let paymentId = paymentId else {
            return nil
        }
        
        let attributedTitle = NSAttributedString(string: ("Operación #{0}".localized as NSString).replacingOccurrences(of: "{0}", with: "\(paymentId)"), attributes: PXNewCustomView.titleAttributes)
        
        let date = Date()
        let attributedSubtitle = NSAttributedString(string: Utils.getFormatedStringDate(date, addTime: true), attributes: PXNewCustomView.subtitleAttributes)
        
        let icon = ResourceManager.shared.getImage("receipt_icon")
        
        let data = PXNewCustomViewData(firstString: attributedTitle, secondString: attributedSubtitle, thirdString: nil, icon: icon, iconURL: nil, action: nil, color: nil)
        return data
    }
    
    //POINTS DATA
    class func getDataForPointsView(points: PXPoints?) -> MLBusinessLoyaltyRingData? {
        guard let points = points else {
            return nil
        }
        let data = PXRingViewData(points: points)
        return data
    }
    
    //DISCOUNTS DATA
    class func getDataForDiscountsView(discounts: PXDiscounts?) -> MLBusinessDiscountBoxData? {
        guard let discounts = discounts else {
            return nil
        }
        let data = PXDiscountsBoxData(discounts: discounts)
        return data
    }
    
    class func getDataForTouchpointsView(discounts: PXDiscounts?) -> MLBusinessTouchpointsData? {
        guard let touchpoint = discounts?.touchpoint else {
            return nil
        }
        let data = PXDiscountsTouchpointsData(touchpoint: touchpoint)
        return data
    }
    
    //DISCOUNTS ACCESSORY VIEW
    class func getDataForDiscountsAccessoryViewData(discounts: PXDiscounts?) -> ResultViewData? {
        guard let discounts = discounts else {
            return nil
        }
        
        let dataService = MLBusinessAppDataService()
        if dataService.isMpAlreadyInstalled() {
            let button = AndesButton(text: discounts.discountsAction.label, hierarchy: .quiet, size: .large)
            button.add(for: .touchUpInside) {
                //open deep link
                PXDeepLinkManager.open(discounts.discountsAction.target)
                MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapSeeAllDiscountsPath())
            }
            return ResultViewData(view: button, verticalMargin: PXLayout.M_MARGIN, horizontalMargin: PXLayout.L_MARGIN)
        } else {
            let downloadAppDelegate = PXDownloadAppData(discounts: discounts)
            let downloadAppView = MLBusinessDownloadAppView(downloadAppDelegate)
            downloadAppView.addTapAction { (deepLink) in
                //open deep link
                PXDeepLinkManager.open(deepLink)
                MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapDownloadAppPath())
            }
            return ResultViewData(view: downloadAppView, verticalMargin: PXLayout.M_MARGIN, horizontalMargin: PXLayout.L_MARGIN)
        }
    }
    
    //EXPENSE SPLIT DATA
    class func getDataForExpenseSplitView(expenseSplit: PXExpenseSplit) -> MLBusinessActionCardViewData {
        return PXExpenseSplitData(expenseSplitData: expenseSplit)
    }
    
    //CROSS SELLING VIEW
    class func getDataForCrossSellingView(crossSellingItems: [PXCrossSellingItem]?) -> [MLBusinessCrossSellingBoxData]? {
        guard let crossSellingItems = crossSellingItems else {
            return nil
        }
        var data = [MLBusinessCrossSellingBoxData]()
        for item in crossSellingItems {
            data.append(PXCrossSellingItemData(item: item))
        }
        return data
    }
}

// MARK: Payment Method Logic
extension PXNewResultUtil {
    //PAYMENT METHOD ICON
    class func getPaymentMethodIcon(paymentMethod: PXPaymentMethod) -> UIImage? {
        let defaultColor = paymentMethod.paymentTypeId == PXPaymentTypes.ACCOUNT_MONEY.rawValue && paymentMethod.paymentTypeId != PXPaymentTypes.PAYMENT_METHOD_PLUGIN.rawValue
        var paymentMethodImage: UIImage? =  ResourceManager.shared.getImageForPaymentMethod(withDescription: paymentMethod.id, defaultColor: defaultColor)
        // Retrieve image for payment plugin or any external payment method.
        if paymentMethod.paymentTypeId == PXPaymentTypes.PAYMENT_METHOD_PLUGIN.rawValue {
            paymentMethodImage = paymentMethod.getImageForExtenalPaymentMethod()
        }
        return paymentMethodImage
    }
    
    //PAYMENT METHOD DATA
    // This is kept just for refrence and will be removed soon
    @available(*, deprecated, message: "Do not use this, it's just for reference.")
    class func getDataForPaymentMethodView(paymentData: PXPaymentData, amountHelper: PXAmountHelper) -> PXNewCustomViewData? {
        guard let paymentMethod = paymentData.paymentMethod else {
            return nil
        }
        
        let image = getPaymentMethodIcon(paymentMethod: paymentMethod)
        let currency = SiteManager.shared.getCurrency()
        
        let firstString: NSAttributedString = getPMFirstStringORIG(currency: currency, paymentData: paymentData, amountHelper: amountHelper)
        let secondString: NSAttributedString? = getPMSecondString(paymentData: paymentData)
        let thirdString: NSAttributedString? = getPMThirdString(paymentData: paymentData)
        
        let data = PXNewCustomViewData(firstString: firstString, secondString: secondString, thirdString: thirdString, icon: image, iconURL: nil, action: nil, color: .white)
        return data
    }
    
    // PM First String
    @available(*, deprecated, message: "Do not use this, it's just for reference. Use `formatPaymentMethodFirstString()`")
    class func getPMFirstStringORIG(currency: PXCurrency, paymentData: PXPaymentData, amountHelper: PXAmountHelper) -> NSAttributedString {
        let attributes = firstStringAttributes()
        let totalAmountAttributes = attributes.totalAmountAtributes
        let interestRateAttributes = attributes.interestRateAttributes
        let discountAmountAttributes = attributes.discountAmountAttributes
        
        let firstString: NSMutableAttributedString = NSMutableAttributedString()
        
        if let payerCost = paymentData.payerCost {
            if payerCost.installments > 1 {
                let titleString = String(payerCost.installments) + "x " + Utils.getAmountFormated(amount: payerCost.installmentAmount, forCurrency: currency)
                let attributedTitle = NSAttributedString(string: titleString, attributes: PXNewCustomView.titleAttributes)
                firstString.append(attributedTitle)
                
                // Installment Rate
                if payerCost.installmentRate == 0.0 {
                    let interestRateString = " " + "Sin interés".localized.lowercased()
                    let attributedInsterest = NSAttributedString(string: interestRateString, attributes: interestRateAttributes)
                    firstString.appendWithSpace(attributedInsterest)
                }
                
                // Total Amount
                let totalString = Utils.getAmountFormated(amount: payerCost.totalAmount, forCurrency: currency, addingParenthesis: true)
                let attributedTotal = NSAttributedString(string: totalString, attributes: totalAmountAttributes)
                firstString.appendWithSpace(attributedTotal)
            } else {
                let titleString = Utils.getAmountFormated(amount: payerCost.totalAmount, forCurrency: currency)
                let attributedTitle = NSAttributedString(string: titleString, attributes: PXNewCustomView.titleAttributes)
                firstString.append(attributedTitle)
            }
        } else {
            // Caso account money
            if let splitAccountMoneyAmount = paymentData.getTransactionAmountWithDiscount() {
                let string = Utils.getAmountFormated(amount: splitAccountMoneyAmount, forCurrency: currency)
                let attributed = NSAttributedString(string: string, attributes: PXNewCustomView.titleAttributes)
                firstString.append(attributed)
            } else {
                let string = Utils.getAmountFormated(amount: amountHelper.amountToPay, forCurrency: currency)
                let attributed = NSAttributedString(string: string, attributes: PXNewCustomView.titleAttributes)
                firstString.append(attributed)
            }
        }
        
        // Discount
        if let discount = paymentData.getDiscount(), let transactionAmount = paymentData.transactionAmount {
            let transactionAmount = Utils.getAmountFormated(amount: transactionAmount.doubleValue, forCurrency: currency)
            let attributedAmount = NSAttributedString(string: transactionAmount, attributes: discountAmountAttributes)
            
            firstString.appendWithSpace(attributedAmount)
            
            let discountString = discount.getDiscountDescription()
            let attributedString = NSAttributedString(string: discountString, attributes: interestRateAttributes)
            
            firstString.appendWithSpace(attributedString)
        }
        
        return firstString
    }
    
    class func formatPaymentMethodFirstString(totalAmount: String, transactionAmount: String?, hasInstallments: Bool, installmentsCount: Int, installmentsAmount: String?, installmentRate: Double?, hasDiscount: Bool, discountName: String?) -> NSAttributedString {
        let attributes = firstStringAttributes()
        let totalAmountAttributes = attributes.totalAmountAtributes
        let interestRateAttributes = attributes.interestRateAttributes
        let discountAmountAttributes = attributes.discountAmountAttributes
        
        let firstString: NSMutableAttributedString = NSMutableAttributedString()
        
        if hasInstallments {
            if installmentsCount > 1 {
                let installmentsAmount = installmentsAmount ?? ""
                let titleString = String(installmentsCount) + "x " + installmentsAmount
                let attributedTitle = NSAttributedString(string: titleString, attributes: PXNewCustomView.titleAttributes)
                firstString.append(attributedTitle)
                
                // Installment Rate
                if installmentRate == 0.0 {
                    let interestRateString = " " + "Sin interés".localized.lowercased()
                    let attributedInsterest = NSAttributedString(string: interestRateString, attributes: interestRateAttributes)
                    firstString.appendWithSpace(attributedInsterest)
                }
                
                // Total Amount
                let totalString = Utils.addParenthesis(totalAmount)
                let attributedTotal = NSAttributedString(string: totalString, attributes: totalAmountAttributes)
                firstString.appendWithSpace(attributedTotal)
            } else {
                let titleString = totalAmount
                let attributedTitle = NSAttributedString(string: titleString, attributes: PXNewCustomView.titleAttributes)
                firstString.append(attributedTitle)
            }
        } else {
            // Caso account money
            let attributed = NSAttributedString(string: totalAmount, attributes: PXNewCustomView.titleAttributes)
            firstString.append(attributed)
        }
        
        // Discount
        if hasDiscount, let transactionAmount = transactionAmount {
            let transactionAmount = transactionAmount
            let attributedAmount = NSAttributedString(string: transactionAmount, attributes: discountAmountAttributes)
            
            firstString.appendWithSpace(attributedAmount)
            
            let discountString = discountName ?? ""
            let attributedString = NSAttributedString(string: discountString, attributes: interestRateAttributes)
            
            firstString.appendWithSpace(attributedString)
        }
        
        return firstString
    }
    
    class func firstStringAttributes() -> (totalAmountAtributes: [NSAttributedString.Key: Any], interestRateAttributes: [NSAttributedString.Key: Any], discountAmountAttributes: [NSAttributedString.Key: Any]) {
        let totalAmountAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT),
            NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.45)
        ]
        
        let interestRateAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT),
            NSAttributedString.Key.foregroundColor: ThemeManager.shared.noTaxAndDiscountLabelTintColor()
        ]
        
        let discountAmountAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT),
            NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.45),
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]
        
        return (totalAmountAttributes, interestRateAttributes, discountAmountAttributes)
    }
    
    // PM Second String
    class func formatPaymentMethodSecondString(paymentMethodName: String?, paymentMethodLastFourDigits lastFourDigits: String?, paymentTypeIdValue: String) -> NSAttributedString? {
        guard let description = assembleSecondString(paymentMethodName: paymentMethodName ?? "", paymentMethodLastFourDigits: lastFourDigits, paymentTypeIdValue: paymentTypeIdValue) else { return nil }
        return secondStringAttributed(description)
    }
    
    @available(*, deprecated, message: "Do not use this, it's just for reference. Use `formatPaymentMethodSecondString()`")
    class func getPMSecondString(paymentData: PXPaymentData) -> NSAttributedString? {
        guard let paymentMethod = paymentData.paymentMethod else {
            return nil
        }
        let paymentMethodName = paymentMethod.name ?? ""
        
        var pmDescription = ""
        if paymentMethod.isCard {
            if let lastFourDigits = (paymentData.token?.lastFourDigits) {
                pmDescription = paymentMethodName + " " + "terminada en".localized + " " + lastFourDigits
            }
        } else if paymentMethod.paymentTypeId == "digital_currency" {
            pmDescription = paymentMethodName
        } else {
            return nil
        }
        
        let attributedSecond = secondStringAttributed(pmDescription)
        return attributedSecond
    }
    
    class func assembleSecondString(paymentMethodName: String, paymentMethodLastFourDigits lastFourDigits: String?, paymentTypeIdValue: String) -> String? {
        var pmDescription: String = ""
        if let paymentType = PXPaymentTypes(rawValue: paymentTypeIdValue), paymentType.isCard() {
            if let lastFourDigits = lastFourDigits {
                pmDescription = paymentMethodName + " " + "terminada en".localized + " " + lastFourDigits
            }
        } else if paymentTypeIdValue == "digital_currency" {
            pmDescription = paymentMethodName
        } else {
            return nil
        }
        return pmDescription
    }
    
    class func secondStringAttributed(_ string: String) -> NSAttributedString {
        return NSMutableAttributedString(string: string, attributes: PXNewCustomView.subtitleAttributes)
    }
    
    // PM Third String
    class func formatPaymentMethodThirdString(_ string: String?) -> NSAttributedString? {
        guard let paymentMethodDisplayDescription = string else { return nil }
        return thirdStringAttributed(paymentMethodDisplayDescription)
    }
    
    @available(*, deprecated, message: "Do not use this, it's just for reference. Use `formatPaymentMethodThirdString()`")
    class func getPMThirdString(paymentData: PXPaymentData) -> NSAttributedString? {
        guard let paymentMethodDisplayDescription = paymentData.paymentMethod?.creditsDisplayInfo?.description?.message else {
            return nil
        }
        let thirdAttributed = thirdStringAttributed(paymentMethodDisplayDescription)
        return thirdAttributed
    }
    
    class func thirdStringAttributed(_ string: String) -> NSAttributedString {
        return NSMutableAttributedString(string: string, attributes: PXNewCustomView.subtitleAttributes)
    }
}
