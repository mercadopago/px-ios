//
//  PXPaymentCongratsViewModel.swift
//  Pods
//
//  Created by Franco Risma on 28/07/2020.
//

import Foundation

class PXPaymentCongratsViewModel {

    private let paymentCongrats: PXPaymentCongrats

    init(paymentCongrats: PXPaymentCongrats) {
        self.paymentCongrats = paymentCongrats
    }

    func launch(navigationHandler: PXNavigationHandler, showWithAnimation animated: Bool, finishButtonAnimation: (() -> Void)? = nil) {
        let viewController = PXNewResultViewController(viewModel: self, finishButtonAnimation: finishButtonAnimation)
        navigationHandler.pushViewController(viewController: viewController, animated: animated)
    }

    // MARK: Private methods
    private func createPaymentMethodReceiptData(from paymentInfo: PXCongratsPaymentInfo) -> PXNewCustomViewData {
        let firstString = PXNewResultUtil.formatPaymentMethodFirstString(paymentInfo: paymentInfo)

        let secondString = PXNewResultUtil.formatPaymentMethodSecondString(paymentMethodName: paymentInfo.paymentMethodName,
                                                                           paymentMethodLastFourDigits: paymentInfo.paymentMethodLastFourDigits,
                                                                           paymentType: paymentInfo.paymentMethodType)

        let thirdString = PXNewResultUtil.formatPaymentMethodThirdString(paymentInfo.paymentMethodDescription)

        let defaultIcon = ResourceManager.shared.getImage("PaymentGeneric")
        let iconURL = paymentInfo.paymentMethodIconURL

        return PXNewCustomViewData(firstString: firstString, secondString: secondString, thirdString: thirdString, icon: defaultIcon, iconURL: iconURL, action: nil, color: .white)
    }
}

extension PXPaymentCongratsViewModel: PXNewResultViewModelInterface {
    // HEADER
    func getHeaderColor() -> UIColor {
        guard let color = paymentCongrats.headerColor else {
            return ResourceManager.shared.getResultColorWith(status: paymentCongrats.type.getDescription())
        }
        return color
    }

    func getHeaderTitle() -> String {
        return paymentCongrats.headerTitle
    }

    func getHeaderIcon() -> UIImage? {
        return paymentCongrats.headerImage
    }

    func getHeaderURLIcon() -> String? {
        return paymentCongrats.headerURL
    }

    func getHeaderBadgeImage() -> UIImage? {
        guard let image = paymentCongrats.headerBadgeImage else {
            return ResourceManager.shared.getBadgeImageWith(status: paymentCongrats.type.getDescription())
        }
        return image
    }

    func getHeaderCloseAction() -> (() -> Void)? {
        return paymentCongrats.headerCloseAction
    }

    //RECEIPT
    func mustShowReceipt() -> Bool {
        return paymentCongrats.shouldShowReceipt
    }

    func getReceiptId() -> String? {
        return paymentCongrats.receiptId
    }

    //POINTS AND DISCOUNTS
    ///POINTS
    func getPoints() -> PXPoints? {
        return paymentCongrats.points
    }

