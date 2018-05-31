//
//  PXOneTapViewModel.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 15/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoPXTracking

final class PXOneTapViewModel: PXReviewViewModel {

    // Tracking overrides.
    override var screenName: String { return TrackingUtil.SCREEN_NAME_REVIEW_AND_CONFIRM_ONE_TAP }
    override var screenId: String { return TrackingUtil.SCREEN_ID_REVIEW_AND_CONFIRM_ONE_TAP }

    override func trackChangePaymentMethodEvent() {
        MPXTracker.sharedInstance.trackActionEvent(action: TrackingUtil.ACTION_ONE_TAP_CHANGE_PAYMENT_METHOD, screenId: screenId, screenName: screenName)
    }

    override func trackConfirmActionEvent() {
        MPXTracker.sharedInstance.trackActionEvent(action: TrackingUtil.ACTION_CHECKOUT_CONFIRMED, screenId: screenId, screenName: screenName)
    }

    override func trackInfo() {
        var properties: [String: String] = [TrackingUtil.METADATA_PAYMENT_METHOD_ID: paymentData.paymentMethod?.paymentMethodId ?? "", TrackingUtil.METADATA_PAYMENT_TYPE_ID: paymentData.paymentMethod?.paymentTypeId ?? "", TrackingUtil.METADATA_AMOUNT_ID: preference.getAmount().stringValue]

        if let customerCard = paymentOptionSelected as? CustomerPaymentMethod {
            properties[TrackingUtil.METADATA_CARD_ID] = customerCard.customerPaymentMethodId
        }
        if let installments = paymentData.payerCost?.installments {
            properties[TrackingUtil.METADATA_INSTALLMENTS] = installments.stringValue
        }

        MPXTracker.sharedInstance.trackScreen(screenId: screenId, screenName: screenName, properties: properties)
    }
}
