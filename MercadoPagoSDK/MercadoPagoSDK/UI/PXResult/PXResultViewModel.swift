//
//  PXResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 20/10/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MLBusinessComponents

internal class PXResultViewModel: NSObject {

    let amountHelper: PXAmountHelper
    var paymentResult: PaymentResult
    var instructionsInfo: PXInstructions?
    var pointsAndDiscounts: PXPointsAndDiscounts?
    var preference: PXPaymentResultConfiguration
    let remedy: PXRemedy?
    let oneTapDto: PXOneTapDto?
    var callback: ((PaymentResult.CongratsState, String?) -> Void)?

    init(amountHelper: PXAmountHelper, paymentResult: PaymentResult, instructionsInfo: PXInstructions? = nil, pointsAndDiscounts: PXPointsAndDiscounts?, resultConfiguration: PXPaymentResultConfiguration = PXPaymentResultConfiguration(), remedy: PXRemedy? = nil, oneTapDto: PXOneTapDto? = nil) {
        self.paymentResult = paymentResult
        self.instructionsInfo = instructionsInfo
        self.pointsAndDiscounts = pointsAndDiscounts
        self.preference = resultConfiguration
        self.amountHelper = amountHelper
        self.remedy = remedy
        self.oneTapDto = oneTapDto
    }

    func getPaymentData() -> PXPaymentData {
        guard let paymentData = paymentResult.paymentData else {
            fatalError("paymentResult.paymentData cannot be nil")
        }
        return paymentData
    }

    func setCallback(callback: @escaping ((PaymentResult.CongratsState, String?) -> Void)) {
        self.callback = callback
    }

    func getPaymentStatus() -> String {
        return paymentResult.status
    }

    func getPaymentStatusDetail() -> String {
        return paymentResult.statusDetail
    }

    func getPaymentId() -> String? {
        return paymentResult.paymentId
    }

    func isCallForAuth() -> Bool {
        return paymentResult.isCallForAuth()
    }

    func primaryResultColor() -> UIColor {
        return ResourceManager.shared.getResultColorWith(status: paymentResult.status, statusDetail: paymentResult.statusDetail)
    }
}

// MARK: PXCongratsTrackingDataProtocol Implementation
extension PXResultViewModel: PXCongratsTrackingDataProtocol {
    func hasBottomView() -> Bool {
        return getBottomCustomView() != nil
    }

    func hasTopView() -> Bool {
        return getTopCustomView() != nil
    }

    func hasImportantView() -> Bool {
        return false
    }

    func getScoreLevel() -> Int? {
        return PXNewResultUtil.getDataForPointsView(points: pointsAndDiscounts?.points)?.getRingNumber()
    }

    func getDiscountsCount() -> Int {
        guard let numberOfDiscounts = PXNewResultUtil.getDataForDiscountsView(discounts: pointsAndDiscounts?.discounts)?.getItems().count else { return 0 }
        return numberOfDiscounts
    }
    
    func getCampaignsIds() -> String? {
        guard let discounts = PXNewResultUtil.getDataForDiscountsView(discounts: pointsAndDiscounts?.discounts) else { return nil }
        var campaignsIdsArray: [String] = []
        for item in discounts.getItems() {
            if let id = item.trackIdForItem() {
                campaignsIdsArray.append(id)
            }
        }
        return campaignsIdsArray.isEmpty ? "" : campaignsIdsArray.joined(separator: ", ")
    }

    func getCampaignId() -> String? {
        guard let campaignId = amountHelper.campaign?.id else { return nil }
        return "\(campaignId)"
    }
}

