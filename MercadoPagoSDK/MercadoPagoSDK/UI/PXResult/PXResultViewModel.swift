//
//  PXResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 20/10/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MLBusinessComponents

internal class PXResultViewModel: PXResultViewModelInterface {

    var paymentResult: PaymentResult
    var instructionsInfo: PXInstructions?
    var pointsAndDiscounts: PointsAndDiscounts?
    var preference: PXPaymentResultConfiguration
    var callback: ((PaymentResult.CongratsState) -> Void)?
    let amountHelper: PXAmountHelper

    let warningStatusDetails = [PXRejectedStatusDetail.INVALID_ESC, PXRejectedStatusDetail.CALL_FOR_AUTH, PXRejectedStatusDetail.BAD_FILLED_CARD_NUMBER, PXRejectedStatusDetail.CARD_DISABLE, PXRejectedStatusDetail.INSUFFICIENT_AMOUNT, PXRejectedStatusDetail.BAD_FILLED_DATE, PXRejectedStatusDetail.BAD_FILLED_SECURITY_CODE, PXRejectedStatusDetail.REJECTED_INVALID_INSTALLMENTS, PXRejectedStatusDetail.BAD_FILLED_OTHER]

    init(amountHelper: PXAmountHelper, paymentResult: PaymentResult, instructionsInfo: PXInstructions? = nil, pointsAndDiscounts: PointsAndDiscounts?, resultConfiguration: PXPaymentResultConfiguration = PXPaymentResultConfiguration()) {
        self.paymentResult = paymentResult
        self.instructionsInfo = instructionsInfo
        self.pointsAndDiscounts = pointsAndDiscounts
        self.preference = resultConfiguration
        self.amountHelper = amountHelper
    }

    func getPaymentData() -> PXPaymentData {
        return self.paymentResult.paymentData!
    }

    func setCallback(callback: @escaping ((PaymentResult.CongratsState) -> Void)) {
        self.callback = callback
    }

    func getPaymentStatus() -> String {
        return self.paymentResult.status
    }

    func getPaymentStatusDetail() -> String {
        return self.paymentResult.statusDetail
    }

    func getPaymentId() -> String? {
        return self.paymentResult.paymentId
    }
    func isCallForAuth() -> Bool {
        return self.paymentResult.isCallForAuth()
    }

    func primaryResultColor() -> UIColor {
        return ResourceManager.shared.getResultColorWith(status: paymentResult.status, statusDetail: paymentResult.statusDetail)
    }
}

// MARK: Tracking
extension PXResultViewModel {
    func getTrackingProperties() -> [String: Any] {
        let currency_id = "currency_id"
        let discount_coupon_amount = "discount_coupon_amount"
        let has_split = "has_split_payment"
        let raw_amount = "preference_amount"

        var properties: [String: Any] = amountHelper.getPaymentData().getPaymentDataForTracking()
        properties["style"] = "generic"
        if let paymentId = paymentResult.paymentId {
            properties["payment_id"] = Int64(paymentId)
        }
        properties["payment_status"] = paymentResult.status
        properties["payment_status_detail"] = paymentResult.statusDetail

        properties[has_split] = amountHelper.isSplitPayment
        properties[currency_id] = SiteManager.shared.getCurrency().id
        properties[discount_coupon_amount] = amountHelper.getDiscountCouponAmountForTracking()

        if let rawAmount = amountHelper.getPaymentData().getRawAmount() {
            properties[raw_amount] = rawAmount.decimalValue
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
        let completionHandler : (Bool) -> Void = { result in
            sleep(1)
            success(result)
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: completionHandler)
        } else {
            success(false)
        }
    }
}

// MARK: New Result View Model Interface
extension PXResultViewModel: PXNewResultViewModelInterface {

