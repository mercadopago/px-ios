//
//  PXBusinessResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import MLBusinessComponents

class PXBusinessResultViewModel: NSObject {

    let businessResult: PXBusinessResult
    let pointsAndDiscounts: PXPointsAndDiscounts?
    let paymentData: PXPaymentData
    let amountHelper: PXAmountHelper
    var callback: ((PaymentResult.CongratsState, String?) -> Void)?

    //Default Image
    private lazy var approvedIconName = "default_item_icon"

    init(businessResult: PXBusinessResult, paymentData: PXPaymentData, amountHelper: PXAmountHelper, pointsAndDiscounts: PXPointsAndDiscounts?) {
        self.businessResult = businessResult
        self.paymentData = paymentData
        self.amountHelper = amountHelper
        self.pointsAndDiscounts = pointsAndDiscounts
        super.init()
    }

    func getPaymentId() -> String? {
        guard let firstPaymentId = businessResult.getReceiptIdList()?.first else { return businessResult.getReceiptId() }
        return firstPaymentId
    }

    func primaryResultColor() -> UIColor {
        return ResourceManager.shared.getResultColorWith(status: self.businessResult.getBusinessStatus().getDescription())
    }

    func setCallback(callback: @escaping ((PaymentResult.CongratsState, String?) -> Void)) {
        self.callback = callback
    }

    func getBadgeImage() -> UIImage? {
        return ResourceManager.shared.getBadgeImageWith(status: self.businessResult.getBusinessStatus().getDescription())
    }

    func getAttributedTitle(forNewResult: Bool = false) -> NSAttributedString {
        let title = businessResult.getTitle()
        let fontSize = forNewResult ? PXNewResultHeader.TITLE_FONT_SIZE : PXHeaderRenderer.TITLE_FONT_SIZE
        let attributes = [NSAttributedString.Key.font: Utils.getFont(size: fontSize)]
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        return attributedString
    }

    func getErrorComponent() -> PXErrorComponent? {
        guard let labelInstruction = self.businessResult.getHelpMessage() else {
            return nil
        }

        let title = PXResourceProvider.getTitleForErrorBody()
        let props = PXErrorProps(title: title.toAttributedString(), message: labelInstruction.toAttributedString())

        return PXErrorComponent(props: props)
    }
    
    func errorBodyView() -> UIView?  {
        if let errorComponent = getErrorComponent() {
            return errorComponent.render()
        }
        return nil
    }

    func getHeaderDefaultIcon() -> UIImage? {
        if let brIcon = businessResult.getIcon() {
             return brIcon
        } else if let defaultImage = ResourceManager.shared.getImage(approvedIconName) {
            return defaultImage
        }
        return nil
    }
}

// MARK: New Result View Model Interface
extension PXBusinessResultViewModel: PXNewResultViewModelInterface {
    func getPaymentViewData() -> PXNewCustomViewData? {
        return nil
    }
    
    func getSplitPaymentViewData() -> PXNewCustomViewData? {
        return nil
    }
    
    func getHeaderColor() -> UIColor {
        return primaryResultColor()
    }

    func getHeaderTitle() -> String {
        return getAttributedTitle().string
    }

    func getHeaderIcon() -> UIImage? {
        return getHeaderDefaultIcon()
    }

    func getHeaderURLIcon() -> String? {
        return businessResult.getImageUrl()
    }

    func getHeaderBadgeImage() -> UIImage? {
        return getBadgeImage()
    }

    func getHeaderCloseAction() -> (() -> Void)? {
        let action = { [weak self] in
            if let callback = self?.callback {
                callback(PaymentResult.CongratsState.EXIT, nil)
            }
        }
        return action
    }

    func getRemedyButtonAction() -> ((String?) -> Void)? {
        let action = { [weak self] (text: String?) in
            if let callback = self?.callback {
                callback(PaymentResult.CongratsState.EXIT, text)
            }
        }
        return action
    }

    func mustShowReceipt() -> Bool {
        return businessResult.mustShowReceipt()
    }

    func getReceiptId() -> String? {
        return businessResult.getReceiptId()
    }

    func getPoints() -> PXPoints? {
        return pointsAndDiscounts?.points
    }

