//
//  PXBusinessResultViewModel+Tracking.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 13/12/2018.
//

import Foundation
// MARK: Tracking
extension PXBusinessResultViewModel {
    func getFooterPrimaryActionTrackingPath() -> String {
        let paymentStatus = businessResult.paymentStatus
        var screenPath = ""
        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getSuccessPrimaryActionPath()
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionPrimaryActionPath()
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getErrorPrimaryActionPath()
        }
        return screenPath
    }

    func getFooterSecondaryActionTrackingPath() -> String {
        let paymentStatus = businessResult.paymentStatus
        var screenPath = ""
        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getSuccessSecondaryActionPath()
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionSecondaryActionPath()
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getErrorSecondaryActionPath()
        }
        return screenPath
    }

    func getHeaderCloseButtonTrackingPath() -> String {
        let paymentStatus = businessResult.paymentStatus
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

// MARK: PXCongratsTrackingDataProtocol Implementation
extension PXBusinessResultViewModel: PXCongratsTrackingDataProtocol {
    func hasBottomView() -> Bool {
        return businessResult.getBottomCustomView() != nil
    }

    func hasTopView() -> Bool {
        return businessResult.getTopCustomView() != nil
    }

    func hasImportantView() -> Bool {
        return businessResult.getImportantCustomView() != nil
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

extension PXBusinessResultViewModel: PXViewModelTrackingDataProtocol {
    func getTrackingPath() -> String {
        let paymentStatus = businessResult.paymentStatus
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
        switch businessResult.getBusinessStatus() {
        case .APPROVED:
            return .SUCCESS
        case .REJECTED:
            return .FAILURE
        case .PENDING:
            return .PENDING
        case .IN_PROGRESS:
            return .PENDING
        }
    }
    
    func getTrackingProperties() -> [String: Any] {
       var properties: [String: Any] = amountHelper.getPaymentData().getPaymentDataForTracking()
       properties["style"] = "custom"
       if let paymentId = getPaymentId() {
           properties["payment_id"] = Int64(paymentId)
       }
       properties["payment_status"] = businessResult.paymentStatus
       properties["payment_status_detail"] = businessResult.paymentStatusDetail
       properties["has_split_payment"] = amountHelper.isSplitPayment
       properties["currency_id"] = SiteManager.shared.getCurrency().id
       properties["discount_coupon_amount"] = amountHelper.getDiscountCouponAmountForTracking()
       properties = PXCongratsTracking.getProperties(dataProtocol: self, properties: properties)

       if let rawAmount = amountHelper.getPaymentData().getRawAmount() {
           properties["preference_amount"] = rawAmount.decimalValue
       }

       return properties
    }
}