// MARK: Tracking
extension PXResultViewModel {
    func getTrackingProperties() -> [String: Any] {
        var properties: [String: Any] = amountHelper.getPaymentData().getPaymentDataForTracking()
        properties["style"] = "generic"
        if let paymentId = paymentResult.paymentId {
            properties["payment_id"] = Int64(paymentId)
        }
        properties["payment_status"] = paymentResult.status
        properties["payment_status_detail"] = paymentResult.statusDetail

        properties["has_split_payment"] = amountHelper.isSplitPayment
        properties["currency_id"] = SiteManager.shared.getCurrency().id
        properties["discount_coupon_amount"] = amountHelper.getDiscountCouponAmountForTracking()
        properties = PXCongratsTracking.getProperties(dataProtocol: self, properties: properties)

        if let rawAmount = amountHelper.getPaymentData().getRawAmount() {
            properties["preference_amount"] = rawAmount.decimalValue
        }

        let paymentStatus = paymentResult.status
        if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            if let remedy = remedy, !(remedy.isEmpty) {
                properties["recoverable"] = true
                var remedies: [String] = []
                if remedy.suggestedPaymentMethod != nil {
                    remedies.append("payment_method_suggestion")
                } else if remedy.cvv != nil {
                    remedies.append("cvv_request")
                } else if remedy.highRisk != nil {
                    remedies.append("kyc_request")
                }
                if !(remedies.isEmpty) {
                    properties["remedies"] = remedies // [ payment_method_suggestion / cvv_request /  kyc_request ]
                }
            } else {
                properties["recoverable"] = false
                properties["remedies"] = []
            }
        }

        return properties
    }

    func getRemedyProperties() -> [String: Any] {
        var properties: [String: Any] = [:]
        guard let remedy = remedy else { return properties }

        var type: String?
        if remedy.suggestedPaymentMethod != nil {
            type = "payment_method_suggestion"
        } else if remedy.cvv != nil {
            type = "cvv_request"
        } else if remedy.highRisk != nil {
            type = "kyc_request"
        }
        if let type = type {
            properties["type"] = type // [ payment_method_suggestion / cvv_request /  kyc_request ]
        }
        if let trackingData = remedy.trackingData {
            properties["extra_info"] = trackingData
        }

        return properties
    }

    func getTrackingPath() -> String {
        let paymentStatus = paymentResult.status
        var screenPath = ""

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getSuccessPath()
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionPath()
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getErrorPath()
        }
        return screenPath
    }

    func getFlowBehaviourResult() -> PXResultKey {
        let isApprovedOfflinePayment = PXPayment.Status.PENDING.elementsEqual(paymentResult.status) && PXPayment.StatusDetails.PENDING_WAITING_PAYMENT.elementsEqual(paymentResult.statusDetail)

        if paymentResult.isApproved() || isApprovedOfflinePayment {
            return .SUCCESS
        } else if paymentResult.isRejected() {
            return .FAILURE
        } else {
            return .PENDING
        }
    }

    func getFooterPrimaryActionTrackingPath() -> String {
        let paymentStatus = paymentResult.status
        var screenPath = ""

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = ""
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = ""
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getErrorChangePaymentMethodPath()
        }
        return screenPath
    }

    func getFooterSecondaryActionTrackingPath() -> String {
        let paymentStatus = paymentResult.status
        var screenPath = ""

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getSuccessContinuePath()
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionContinuePath()
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = ""
        }
        return screenPath
    }

    func getHeaderCloseButtonTrackingPath() -> String {
        let paymentStatus = paymentResult.status
        var screenPath = ""

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getSuccessAbortPath()
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionAbortPath()
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getErrorAbortPath()
        }
        return screenPath
    }
}

// MARK: URL logic
extension PXResultViewModel {
    func getBackUrl() -> URL? {
        if let status = PXPaymentStatus(rawValue: getPaymentStatus()) {
            switch status {
            case .APPROVED:
                return URL(string: amountHelper.preference.backUrls?.success ?? "")
            case .PENDING:
                return URL(string: amountHelper.preference.backUrls?.pending ?? "")
            case .REJECTED:
                return URL(string: amountHelper.preference.backUrls?.failure ?? "")
            default:
                return nil
            }
        }
        return nil
    }