    func getViews() -> [ResultViewData] {
        var views = [ResultViewData]()

        //Header View
        let headerView = buildHeaderView()
        views.append(ResultViewData(view: headerView, verticalMargin: 0, horizontalMargin: 0))

        //Important View

        //Points
        if let pointsView = buildPointsViews() {
            views.append(ResultViewData(view: pointsView, verticalMargin: PXLayout.M_MARGIN, horizontalMargin: PXLayout.L_MARGIN))
        }

        //Discounts
        if let discountsView = buildDiscountsViews() {
            views.append(ResultViewData(view: DividingLineView(hasTriangle: true), verticalMargin: PXLayout.M_MARGIN, horizontalMargin: PXLayout.L_MARGIN))
            views.append(ResultViewData(view: discountsView, verticalMargin: PXLayout.S_MARGIN, horizontalMargin: PXLayout.M_MARGIN))

            let button = PXOutlinedSecondaryButton()
            button.buttonTitle = "Ver todos los descuentos"

            views.append(ResultViewData(view: button, verticalMargin: PXLayout.M_MARGIN, horizontalMargin: PXLayout.L_MARGIN))
        } else {
            views.append(ResultViewData(view: DividingLineView(), verticalMargin: PXLayout.M_MARGIN, horizontalMargin: PXLayout.L_MARGIN))
        }

        //Instructions View
        if let bodyComponent = buildBodyComponent() as? PXBodyComponent, bodyComponent.hasInstructions() {
            views.append(ResultViewData(view: bodyComponent.render(), verticalMargin: 0, horizontalMargin: 0))
        }

        //Top Custom View
        if let topCustomView = buildTopCustomView() {
            views.append(ResultViewData(view: topCustomView, verticalMargin: 0, horizontalMargin: 0))
        }

        //Receipt View
        if let receiptView = buildReceiptView() {
            views.append(ResultViewData(view: receiptView, verticalMargin: 0, horizontalMargin: 0))
        }

        //Payment Method View
        if let paymentData = paymentResult.paymentData, let PMView = buildPaymentMethodView(paymentData: paymentData) {
            views.append(ResultViewData(view: PMView, verticalMargin: 0, horizontalMargin: 0))
        }

        //Split Payment View
        if let splitPaymentData = paymentResult.splitAccountMoney, let splitView = buildPaymentMethodView(paymentData: splitPaymentData) {
            views.append(ResultViewData(view: splitView, verticalMargin: 0, horizontalMargin: 0))
        }

        //Bottom Custom View
        if let bottomCustomView = buildBottomCustomView() {
            views.append(ResultViewData(view: bottomCustomView, verticalMargin: 0, horizontalMargin: 0))
        }

        //Separator View
        views.append(ResultViewData(view: DividingLineView(), verticalMargin: 0, horizontalMargin: 0))

        //Footer View
        let footerView = buildFooterView()
        views.append(ResultViewData(view: footerView, verticalMargin: 0, horizontalMargin: 0))

        return views
    }
}

// MARK: New Result View Model Builders
extension PXResultViewModel {
    //Header View
    func buildHeaderView() -> UIView {
        let data = PXNewResultHeaderData(color: primaryResultColor(), title: titleHeader(forNewResult: true).string, icon: iconImageHeader(), iconURL: nil, badgeImage: badgeImage(), closeAction: { [weak self] in
            if let callback = self?.callback {
                if let url = self?.getBackUrl() {
                    self?.openURL(url: url, success: { (_) in
                        callback(PaymentResult.CongratsState.cancel_EXIT)
                    })
                } else {
                    callback(PaymentResult.CongratsState.cancel_EXIT)
                }
            }
        })
        let headerView = PXNewResultHeader(data: data)
        return headerView
    }

    //Receipt View
    func buildReceiptView() -> UIView? {
        guard let props = getReceiptComponentProps(), let title = props.receiptDescriptionString else {
            return nil
        }
        let attributedTitle = NSAttributedString(string: title, attributes: PXNewCustomView.titleAttributes)
        let subtitle = props.dateLabelString ?? ""
        let attributedSubtitle = NSAttributedString(string: subtitle, attributes: PXNewCustomView.subtitleAttributes)
        let data = PXNewCustomViewData(firstString: attributedTitle, secondString: attributedSubtitle, thirdString: nil, icon: nil, iconURL: nil, action: nil, color: nil)
        let view = PXNewCustomView(data: data)
        return view
    }

    //Points View
    func buildPointsViews() -> UIView? {
//        guard let points = pointsAndDiscounts?.points else {return nil}
//        let pointsDelegate = RingViewDateDelegate(points: points)
        let mockData = LoyaltyRingData()
        let pointsView = MLBusinessLoyaltyRingView(mockData)
        return pointsView
    }

    //Discounts View
    func buildDiscountsViews() -> UIView? {
//        guard let discounts = pointsAndDiscounts?.discounts else {return nil}
//        let discountsDelegate = DiscountsBoxDataDelegate(discounts: discounts)
        let mockData = DiscountData()
        let discountsView = MLBusinessDiscountBoxView(mockData)
        return discountsView
    }

    //Payment Method View
    func buildPaymentMethodView(paymentData: PXPaymentData) -> UIView? {
        guard let data = PXNewCustomViewData.getDataFromPaymentData(paymentData, amountHelper: amountHelper) else {return nil}
        let view = PXNewCustomView(data: data)
        return view
    }

    //Footer View
    func buildFooterView() -> UIView {
        let footerView = buildFooterComponent().render()
        return footerView
    }

}
