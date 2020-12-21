//
//  PXOneTapDto+Tracking.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 13/12/2018.
//

import Foundation

// MARK: Tracking
extension PXOneTapDto {
    private func getPaymentInfoForTracking() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["payment_method_type"] = paymentTypeId
        properties["payment_method_id"] = paymentMethodId
        return properties
    }

    private func getBenefitsInfoForTracking() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["has_interest_free"] = benefits?.interestFree != nil ? true : false
        properties["has_reimbursement"] = benefits?.reimbursement != nil ? true : false
        return properties
    }

    func getAccountMoneyForTracking() -> [String: Any] {
        var accountMoneyDic = getPaymentInfoForTracking()
        var extraInfo = getBenefitsInfoForTracking()
        extraInfo["balance"] = accountMoney?.availableBalance
        extraInfo["invested"] = accountMoney?.invested
        accountMoneyDic["extra_info"] = extraInfo

        return accountMoneyDic
    }

    func getPaymentMethodForTracking() -> [String: Any] {
        var paymentMethodDic = getPaymentInfoForTracking()
        paymentMethodDic["extra_info"] = getBenefitsInfoForTracking()
        return paymentMethodDic
    }

    func getCardForTracking(amountHelper: PXAmountHelper) -> [String: Any] {
        var savedCardDic = getPaymentInfoForTracking()
        var extraInfo = getBenefitsInfoForTracking()
        extraInfo["card_id"] = oneTapCard?.cardId
        let cardIdsEsc = PXTrackingStore.sharedInstance.getData(forKey: PXTrackingStore.cardIdsESC) as? [String] ?? []
        extraInfo["has_esc"] = cardIdsEsc.contains(oneTapCard?.cardId ?? "")
        if let cardId = oneTapCard?.cardId {
            extraInfo["selected_installment"] = amountHelper.paymentConfigurationService.getSelectedPayerCostsForPaymentMethod(cardId)?.getPayerCostForTracking()
            extraInfo["has_split"] = amountHelper.paymentConfigurationService.getSplitConfigurationForPaymentMethod(cardId) != nil
        }
        if let issuerId = oneTapCard?.cardUI?.issuerId {
            extraInfo["issuer_id"] = Int64(issuerId)
        }

        savedCardDic["extra_info"] = extraInfo
        return savedCardDic
    }
}
