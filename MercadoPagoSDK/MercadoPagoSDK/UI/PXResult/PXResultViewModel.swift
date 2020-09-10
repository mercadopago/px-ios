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
    
    func headerCloseAction() -> () -> () {
        return { [weak self] in
            guard let self = self else { return }
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
    }
    
    func creditsExpectationView() -> UIView? {
        guard paymentResult.paymentData?.paymentMethod?.id == "consumer_credits" else { return nil }
        if let resultInfo = amountHelper.getPaymentData().getPaymentMethod()?.creditsDisplayInfo?.resultInfo,
            let title = resultInfo.title,
            let subtitle = resultInfo.subtitle {
            return PXCreditsExpectationView(title: title, subtitle: subtitle)
        }
        return nil
    }
    
    func errorBodyView() -> UIView? {
        if let bodyComponent = buildBodyComponent() as? PXBodyComponent,
            bodyComponent.hasBodyError() {
            return bodyComponent.render()
        }
        return nil
    }
    
    func instructionsView() -> UIView? {
        guard let bodyComponent = buildBodyComponent() as? PXBodyComponent, bodyComponent.hasInstructions() else {
            return nil
        }
        return bodyComponent.render()
    }
    
    private func getRemedyViewData() -> PXRemedyViewData? {
        if isPaymentResultRejectedWithRemedy(),
            let remedy = remedy {
            return PXRemedyViewData(oneTapDto: oneTapDto,
                                    paymentData: paymentResult.paymentData,
                                    amountHelper: amountHelper,
                                    remedy: remedy,
                                    animatedButtonDelegate: nil,
                                    remedyViewProtocol: nil,
                                    remedyButtonTapped: getRemedyButtonAction())
        }
        return nil
    }
    
    private func getRemedyButtonAction() -> ((String?) -> Void)? {
        let action = { (text: String?) in
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Screens.PaymentResult.getErrorRemedyPath(), properties: self.getRemedyProperties())
            
            if let callback = self.callback {
                if self.remedy?.cvv != nil {
                    callback(PaymentResult.CongratsState.RETRY_SECURITY_CODE, text)
                } else if self.remedy?.suggestedPaymentMethod != nil {
                    callback(PaymentResult.CongratsState.RETRY_SILVER_BULLET, text)
                } else {
                    callback(PaymentResult.CongratsState.RETRY, text)
                }
            }
        }
        return action
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

    func hasExpenseSplitView() -> Bool {
        return pointsAndDiscounts?.expenseSplit != nil && MLBusinessAppDataService().isMp() ? true : false
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
    func getRemedyProperties() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["payment_status"] = paymentResult.status
        properties["payment_status_detail"] = paymentResult.statusDetail
        guard let remedy = remedy else { return properties }

        properties["index"] = 0
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
    
    private func paymentMethodShouldBeShown() -> Bool {
        let isApproved = paymentResult.isApproved()
        return !hasInstructions() && isApproved
    }
    
    private func hasInstructions() -> Bool {
        return instructionsInfo?.getInstruction() != nil
    }
    
	func getPaymentMethodsImageURLs() -> [String: String]? {
        return pointsAndDiscounts?.paymentMethodsImages
    }

    private func getTopCustomView() -> UIView? {
        if paymentResult.isApproved() {
            return preference.getTopCustomView()
        }
        return nil
    }
    
    private func getBottomCustomView() -> UIView? {
        if paymentResult.isApproved() {
            return preference.getBottomCustomView()
        }
        return nil
    }
    
    internal func getRedirectUrl() -> URL? {
        return getUrl(backUrls: amountHelper.preference.redirectUrls, appendLanding: true)
    }
    
    private func shouldAutoReturn() -> Bool {
        guard let autoReturn = amountHelper.preference.autoReturn,
            let fieldId = PXNewResultUtil.PXAutoReturnTypes(rawValue: autoReturn),
            getBackUrl() != nil else {
                return false
        }
        
        let status = PXPaymentStatus(rawValue: getPaymentStatus())
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
    
    private func getUrl(backUrls: PXBackUrls?, appendLanding: Bool = false) -> URL? {
        var urlString: String?
        let status = PXPaymentStatus(rawValue: getPaymentStatus())
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
    
    private func isPaymentResultRejectedWithRemedy() -> Bool {
        if paymentResult.isRejectedWithRemedy(),
            let remedy = remedy, remedy.isEmpty == false {
            return true
        }
        return false
    }
}

extension PXResultViewModel: PXViewModelTrackingDataProtocol {
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
    
    func getTrackingProperties() -> [String: Any] {
        var properties: [String: Any] = amountHelper.getPaymentData().getPaymentDataForTracking()
        properties["style"] = "generic"
        if let paymentId = getPaymentId() {
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
            var remedies: [[String: Any]] = []
            if let remedy = remedy,
                !(remedy.isEmpty) {
                if remedy.suggestedPaymentMethod != nil {
                    remedies.append(["index": 0,
                                     "type": "payment_method_suggestion",
                                     "extra_info": remedy.trackingData ?? ""])
                } else if remedy.cvv != nil {
                    remedies.append(["index": 0,
                                     "type": "cvv_request",
                                     "extra_info": remedy.trackingData ?? ""])
                } else if remedy.highRisk != nil {
                    remedies.append(["index": 0,
                                     "type": "kyc_request",
                                     "extra_info": remedy.trackingData ?? ""])
                }
            }
            properties["remedies"] = remedies
        }

        return properties
    }

}

extension PXResultViewModel {
    func toPaymentCongrats() -> PXPaymentCongrats {
        let paymentcongrats = PXPaymentCongrats()
            .withCongratsType(congratsType(fromResultStatus: self.paymentResult.status))
            .withHeaderColor(primaryResultColor())
            .withHeader(title: titleHeader(forNewResult: true).string, imageURL: nil, closeAction: headerCloseAction())
            .withHeaderImage(iconImageHeader())
            .withHeaderBadgeImage(badgeImage())
            .withReceipt(shouldShowReceipt: hasReceiptComponent(), receiptId: getPaymentId(), action: pointsAndDiscounts?.viewReceiptAction)
            .withLoyalty(pointsAndDiscounts?.points)
            .withDiscounts(pointsAndDiscounts?.discounts)
            .withExpenseSplit(pointsAndDiscounts?.expenseSplit)
            .withCrossSelling(pointsAndDiscounts?.crossSelling)
            .withCustomSorting(pointsAndDiscounts?.customOrder)
            .withInstructionView(instructionsView())
            .withFooterMainAction(getActionButton())
            .withFooterSecondaryAction(getActionLink())
            .withImportantView(nil)
            .withTopView(getTopCustomView())
            .withBottomView(getBottomCustomView())
            .withRemedyViewData(getRemedyViewData())
            .withCreditsExpectationView(creditsExpectationView())
            .shouldShowPaymentMethod(paymentMethodShouldBeShown())
            .withRedirectURLs(getRedirectUrl())
            .shouldAutoReturn(shouldAutoReturn())
        
        if let paymentInfo = getPaymentMethod(paymentData: paymentResult.paymentData, amountHelper: amountHelper) {
            paymentcongrats.withPaymentMethodInfo(paymentInfo)
        }
        
        if amountHelper.isSplitPayment,
            let splitPaymentData = amountHelper.splitAccountMoney,
            let splitPaymentInfo = getPaymentMethod(paymentData: splitPaymentData, amountHelper: amountHelper) {
            paymentcongrats.withSplitPaymentInfo(splitPaymentInfo)
        }
        
        paymentcongrats.withStatementDescription(paymentResult.statementDescription)
        
        paymentcongrats.withFlowBehaviorResult(getFlowBehaviourResult())
                .withTrackingProperties(getTrackingProperties())
                .withTrackingPath(getTrackingPath())
                .withErrorBodyView(errorBodyView())
        
        return paymentcongrats
    }
    
    private func getPaymentMethod(paymentData: PXPaymentData?, amountHelper: PXAmountHelper) -> PXCongratsPaymentInfo? {
        guard let paymentData = paymentData,
            let paymentTypeIdString = paymentData.getPaymentMethod()?.paymentTypeId,
            let paymentType = PXPaymentTypes(rawValue: paymentTypeIdString),
            let paymentId = paymentData.getPaymentMethod()?.id
        else { return nil }
        
        return assemblePaymentMethodInfo(paymentData: paymentData, amountHelper: amountHelper, currency: SiteManager.shared.getCurrency(), paymentType: paymentType, paymentMethodId: paymentId, externalPaymentMethodInfo: paymentData.getPaymentMethod()?.externalPaymentPluginImageData as Data?)
    }
    
    private func assemblePaymentMethodInfo(paymentData: PXPaymentData, amountHelper: PXAmountHelper, currency: PXCurrency, paymentType: PXPaymentTypes, paymentMethodId: String, externalPaymentMethodInfo: Data?) -> PXCongratsPaymentInfo {
        var paidAmount: String
        if let transactionAmountWithDiscount = paymentData.getTransactionAmountWithDiscount() {
            paidAmount = Utils.getAmountFormated(amount: transactionAmountWithDiscount, forCurrency: currency)
        } else {
            paidAmount = Utils.getAmountFormated(amount: amountHelper.amountToPay, forCurrency: currency)
        }
        
        let transactionAmount = Utils.getAmountFormated(amount: paymentData.transactionAmount?.doubleValue ?? 0.0, forCurrency: currency)
        
        var installmentAmount: String? = nil
        if let amount = paymentData.payerCost?.installmentAmount {
            installmentAmount = Utils.getAmountFormated(amount: amount, forCurrency: currency)
        }
        
        var installmentsTotalAmount: String? = nil
        if let totalForInstallments = paymentData.payerCost?.totalAmount {
            installmentsTotalAmount = Utils.getAmountFormated(amount: totalForInstallments, forCurrency: currency)
        }
        
        var iconURL: String? = nil
        if let paymentMethod = paymentData.paymentMethod, let paymentMethodsImageURLs = getPaymentMethodsImageURLs(), !paymentMethodsImageURLs.isEmpty {
            iconURL = PXNewResultUtil.getPaymentMethodIconURL(for: paymentMethod.id, using: paymentMethodsImageURLs)
        }
        
        return PXCongratsPaymentInfo(paidAmount: paidAmount,
                                     rawAmount: transactionAmount,
                                     paymentMethodName: paymentData.paymentMethod?.name,
                                     paymentMethodLastFourDigits: paymentData.token?.lastFourDigits,
                                     paymentMethodDescription: paymentData.paymentMethod?.creditsDisplayInfo?.description?.message,
                                     paymentMethodIconURL: iconURL,
                                     paymentMethodType: paymentType,
                                     installmentsRate: paymentData.payerCost?.installmentRate,
                                     installmentsCount: paymentData.payerCost?.installments ?? 0,
                                     installmentsAmount: installmentAmount,
                                     installmentsTotalAmount: installmentsTotalAmount,
                                     discountName: paymentData.discount?.name)
    }
    
    private func congratsType(fromResultStatus stringStatus: String) -> PXCongratsType {
        switch stringStatus {
            case PXPaymentStatus.APPROVED.rawValue: return PXCongratsType.approved
            case PXPaymentStatus.PENDING.rawValue: return PXCongratsType.pending
            case PXPaymentStatus.IN_PROCESS.rawValue: return PXCongratsType.inProgress
            case PXPaymentStatus.REJECTED.rawValue: return PXCongratsType.rejected
            default: return PXCongratsType.rejected
        }
    }
}
