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
    
    func headerCloseAction() -> (() -> Void) {
        let action = {
            if let callback = self.callback {
                if let url = self.getBackUrl() {
                    PXNewResultUtil.openURL(url: url, success: { (_) in
                        callback(PaymentResult.CongratsState.EXIT, nil)
                    })
                } else {
                    callback(PaymentResult.CongratsState.EXIT, nil)
                }
            }
        }
        return action
    }

    func primaryResultColor() -> UIColor {
        return ResourceManager.shared.getResultColorWith(status: businessResult.getBusinessStatus().getDescription())
    }

    func setCallback(callback: @escaping ((PaymentResult.CongratsState, String?) -> Void)) {
        self.callback = callback
    }

    func getBadgeImage() -> UIImage? {
        return ResourceManager.shared.getBadgeImageWith(status: businessResult.getBusinessStatus().getDescription())
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
    
    func creditsExpectationView() -> UIView? {
        if let resultInfo = amountHelper.getPaymentData().getPaymentMethod()?.creditsDisplayInfo?.resultInfo,
            let title = resultInfo.title,
            let subtitle = resultInfo.subtitle,
            businessResult.isApproved() {
            return PXCreditsExpectationView(title: title, subtitle: subtitle)
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
        return headerCloseAction()
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
        return errorBodyView()
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
        return creditsExpectationView()
    }

    func getTopCustomView() -> UIView? {
        return self.businessResult.getTopCustomView()
    }

    func getBottomCustomView() -> UIView? {
        return self.businessResult.getBottomCustomView()
    }

    func shouldAutoReturn() -> Bool {
        guard let autoReturn = amountHelper.preference.autoReturn,
            let fieldId = PXNewResultUtil.PXAutoReturnTypes(rawValue: autoReturn),
            getBackUrl() != nil else {
            return false
        }

        let status = businessResult.getBusinessStatus()
        switch status {
        case .APPROVED:
            return fieldId == .APPROVED
        default:
            return fieldId == .ALL
        }
    }

    func getBackUrl() -> URL? {
        return getUrl(backUrls: amountHelper.preference.backUrls)
    }

    func getRedirectUrl() -> URL? {
        return getUrl(backUrls: amountHelper.preference.redirectUrls, appendLanding: true)
    }

    private func getUrl(backUrls: PXBackUrls?, appendLanding: Bool = false) -> URL? {
        var urlString: String?
        let status = businessResult.getBusinessStatus()
        switch status {
        case .APPROVED:
            urlString = backUrls?.success
        case .PENDING:
            urlString = backUrls?.pending
        case .REJECTED:
            urlString = backUrls?.failure
        default:
            return nil
        }
        if let urlString = urlString,
            !urlString.isEmpty {
            if appendLanding {
                let landingURL = MLBusinessAppDataService().appendLandingURLToString(urlString)
                return URL(string: landingURL)
            }
            return URL(string: urlString)
        }
        return nil
    }
    
    func getCongratsType() -> PXCongratsType{
        switch businessResult.getBusinessStatus() {
        case .APPROVED:
            return .APPROVED
        case .REJECTED:
            return .REJECTED
        case .IN_PROGRESS:
            return .IN_PROGRESS
        case .PENDING:
            return .PENDING
        default:
            return .PENDING
        }
    }
    
    func getLinkAction() -> PXAction? {
        return businessResult.getSecondaryAction() != nil ? businessResult.getSecondaryAction() : PXCloseLinkAction()
    }
}

extension PXBusinessResultViewModel {
    func toPaymentCongrats() -> PXPaymentCongrats {
        let paymentCongratsData = PXPaymentCongrats()
            .withCongratsType(getCongratsType())
        
        paymentCongratsData.withHeader(title: getAttributedTitle().string, imageURL: businessResult.getImageUrl(), closeAction: headerCloseAction())
            .withHeaderColor(primaryResultColor())
            .withHeaderImage(getHeaderDefaultIcon())
            .withHeaderBadgeImage(getBadgeImage())
        
        //Recepit
        paymentCongratsData.withReceipt(shouldShowReceipt: businessResult.mustShowReceipt(), receiptId: businessResult.getReceiptId(), action: pointsAndDiscounts?.viewReceiptAction)
        
        //Points and Discounts
        paymentCongratsData.withLoyalty(pointsAndDiscounts?.points)
            .withDiscounts(pointsAndDiscounts?.discounts)
            .withCrossSelling(pointsAndDiscounts?.crossSelling)
            .withCustomSorting(pointsAndDiscounts?.customOrder)
            .withExpenseSplit(pointsAndDiscounts?.expenseSplit)
        
        //Payment Info
        
        if let paymentMethodTypeId = paymentData.paymentMethod?.paymentTypeId, let paymentType = PXPaymentTypes(rawValue: paymentMethodTypeId), let paymentMethodId = paymentData.paymentMethod?.getId() {
            paymentCongratsData.withPaymentMethodInfo(assemblePaymentMethodInfo(paymentData: paymentData, amountHelper: amountHelper, currency: SiteManager.shared.getCurrency(), paymentMethodType: paymentType, paymentMethodId: paymentMethodId))
        }
        
        
        //Split Payment info
        if amountHelper.isSplitPayment,
            let splitPaymentData = amountHelper.splitAccountMoney,
            let splitPaymentMethodTypeId = splitPaymentData.paymentMethod?.paymentTypeId,
            let splitPaymentType = PXPaymentTypes(rawValue: splitPaymentMethodTypeId),
            let splitPaymentMethodId = splitPaymentData.paymentMethod?.getId() {
            paymentCongratsData.withSplitPaymentInfo(assemblePaymentMethodInfo(paymentData: splitPaymentData, amountHelper: amountHelper, currency: SiteManager.shared.getCurrency(), paymentMethodType: splitPaymentType, paymentMethodId: splitPaymentMethodId))
        }
        
        paymentCongratsData.shouldShowPaymentMethod(shouldShowPaymentMethod())
            .withStatementDescription(businessResult.getStatementDescription())
        
        //Actions
        paymentCongratsData.withFooterMainAction(businessResult.getMainAction()).withFooterSecondaryAction(getLinkAction())
        
        //Views
        paymentCongratsData.withTopView(businessResult.getTopCustomView())
            .withImportantView(businessResult.getImportantCustomView())
            .withBottomView(businessResult.getBottomCustomView())
            .withCreditsExpectationView(creditsExpectationView())
            .withErrorBodyView(errorBodyView())
        
        //tracking
        paymentCongratsData.withTrackingProperties(getTrackingProperties())
            .withFlowBehaviorResult(getFlowBehaviourResult())
        return paymentCongratsData
    }
    
    private func assemblePaymentMethodInfo(paymentData: PXPaymentData, amountHelper: PXAmountHelper, currency: PXCurrency, paymentMethodType: PXPaymentTypes, paymentMethodId: String) -> PXCongratsPaymentInfo {
        var paidAmount = ""
        if let transactionAmountWithDiscount = paymentData.getTransactionAmountWithDiscount() {
            paidAmount = Utils.getAmountFormated(amount: transactionAmountWithDiscount, forCurrency: currency)
        } else {
            paidAmount = Utils.getAmountFormated(amount: amountHelper.amountToPay, forCurrency: currency)
        }
        
        
        let paymentMethodName = paymentData.paymentMethod?.name ?? ""
        let lastFourDigits = paymentData.token?.lastFourDigits
        let transactionAmount = Utils.getAmountFormated(amount: paymentData.transactionAmount?.doubleValue ?? 0.0, forCurrency: currency)
        let installmentRate = paymentData.payerCost?.installmentRate
        let installmentsCount = paymentData.payerCost?.installments ?? 0
        let installmentAmount = Utils.getAmountFormated(amount: paymentData.payerCost?.installmentAmount ?? 0.0, forCurrency: currency)
        let installmentsTotalAmount = Utils.getAmountFormated(amount:  paymentData.payerCost?.totalAmount ?? 0.0, forCurrency: currency)
        let paymentMethodExtraInfo = paymentData.paymentMethod?.creditsDisplayInfo?.description?.message
        let externalPaymentPluginImageData = paymentData.paymentMethod?.externalPaymentPluginImageData
        let discountName = paymentData.discount?.name
        
        return PXCongratsPaymentInfo(paidAmount: paidAmount, rawAmount: transactionAmount, paymentMethodName: paymentMethodName, paymentMethodLastFourDigits: lastFourDigits, paymentMethodDescription: paymentMethodExtraInfo, paymentMethodId: paymentMethodId, paymentMethodType: paymentMethodType, installmentsRate: installmentRate, installmentsCount: installmentsCount, installmentsAmount: installmentAmount, installmentsTotalAmount: installmentsTotalAmount, discountName: discountName, externalPaymentMethodImage: externalPaymentPluginImageData as Data?)
    }
}