    func getPointsTapAction() -> ((String) -> Void)? {
        let action: (String) -> Void = { (deepLink) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapScorePath())
        }
        return action
    }

    func getDiscounts() -> PXDiscounts? {
        return pointsAndDiscounts?.discounts
    }

    func getDiscountsTapAction() -> ((Int, String?, String?) -> Void)? {
        let action: (Int, String?, String?) -> Void = { (index, deepLink, trackId) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            PXCongratsTracking.trackTapDiscountItemEvent(index, trackId)
        }
        return action
    }

    func didTapDiscount(index: Int, deepLink: String?, trackId: String?) {
        PXDeepLinkManager.open(deepLink)
        PXCongratsTracking.trackTapDiscountItemEvent(index, trackId)
    }

    func getExpenseSplit() -> PXExpenseSplit? {
        return pointsAndDiscounts?.expenseSplit
    }

    func getExpenseSplitTapAction() -> (() -> Void)? {
        let action: () -> Void = { [weak self] in
            PXDeepLinkManager.open(self?.pointsAndDiscounts?.expenseSplit?.action.target)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapDeeplinkPath(), properties: PXCongratsTracking.getDeeplinkProperties(type: "money_split", deeplink: self?.pointsAndDiscounts?.expenseSplit?.action.target ?? ""))
        }
        return action
    }

    func getCrossSellingItems() -> [PXCrossSellingItem]? {
        return pointsAndDiscounts?.crossSelling
    }

    func getCrossSellingTapAction() -> ((String) -> Void)? {
        let action: (String) -> Void = { (deepLink) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapCrossSellingPath())
        }
        return action
    }

    func getViewReceiptAction() -> PXRemoteAction? {
        return pointsAndDiscounts?.viewReceiptAction
    }

    func getTopTextBox() -> PXText? {
        return pointsAndDiscounts?.topTextBox
    }

    func getCustomOrder() -> Bool? {
        return pointsAndDiscounts?.customOrder
    }

    func hasInstructions() -> Bool {
        return false
    }

    func getInstructionsView() -> UIView? {
        return nil
    }

    func shouldShowPaymentMethod() -> Bool {
        let isApproved = businessResult.isApproved()
        return !hasInstructions() && isApproved
    }

    func getPaymentData() -> PXPaymentData? {
        return paymentData
    }

    func getAmountHelper() -> PXAmountHelper? {
        return amountHelper
    }

    func getSplitPaymentData() -> PXPaymentData? {
        return amountHelper.splitAccountMoney
    }

    func getSplitAmountHelper() -> PXAmountHelper? {
        return amountHelper
    }

    func shouldShowErrorBody() -> Bool {
        return getErrorComponent() != nil
    }

    func getErrorBodyView() -> UIView? {
        if let errorComponent = getErrorComponent() {
            return errorComponent.render()
        }
        return nil
    }

    func getRemedyView(animatedButtonDelegate: PXAnimatedButtonDelegate?, remedyViewProtocol: PXRemedyViewProtocol?) -> UIView? {
        return nil
    }

    func isPaymentResultRejectedWithRemedy() -> Bool {
        return false
    }

    func getFooterMainAction() -> PXAction? {
        return businessResult.getMainAction()
    }

    func getFooterSecondaryAction() -> PXAction? {
        let linkAction = businessResult.getSecondaryAction() != nil ? businessResult.getSecondaryAction() : PXCloseLinkAction()
        return linkAction
    }

    func getImportantView() -> UIView? {
        return self.businessResult.getImportantCustomView()
    }

    func getCreditsExpectationView() -> UIView? {
        if let resultInfo = amountHelper.getPaymentData().getPaymentMethod()?.creditsDisplayInfo?.resultInfo,
            let title = resultInfo.title,
            let subtitle = resultInfo.subtitle,
            businessResult.isApproved() {
            return PXCreditsExpectationView(title: title, subtitle: subtitle)
        }
        return nil
    }

    func getTopCustomView() -> UIView? {
        return self.businessResult.getTopCustomView()
    }

    func getBottomCustomView() -> UIView? {
        return self.businessResult.getBottomCustomView()
    }
}

