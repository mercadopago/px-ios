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
    class func trackScreenAndConversion(viewModel: PXViewModelTrackingDataProtocol) {
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

    //ATTRIBUTES FOR DISPLAYING PAYMENT METHOD
    static let totalAmountAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT),
        NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.45)
    ]

    static let interestRateAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT),
        NSAttributedString.Key.foregroundColor: ThemeManager.shared.noTaxAndDiscountLabelTintColor()
    ]

    static let discountAmountAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT),
        NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.45),
        NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue
    ]

    //PAYMENT METHOD ICON URL
    class func getPaymentMethodIconURL(for paymentMethodId: String, using paymentMethodsImageURLs: [String: String]) -> String? {
        guard paymentMethodsImageURLs.keys.contains(paymentMethodId), let iconURLString = paymentMethodsImageURLs[paymentMethodId] else {
            return nil
        }
        return iconURLString
    }

    class func formatPaymentMethodFirstString(paymentInfo: PXCongratsPaymentInfo) -> NSAttributedString {
        var firstString: NSMutableAttributedString = NSMutableAttributedString()

        if paymentInfo.hasInstallments { // Pago en cuotas
            if let installmentsAmount = paymentInfo.installmentsAmount, let installmentsTotalAmount = paymentInfo.installmentsTotalAmount {
                firstString = textForInstallmentsPayment(installmentsCount: paymentInfo.installmentsCount, installmentsRate: paymentInfo.installmentsRate, installmentsAmount: installmentsAmount, installmentsTotalAmount: installmentsTotalAmount)
            }
        } else { // Caso account money
            firstString.append(textForNonInstallmentPayment(paidAmount: paymentInfo.paidAmount))
        }

        if paymentInfo.hasDiscount {
            if let discountName = paymentInfo.discountName, let rawAmount = paymentInfo.rawAmount {
                let message = discountMessage(discountName, transactionAmount: rawAmount)
                firstString.append(message)
            }
        }

        return firstString
    }

    class func textForInstallmentsPayment(installmentsCount: Int, installmentsRate: Double, installmentsAmount: String, installmentsTotalAmount: String) -> NSMutableAttributedString {
        guard installmentsCount > 1 else {
            return NSMutableAttributedString(string: installmentsTotalAmount, attributes: PXNewCustomView.titleAttributes)
        }
        let finalString: NSMutableAttributedString = NSMutableAttributedString()
        let titleString = String(format: "%dx %@", installmentsCount, installmentsAmount)
        let attributedTitle = NSAttributedString(string: titleString, attributes: PXNewCustomView.titleAttributes)
        finalString.append(attributedTitle)

        // Installment Rate
        if installmentsRate == 0.0 {
            let interestRateString = String(format: " %@", "Sin interés".localized.lowercased())
            let attributedInsterest = NSAttributedString(string: interestRateString, attributes: interestRateAttributes)
            finalString.appendWithSpace(attributedInsterest)
        }

        // Total Amount
        let totalString = Utils.addParenthesis(installmentsTotalAmount)
        let attributedTotal = NSAttributedString(string: totalString, attributes: totalAmountAttributes)
        finalString.appendWithSpace(attributedTotal)

        return finalString
    }

    class func textForNonInstallmentPayment(paidAmount: String) -> NSAttributedString {
        return NSAttributedString(string: paidAmount, attributes: PXNewCustomView.titleAttributes)
    }

    class func discountMessage(_ text: String, transactionAmount: String) -> NSMutableAttributedString {
        let discountString = NSMutableAttributedString()

        let attributedAmount = NSAttributedString(string: transactionAmount, attributes: discountAmountAttributes)
        discountString.appendWithSpace(attributedAmount)

        let attributedMessage = NSAttributedString(string: text, attributes: interestRateAttributes)
        discountString.appendWithSpace(attributedMessage)

        return discountString
    }

    // PM Second String
    class func formatPaymentMethodSecondString(paymentMethodName: String?, paymentMethodLastFourDigits lastFourDigits: String?, paymentType: PXPaymentTypes) -> NSAttributedString? {
        guard let description = assembleSecondString(paymentMethodName: paymentMethodName ?? "", paymentMethodLastFourDigits: lastFourDigits, paymentType: paymentType) else { return nil }
        return secondStringAttributed(description)
    }

    class func assembleSecondString(paymentMethodName: String, paymentMethodLastFourDigits lastFourDigits: String?, paymentType: PXPaymentTypes) -> String? {
        var pmDescription: String = ""
        if paymentType.isCard() {
            if let lastFourDigits = lastFourDigits {
                pmDescription = paymentMethodName.capitalized + " " + "terminada en".localized + " " + lastFourDigits
            }
        } else if paymentType == PXPaymentTypes.DIGITAL_CURRENCY {
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
