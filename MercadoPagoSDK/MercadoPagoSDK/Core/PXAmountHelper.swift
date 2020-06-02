//
//  PXAmountHelper.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 29/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal struct PXAmountHelper {

    internal let preference: PXCheckoutPreference
    private let paymentData: PXPaymentData
    internal let chargeRules: [PXPaymentTypeChargeRule]?
    internal let paymentConfigurationService: PXPaymentConfigurationServices
    internal var splitAccountMoney: PXPaymentData?

    init (preference: PXCheckoutPreference, paymentData: PXPaymentData, chargeRules: [PXPaymentTypeChargeRule]?, paymentConfigurationService: PXPaymentConfigurationServices, splitAccountMoney: PXPaymentData?) {
        self.preference = preference
        self.paymentData = paymentData
        self.chargeRules = chargeRules
        self.paymentConfigurationService = paymentConfigurationService
        self.splitAccountMoney = splitAccountMoney
    }

    internal var consumedDiscount: Bool {
        return paymentData.consumedDiscount ?? false
    }

    var discount: PXDiscount? {
        return paymentData.discount
    }

    var campaign: PXCampaign? {
        return paymentData.campaign
    }

    var preferenceAmount: Double {
        return self.preference.getTotalAmount()
    }

    var preferenceAmountWithCharges: Double {
        return preferenceAmount + chargeRuleAmount
    }

    var amountToPay: Double {
        if let payerCost = paymentData.payerCost {
            return payerCost.totalAmount
        }
        if let couponAmount = paymentData.discount?.couponAmount {
            return preferenceAmount - couponAmount + chargeRuleAmount
        } else {
            return preferenceAmount + chargeRuleAmount
        }
    }

    var isSplitPayment: Bool {
        return splitAccountMoney != nil
    }

    func getAmountToPayWithoutPayerCost(_ paymentMethodId: String?) -> Double {
        guard let paymentMethodId = paymentMethodId, let amountFromPaymentMethod = paymentConfigurationService.getAmountToPayWithoutPayerCostForPaymentMethod(paymentMethodId) else {
            return amountToPayWithoutPayerCost
        }
        return amountFromPaymentMethod
    }

    private var amountToPayWithoutPayerCost: Double {
        if let couponAmount = paymentData.discount?.couponAmount {
            return preferenceAmount - couponAmount + chargeRuleAmount
        } else {
            return preferenceAmount + chargeRuleAmount
        }
    }

    var amountOff: Double {
        guard let discount = self.paymentData.discount else {
            return 0
        }
        return discount.couponAmount
    }

    var maxCouponAmount: Double? {
        if let maxCouponAmount = paymentData.campaign?.maxCouponAmount, maxCouponAmount > 0.0 {
            return maxCouponAmount
        }
        return nil
    }

    internal var chargeRuleAmount: Double {
        guard let rules = chargeRules else {
            return 0
        }
        for rule in rules {
            if rule.paymentTypeId == paymentData.paymentMethod?.paymentTypeId {
                return rule.amountCharge
            }
        }
        return 0
    }

    internal func getPaymentData() -> PXPaymentData {

        // Set total card amount with charges without discount
        if paymentData.transactionAmount == nil || paymentData.transactionAmount == 0 {
            self.paymentData.transactionAmount = NSDecimalNumber(floatLiteral: preferenceAmountWithCharges)
        }
        return paymentData
    }
}

internal extension PXAmountHelper {
    static func getRoundedAmountAsNsDecimalNumber(amount: Double?, forInit: Bool = false) -> NSDecimalNumber {
         guard let targetAmount = amount else { return 0 }
         let decimalPlaces: Double = forInit ? 2 : Double(SiteManager.shared.getCurrency().getDecimalPlacesOrDefault())
         let amountRounded: Double = Double(round(pow(10, decimalPlaces) * Double(targetAmount)) / pow(10, decimalPlaces))
         let amountString = String(format: "%\(decimalPlaces / 10)f", amountRounded)
         return NSDecimalNumber(string: amountString)
     }
}

// MARK: Tracking usage
internal extension PXAmountHelper {
    func getDiscountCouponAmountForTracking() -> Decimal {
        guard let couponAmount = paymentData.getDiscount()?.getCouponAmount()?.decimalValue else { return 0 }
        if let amPaymentDataAmount = splitAccountMoney?.getDiscount()?.getCouponAmount() {
            return amPaymentDataAmount.decimalValue + couponAmount
        }
        return couponAmount
    }
}