    func getPointsTapAction() -> ((String) -> Void)? {
        let action: (String) -> Void = { (deepLink) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapScorePath())
        }
        return action
    }

    ///DISCOUNTS
    func getDiscounts() -> PXDiscounts? {
        return paymentCongrats.discounts
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

    ///EXPENSE SPLIT VIEW
    func getExpenseSplit() -> PXExpenseSplit? {
        return paymentCongrats.expenseSplit
    }

    // This implementation is the same accross PXBusinessResultViewModel and PXResultViewModel, so it's ok to do it here
    func getExpenseSplitTapAction() -> (() -> Void)? {
        let action: () -> Void = { [weak self] in
            PXDeepLinkManager.open(self?.paymentCongrats.expenseSplit?.action.target)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapDeeplinkPath(), properties: PXCongratsTracking.getDeeplinkProperties(type: "money_split", deeplink: self?.paymentCongrats.expenseSplit?.action.target ?? ""))
        }
        return action
    }

    func getCrossSellingItems() -> [PXCrossSellingItem]? {
        return paymentCongrats.crossSelling
    }

    ///CROSS SELLING
    // This implementation is the same accross PXBusinessResultViewModel and PXResultViewModel, so it's ok to do it here
    func getCrossSellingTapAction() -> ((String) -> Void)? {
        let action: (String) -> Void = { (deepLink) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapCrossSellingPath())
        }
        return action
    }

    ////VIEW RECEIPT ACTION
    func getViewReceiptAction() -> PXRemoteAction? {
        return paymentCongrats.receiptAction
    }

    ////TOP TEXT BOX
    func getTopTextBox() -> PXText? {
        return nil
    }

    ////CUSTOM ORDER
    func getCustomOrder() -> Bool? {
        return paymentCongrats.hasCustomSorting
    }

    //INSTRUCTIONS
    func hasInstructions() -> Bool {
        return paymentCongrats.instructionsView != nil
    }

    func getInstructionsView() -> UIView? {
        return paymentCongrats.instructionsView
    }

    // PAYMENT METHOD
    func shouldShowPaymentMethod() -> Bool {
        return paymentCongrats.shouldShowPaymentMethod
    }

    func getPaymentViewData() -> PXNewCustomViewData? {
        guard let paymentInfo = paymentCongrats.paymentInfo else { return nil }
        return createPaymentMethodReceiptData(from: paymentInfo)
    }

    // SPLIT PAYMENT METHOD
    func getSplitPaymentViewData() -> PXNewCustomViewData? {
        guard let paymentInfo = paymentCongrats.splitPaymentInfo else { return nil }
        return createPaymentMethodReceiptData(from: paymentInfo)
    }

    // REJECTED BODY
    func shouldShowErrorBody() -> Bool {
        return paymentCongrats.errorBodyView != nil
    }

    func getErrorBodyView() -> UIView? {
        return paymentCongrats.errorBodyView
    }

    func getRemedyView(animatedButtonDelegate: PXAnimatedButtonDelegate?, remedyViewProtocol: PXRemedyViewProtocol?) -> UIView? {
        if isPaymentResultRejectedWithRemedy(), var remedyViewData = paymentCongrats.remedyViewData {
            remedyViewData.animatedButtonDelegate = animatedButtonDelegate
            remedyViewData.remedyViewProtocol = remedyViewProtocol
            return PXRemedyView(data: remedyViewData)
        }
        return nil
    }

    func getRemedyButtonAction() -> ((String?) -> Void)? {
        return nil
    }

    func isPaymentResultRejectedWithRemedy() -> Bool {
        return paymentCongrats.remedyViewData != nil
    }

    // FOOTER
    func getFooterMainAction() -> PXAction? {
        return paymentCongrats.mainAction
    }

    func getFooterSecondaryAction() -> PXAction? {
        return paymentCongrats.secondaryAction
    }

    // CUSTOM VIEWS
    func getImportantView() -> UIView? {
        return paymentCongrats.importantView
    }

    func getCreditsExpectationView() -> UIView? {
        return paymentCongrats.creditsExpectationView
    }

    func getTopCustomView() -> UIView? {
        return paymentCongrats.topView
    }

    func getBottomCustomView() -> UIView? {
        return paymentCongrats.bottomView
    }

    //CALLBACKS & TRACKING
    func getTrackingProperties() -> [String: Any] {
        if let internalTrackingValues = paymentCongrats.internalTrackingValues {
            return internalTrackingValues
        } else {
            guard let extConf = paymentCongrats.externalTrackingValues else { return [:] }
            let trackingConfiguration = PXTrackingConfiguration(trackListener: extConf.trackListener,
                                                                flowName: extConf.flowName,
                                                                flowDetails: extConf.flowDetails,
                                                                sessionId: extConf.sessionId)
            trackingConfiguration.updateTracker()

            var properties: [String: Any] = [:]
            properties["style"] = "custom"
            properties["payment_method_id"] = extConf.paymentMethodId
            properties["payment_method_type"] = extConf.paymentMethodType
            properties["payment_id"] = extConf.paymentId
            properties["payment_status"] = paymentCongrats.type.getRawValue()
            properties["preference_amount"] = extConf.totalAmount
            properties["payment_status_detail"] = extConf.paymentStatusDetail

            if let campaingId = extConf.campaingId {
                properties[PXCongratsTracking.TrackingKeys.campaignId.rawValue] = campaingId
            }

            if let currency = extConf.currencyId {
                properties["currency_id"] = currency
            }

            properties["has_split_payment"] = paymentCongrats.splitPaymentInfo != nil
            properties[PXCongratsTracking.TrackingKeys.hasBottomView.rawValue] = paymentCongrats.bottomView != nil
            properties[PXCongratsTracking.TrackingKeys.hasTopView.rawValue] = paymentCongrats.topView != nil
            properties[PXCongratsTracking.TrackingKeys.hasImportantView.rawValue] = paymentCongrats.importantView != nil
            properties[PXCongratsTracking.TrackingKeys.hasExpenseSplitView.rawValue] = paymentCongrats.expenseSplit != nil
            properties[PXCongratsTracking.TrackingKeys.scoreLevel.rawValue] = paymentCongrats.points?.progress.levelNumber
            properties[PXCongratsTracking.TrackingKeys.discountsCount.rawValue] = paymentCongrats.discounts?.items.count

            return properties
        }
    }

    func getTrackingPath() -> String {
        if let internalTrackingPath = paymentCongrats.internalTrackingPath {
            return internalTrackingPath
        } else {
            var screenPath = ""
            let paymentStatus = paymentCongrats.type.getRawValue()
            if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
                screenPath = TrackingPaths.Screens.PaymentResult.getSuccessPath(basePath: TrackingPaths.paymentCongrats)
            } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
                screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionPath(basePath: TrackingPaths.paymentCongrats)
            } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
                screenPath = TrackingPaths.Screens.PaymentResult.getErrorPath(basePath: TrackingPaths.paymentCongrats)
            }

            return screenPath
        }
    }

    func getFlowBehaviourResult() -> PXResultKey {
        guard let internalResult = paymentCongrats.internalFlowBehaviourResult else {
            switch paymentCongrats.type {
            case .approved: return .SUCCESS
            case .rejected: return .FAILURE
            case .pending, .inProgress: return .PENDING
            }
        }
        return internalResult
    }

    //URLs, and AutoReturn
    func shouldAutoReturn() -> Bool {
        return paymentCongrats.shouldAutoReturn
    }

    func getBackUrl() -> URL? {
        return nil
    }
}