    func openURL(url: URL, success: @escaping (Bool) -> Void) {
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

// MARK: New Result View Model Interface
extension PXResultViewModel: PXNewResultViewModelInterface {
    func getHeaderColor() -> UIColor {
        return primaryResultColor()
    }

    func getHeaderTitle() -> String {
        return titleHeader(forNewResult: true).string
    }

    func getHeaderIcon() -> UIImage? {
        return iconImageHeader()
    }

    func getHeaderURLIcon() -> String? {
        return nil
    }

    func getHeaderBadgeImage() -> UIImage? {
        return badgeImage()
    }

    func getHeaderCloseAction() -> (() -> Void)? {
        let action = { [weak self] in
            if let callback = self?.callback {
                if let url = self?.getBackUrl() {
                    self?.openURL(url: url, success: { (_) in
                        callback(PaymentResult.CongratsState.EXIT, nil)
                    })
                } else {
                    callback(PaymentResult.CongratsState.EXIT, nil)
                }
            }
        }
        return action
    }

    func getRemedyButtonAction() -> ((String?) -> Void)? {
        let action = { [weak self] (text: String?) in
            if let properties = self?.getRemedyProperties() {
                MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Screens.PaymentResult.getErrorRemedyPath(), properties: properties)
            }

            if let callback = self?.callback {
                if self?.remedy?.cvv != nil {
                    callback(PaymentResult.CongratsState.RETRY_SECURITY_CODE, text)
                } else if self?.remedy?.suggestedPaymentMethod != nil {
                    callback(PaymentResult.CongratsState.RETRY_SILVER_BULLET, text)
                } else {
                    callback(PaymentResult.CongratsState.RETRY, text)
                }
            }
        }
        return action
    }

    func mustShowReceipt() -> Bool {
        return hasReceiptComponent()
    }

    func getReceiptId() -> String? {
        return paymentResult.paymentId
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

    func hasInstructions() -> Bool {
        return instructionsInfo?.getInstruction() != nil
    }

    func getInstructionsView() -> UIView? {
        guard let bodyComponent = buildBodyComponent() as? PXBodyComponent, bodyComponent.hasInstructions() else {
            return nil
        }
        return bodyComponent.render()
    }

    func shouldShowPaymentMethod() -> Bool {
        let isApproved = paymentResult.isApproved()
        return !hasInstructions() && isApproved
    }

    func getPaymentData() -> PXPaymentData? {
        return paymentResult.paymentData
    }

    func getAmountHelper() -> PXAmountHelper? {
        return amountHelper
    }

    func getSplitPaymentData() -> PXPaymentData? {
        return paymentResult.splitAccountMoney
    }

    func getSplitAmountHelper() -> PXAmountHelper? {
        return amountHelper
    }

    func shouldShowErrorBody() -> Bool {
        let bodyComponent = buildBodyComponent() as? PXBodyComponent
        return bodyComponent?.hasBodyError() ?? false
    }

    func getErrorBodyView() -> UIView? {
        if let bodyComponent = buildBodyComponent() as? PXBodyComponent,
            bodyComponent.hasBodyError() {
            return bodyComponent.render()
        }
        return nil
    }

    func getRemedyView(animatedButtonDelegate: PXAnimatedButtonDelegate?, remedyViewProtocol: PXRemedyViewProtocol?) -> UIView? {
        if isPaymentResultRejectedWithRemedy(),
            let remedy = remedy {
            let data = PXRemedyViewData(oneTapDto: oneTapDto,
                                        paymentData: getPaymentData(),
                                        amountHelper: getAmountHelper(),
                                        remedy: remedy,
                                        animatedButtonDelegate: animatedButtonDelegate,
                                        remedyViewProtocol: remedyViewProtocol,
                                        remedyButtonTapped: getRemedyButtonAction())
            return PXRemedyView(data: data)
        }
        return nil
    }

    func isPaymentResultRejectedWithRemedy() -> Bool {
        if paymentResult.isRejectedWithRemedy(),
            let remedy = remedy, remedy.isEmpty == false {
            return true
        }
        return false
    }

    func getFooterMainAction() -> PXAction? {
        return getActionButton()
    }

    func getFooterSecondaryAction() -> PXAction? {
        return getActionLink()
    }

    func getImportantView() -> UIView? {
        return nil
    }

    func getCreditsExpectationView() -> UIView? {
        if let resultInfo = amountHelper.getPaymentData().getPaymentMethod()?.creditsDisplayInfo?.resultInfo,
            let title = resultInfo.title,
            let subtitle = resultInfo.subtitle {
            return PXCreditsExpectationView(title: title, subtitle: subtitle)
        }
        return nil
    }

    func getTopCustomView() -> UIView? {
        if paymentResult.isApproved() {
            return preference.getTopCustomView()
        }
        return nil
    }

    func getBottomCustomView() -> UIView? {
        if paymentResult.isApproved() {
            return preference.getBottomCustomView()
        }
        return nil
    }
}
