//
//  ReviewMockComponentHelper.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 3/6/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

public class ReviewMockComponentHelper: NSObject {

    static func buildReviewViewModel(checkoutPreference: CheckoutPreference, reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference()) -> PXReviewViewModel {
        let paymentData = MockBuilder.buildPaymentData()
        let paymentOptionSelected = MockBuilder.buildPaymentOptionSelected("id")
        let reviewViewModel = PXReviewViewModel(checkoutPreference: checkoutPreference, paymentData: paymentData, paymentOptionSelected: paymentOptionSelected, reviewScreenPreference: reviewScreenPreference)
        return reviewViewModel
    }

    static func buildResultViewModelWithPreference(items: [Item], reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference()) -> PXReviewViewModel {

        let payer = MockBuilder.buildPayer("payer")
        let preference = CheckoutPreference(items: items, payer: payer, paymentMethods: nil)

        let reviewViewModel = ReviewMockComponentHelper.buildReviewViewModel(checkoutPreference: preference, reviewScreenPreference: reviewScreenPreference)
        return reviewViewModel
    }

    static func buildItemComponentView(reviewViewModel: PXReviewViewModel) -> [PXItemContainerView] {
        var itemViews = [PXItemContainerView]()
        let itemComponents = reviewViewModel.buildItemComponents()
        for item in itemComponents {
            itemViews.append(PXItemRenderer().render(item))
        }
        return itemViews
    }
}