extension PXBusinessResultViewModel {
        func ToPaymentCongrats() -> PXPaymentCongrats {
            let paymentCongratsData = PXPaymentCongrats()
            //status
            paymentCongratsData.withStatus(businessResult.getBusinessStatus())
            //title
            paymentCongratsData.withHeaderTitle(getAttributedTitle().string)

            paymentCongratsData.withHeaderColor(primaryResultColor())

            //header icon
            paymentCongratsData.withHeaderImage(getHeaderDefaultIcon(), orURL: businessResult.getImageUrl())

            //Badge Image this is not necessary to call because the paymentCongrats have this default implementation
    //        if let badgeImage = ResourceManager.shared.getBadgeImageWith(status: businessResult.getBusinessStatus().getDescription()) {
    //            paymentCongratsData.withHeaderBadgeImage(badgeImage)
    //        }
            
            //Header Close Action
            paymentCongratsData.withHeaderCloseAction() { [weak self] in
                
            }

            //Recepit
            if businessResult.mustShowReceipt() {
                paymentCongratsData.shouldShowReceipt(receiptId: businessResult.getReceiptId())
            }
            

            //Points and Discounts
            paymentCongratsData.withPoints(pointsAndDiscounts?.points)
                               .withDiscounts(pointsAndDiscounts?.discounts)
                               .withCrossSelling(pointsAndDiscounts?.crossSelling)
                               .withViewReceiptAction(action: pointsAndDiscounts?.viewReceiptAction)
                               .shouldHaveCustomOrder(pointsAndDiscounts?.customOrder)

            if let expenseSplit = pointsAndDiscounts?.expenseSplit {
                paymentCongratsData.withExpenseSplit(expenseSplit.title, action: expenseSplit.action, imageURL: expenseSplit.imageUrl)
            }
            

            #warning("validate to connect the correct data")

            let pmTypeID = businessResult.getPaymentMethodTypeId()!
            let pmID = businessResult.getPaymentMethodId()!
            paymentCongratsData.withPaymentMethodInfo(assemblePaymentMethodInfo(paymentData: paymentData, amountHelper: amountHelper, currency: SiteManager.shared.getCurrency(), paymentMethodTypeId: pmTypeID, paymentMethodId: pmID))

            paymentCongratsData.withErrorBodyView(errorBodyView())
            
            if let label = businessResult.getMainAction()?.label, let action = businessResult.getMainAction()?.action {
            paymentCongratsData.withMainAction(label: label, action: action)
            }

            let linkAction = businessResult.getSecondaryAction() != nil ? businessResult.getSecondaryAction() : PXCloseLinkAction()

            paymentCongratsData.withSecondaryAction(label: linkAction!.label, action: linkAction!.action)

            paymentCongratsData.withCustomViews(important: businessResult.getImportantCustomView(), top: businessResult.getTopCustomView(), bottom: businessResult.getBottomCustomView())

            if let resultInfo = amountHelper.getPaymentData().getPaymentMethod()?.creditsDisplayInfo?.resultInfo,
                let title = resultInfo.title,
                let subtitle = resultInfo.subtitle,
                businessResult.isApproved() {
                paymentCongratsData.withCreditsExpectationView(PXCreditsExpectationView(title: title, subtitle: subtitle))
            }
            return paymentCongratsData
        }

        private func assemblePaymentMethodInfo(paymentData: PXPaymentData, amountHelper: PXAmountHelper, currency: PXCurrency, paymentMethodTypeId: String, paymentMethodId: String) -> PXCongratsPaymentInfo {
            let paidAmount = "\(paymentData.getTransactionAmountWithDiscount())"
            let paymentMethodName = paymentData.paymentMethod?.name ?? ""
            let lastFourDigits = paymentData.token?.lastFourDigits
            let transactionAmount = "\(paymentData.transactionAmount)"
            let hasInstallments = paymentData.payerCost != nil
            let installmentRate = paymentData.payerCost?.installmentRate
            let paidAmountPosta = paymentData.payerCost?.totalAmount
            let installments = paymentData.payerCost?.installments ?? 0
            let installmentAmount = "\(paymentData.payerCost?.installmentAmount)"
            let amountToPay = amountHelper.amountToPay
            let paymentMethodExtraInfo = paymentData.paymentMethod?.creditsDisplayInfo?.description?.message
                //getTransactionAmountWithDiscount()
            // TODO format prices with currency
            return PXCongratsPaymentInfo(paidAmount: paidAmount, transactionAmount: transactionAmount, paymentMethodName: paymentMethodName, paymentMethodLastFourDigits: lastFourDigits, paymentMethodExtraInfo: paymentMethodExtraInfo, paymentMethodId: paymentMethodId, paymentMethodType: PXPaymentTypes(rawValue: paymentMethodTypeId)!, hasInstallments: hasInstallments, installmentsRate: installmentRate, installmentsCount: installments, installmentAmount: installmentAmount, hasDiscount: false, discountName: nil)
        }
}
