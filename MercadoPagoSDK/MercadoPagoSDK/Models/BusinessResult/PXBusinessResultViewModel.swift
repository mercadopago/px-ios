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
        let action = {  [weak self] in
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
        guard paymentData.paymentMethod?.id == "consumer_credits" else { return nil}
        if let resultInfo = amountHelper.getPaymentData().getPaymentMethod()?.creditsDisplayInfo?.resultInfo,
            let title = resultInfo.title,
            let subtitle = resultInfo.subtitle,
            businessResult.isApproved() {
            return PXCreditsExpectationView(title: title, subtitle: subtitle)
        }
        return nil
    }
    
    private func getCongratsType() -> PXCongratsType {
        switch businessResult.getBusinessStatus() {
            case .APPROVED: return PXCongratsType.approved
            case .REJECTED: return PXCongratsType.rejected
            case .IN_PROGRESS: return PXCongratsType.inProgress
            case .PENDING: return PXCongratsType.pending
            default: return PXCongratsType.pending
        }
    }
    
    private func paymentMethodShouldBeShown() -> Bool {
        return businessResult.isApproved()
    }

    func getPaymentMethodsImageURLs() -> [String: String]? {
        return pointsAndDiscounts?.paymentMethodsImages
    }
    
    private func getLinkAction() -> PXAction? {
        return businessResult.getSecondaryAction() != nil ? businessResult.getSecondaryAction() : PXCloseLinkAction()
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
        
        let status = businessResult.getBusinessStatus()
        switch status {
            case .APPROVED:
                return fieldId == .APPROVED
            default:
                return fieldId == .ALL
        }
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

    func getBackUrl() -> URL? {
        return getUrl(backUrls: amountHelper.preference.backUrls)
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
        
        // Receipt
        paymentCongratsData.withReceipt(shouldShowReceipt: businessResult.mustShowReceipt(), receiptId: businessResult.getReceiptId(), action: pointsAndDiscounts?.viewReceiptAction)
        
        // Points & Discounts
        paymentCongratsData.withLoyalty(pointsAndDiscounts?.points)
            .withDiscounts(pointsAndDiscounts?.discounts)
            .withCrossSelling(pointsAndDiscounts?.crossSelling)
            .withCustomSorting(pointsAndDiscounts?.customOrder)
            .withExpenseSplit(pointsAndDiscounts?.expenseSplit)
        
        // Payment Info
        if let paymentMethodTypeId = paymentData.paymentMethod?.paymentTypeId,
            let paymentType = PXPaymentTypes(rawValue: paymentMethodTypeId) {
            paymentCongratsData.withPaymentMethodInfo(assemblePaymentMethodInfo(paymentData: paymentData, amountHelper: amountHelper, currency: SiteManager.shared.getCurrency(), paymentMethodType: paymentType))
        }
        
        
        // Split PaymentInfo
        if amountHelper.isSplitPayment,
            let splitPaymentData = amountHelper.splitAccountMoney,
            let splitPaymentMethodTypeId = splitPaymentData.paymentMethod?.paymentTypeId,
            let splitPaymentType = PXPaymentTypes(rawValue: splitPaymentMethodTypeId) {
            paymentCongratsData.withSplitPaymentInfo(assemblePaymentMethodInfo(paymentData: splitPaymentData, amountHelper: amountHelper, currency: SiteManager.shared.getCurrency(), paymentMethodType: splitPaymentType))
        }
        
        paymentCongratsData.shouldShowPaymentMethod(paymentMethodShouldBeShown())
            .withStatementDescription(businessResult.getStatementDescription())
        
        // Actions
        paymentCongratsData.withFooterMainAction(businessResult.getMainAction()).withFooterSecondaryAction(getLinkAction())
        
        // Views
        paymentCongratsData.withTopView(businessResult.getTopCustomView())
            .withImportantView(businessResult.getImportantCustomView())
            .withBottomView(businessResult.getBottomCustomView())
            .withCreditsExpectationView(creditsExpectationView())
            .withErrorBodyView(errorBodyView())
        
        // Tracking
        paymentCongratsData.withTrackingProperties(getTrackingProperties())
            .withFlowBehaviorResult(getFlowBehaviourResult())
            .withTrackingPath(getTrackingPath())

        // URL Managment
        paymentCongratsData.withRedirectURLs(getRedirectUrl())
            .shouldAutoReturn(shouldAutoReturn())
        return paymentCongratsData
    }
    
    private func assemblePaymentMethodInfo(paymentData: PXPaymentData, amountHelper: PXAmountHelper, currency: PXCurrency, paymentMethodType: PXPaymentTypes/*, paymentMethodId: String*/) -> PXCongratsPaymentInfo {
        var paidAmount = ""
        if let transactionAmountWithDiscount = paymentData.getTransactionAmountWithDiscount() {
            paidAmount = Utils.getAmountFormated(amount: transactionAmountWithDiscount, forCurrency: currency)
        } else {
            paidAmount = Utils.getAmountFormated(amount: amountHelper.amountToPay, forCurrency: currency)
        }
        
        let lastFourDigits = paymentData.token?.lastFourDigits
        let transactionAmount = Utils.getAmountFormated(amount: paymentData.transactionAmount?.doubleValue ?? 0.0, forCurrency: currency)
        let installmentRate = paymentData.payerCost?.installmentRate
        let installmentsCount = paymentData.payerCost?.installments ?? 0
        let installmentAmount = Utils.getAmountFormated(amount: paymentData.payerCost?.installmentAmount ?? 0.0, forCurrency: currency)
        let installmentsTotalAmount = Utils.getAmountFormated(amount:  paymentData.payerCost?.totalAmount ?? 0.0, forCurrency: currency)
        let paymentMethodExtraInfo = paymentData.paymentMethod?.creditsDisplayInfo?.description?.message
        let discountName = paymentData.discount?.name
        
        var iconURL: String? = nil
        if let paymentMethod = paymentData.paymentMethod, let paymentMethodsImageURLs = getPaymentMethodsImageURLs(), !paymentMethodsImageURLs.isEmpty {
            iconURL = PXNewResultUtil.getPaymentMethodIconURL(for: paymentMethod.id, using: paymentMethodsImageURLs)
        }
        
        return PXCongratsPaymentInfo(paidAmount: paidAmount,
                                     rawAmount: transactionAmount,
                                     paymentMethodName: paymentData.paymentMethod?.name,
                                     paymentMethodLastFourDigits: lastFourDigits,
                                     paymentMethodDescription: paymentMethodExtraInfo,
                                     paymentMethodIconURL: iconURL,
                                     paymentMethodType: paymentMethodType,
                                     installmentsRate: installmentRate,
                                     installmentsCount: installmentsCount,
                                     installmentsAmount: installmentAmount,
                                     installmentsTotalAmount: installmentsTotalAmount,
                                     discountName: discountName)
    }
}
