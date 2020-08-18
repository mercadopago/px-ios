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

    //TRACKING
    class func trackScreenAndConversion(viewModel: PXNewResultViewModelInterface) {
        let path = viewModel.getTrackingPath()
        if !path.isEmpty {
            MPXTracker.sharedInstance.trackScreen(screenName: path, properties: viewModel.getTrackingProperties())

            let behaviourProtocol = PXConfiguratorManager.flowBehaviourProtocol
            behaviourProtocol.trackConversion(result: viewModel.getFlowBehaviourResult())
        }
    }

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

    //URL logic
    internal enum PXAutoReturnTypes: String {
        case APPROVED = "approved"
        case ALL = "all"
    }

    internal class func openURL(url: URL, success: @escaping (Bool) -> Void) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { result in
                sleep(1)
                success(result)
            })
        } else {
            success(false)
        }
    }
}

// MARK: Payment Method Logic
extension PXNewResultUtil {
    //PAYMENT METHOD ICON
    class func getPaymentMethodIcon(paymentMethod: PXPaymentMethod) -> UIImage? {
        return getPaymentMethodIcon(paymentTypeId: paymentMethod.paymentTypeId, paymentMethodId: paymentMethod.id, externalPaymentMethodImage: paymentMethod.externalPaymentPluginImageData as? Data)
    }
    
    class func getPaymentMethodIcon(paymentTypeId: String, paymentMethodId: String, externalPaymentMethodImage: Data? = nil) -> UIImage? {
        let defaultColor = paymentTypeId == PXPaymentTypes.ACCOUNT_MONEY.rawValue && paymentTypeId != PXPaymentTypes.PAYMENT_METHOD_PLUGIN.rawValue
        var paymentMethodImage: UIImage? =  ResourceManager.shared.getImageForPaymentMethod(withDescription: paymentMethodId, defaultColor: defaultColor)
        // Retrieve image for payment plugin or any external payment method.
        if paymentTypeId == PXPaymentTypes.PAYMENT_METHOD_PLUGIN.rawValue, let data = externalPaymentMethodImage {
            paymentMethodImage = UIImage(data: data)
        }
        return paymentMethodImage
    }
    
    //PAYMENT METHOD DATA
    class func formatPaymentMethodFirstString(paidAmount: String, transactionAmount: String?, hasInstallments: Bool, installmentsCount: Int, installmentsAmount: String?, installmentRate: Double?, installmentsTotalAmount: String?, hasDiscount: Bool, discountName: String?) -> NSAttributedString {
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
                let totalString = Utils.addParenthesis(installmentsTotalAmount ?? "")
                let attributedTotal = NSAttributedString(string: totalString, attributes: totalAmountAttributes)
                firstString.appendWithSpace(attributedTotal)
            } else {
                let attributedTitle = NSAttributedString(string: installmentsTotalAmount ?? "", attributes: PXNewCustomView.titleAttributes)
                firstString.append(attributedTitle)
            }
        } else {
            // Caso account money
            let attributed = NSAttributedString(string: paidAmount, attributes: PXNewCustomView.titleAttributes)
            firstString.append(attributed)
        }
        
        // Discount
        if hasDiscount, let transactionAmount = transactionAmount {
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
    
    class func thirdStringAttributed(_ string: String) -> NSAttributedString {
        return NSMutableAttributedString(string: string, attributes: PXNewCustomView.subtitleAttributes)
    }
}
