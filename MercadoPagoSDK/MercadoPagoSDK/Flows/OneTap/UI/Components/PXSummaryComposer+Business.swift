//
//  PXSummaryComposer+Utils.swift
//  MercadoPagoSDK
//
//  Created by Federico Bustos Fierro on 14/05/2019.
//

import Foundation

extension PXSummaryComposer {
    // MARK: business
    func shouldDisplayChargeHelpIcon() -> Bool {
        return shouldDisplayChargesHelp
    }

    func getDiscount() -> PXDiscount? {
        if let discountData = getDiscountData() {
            return discountData.discountConfiguration.getDiscountConfiguration().discount
        }
        return nil
    }

    func getDiscountOverview() -> PXDiscountOverview? {
        return getDiscountData()?.discountConfiguration.getDiscountOverview()
    }

    func shouldDisplayCharges() -> Bool {
        return getChargesAmount() > 0
    }

    func getChargesAmount() -> Double {
        return amountHelper.chargeRuleAmount
    }

    func shouldDisplayDiscount() -> Bool {
        return getDiscountData() != nil
    }

    func getDiscountData() -> (discountConfiguration: PXDiscountConfiguration, campaign: PXCampaign)? {
        let paymentMethodId = selectedCard?.payerPaymentMethod?.paymentMethodId ?? selectedCard?.paymentMethodId
        
        let paymentTypeId = selectedCard?.payerPaymentMethod?.paymentTypeId ?? selectedCard?.paymentTypeId
        
        if let discountConfiguration = amountHelper.paymentConfigurationService.getDiscountConfigurationForPaymentMethodOrDefault(paymentOptionID: selectedCard?.cardId, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId),
            let campaign = discountConfiguration.getDiscountConfiguration().campaign {
            return (discountConfiguration, campaign)
        }
        return nil
    }

    // MARK: style
    func summaryColor() -> UIColor {
        return isDefaultStatusBarStyle ? UIColor.black : ThemeManager.shared.whiteColor()
    }

    func yourPurchaseSummaryTitle() -> String {
        return additionalInfoSummary?.purpose ?? "onetap_purchase_summary_title".localized
    }

    func yourPurchaseToShow() -> String {
        return Utils.getAmountFormated(amount: amountHelper.preferenceAmount, forCurrency: currency)
    }

    func discountColor() -> UIColor {
        return isDefaultStatusBarStyle ? ThemeManager.shared.noTaxAndDiscountLabelTintColor() : ThemeManager.shared.whiteColor()
    }

    func discountBriefColor() -> UIColor {
        return isDefaultStatusBarStyle ? ThemeManager.shared.discountBriefColorML() : ThemeManager.shared.discountBriefColorMP()
    }

    func helpIcon(color: UIColor, alpha: CGFloat = 1) -> UIImage? {
        var helperImage: UIImage? =  ResourceManager.shared.getImage("helper_ico_light")
        helperImage = helperImage?.mask(color: color)?.alpha(alpha)
        return helperImage
    }
}
