//
//  PXOneTapDto+Tracking.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 13/12/2018.
//

import Foundation

// MARK: Tracking
extension PXOneTapDto {
    func getAccountMoneyForTracking() -> [String: Any] {
        var accountMoneyDic: [String: Any] = [:]
        accountMoneyDic["payment_method_type"] = paymentTypeId
        accountMoneyDic["payment_method_id"] = paymentMethodId
        var extraInfo: [String: Any] = [:]
        extraInfo["balance"] = accountMoney?.availableBalance
        extraInfo["invested"] = accountMoney?.invested
        extraInfo["has_interest_free"] = benefits?.interestFree != nil ? true : false
        extraInfo["has_reimbursement"] = benefits?.reimbursement != nil ? true : false
        accountMoneyDic["extra_info"] = extraInfo

        return accountMoneyDic
    }

    func getPaymentMethodForTracking() -> [String: Any] {
        var paymentMethodDic: [String: Any] = [:]
        paymentMethodDic["payment_method_type"] = paymentTypeId
        paymentMethodDic["payment_method_id"] = paymentMethodId
        var extraInfo: [String: Any] = [:]
        extraInfo["has_interest_free"] = benefits?.interestFree != nil ? true : false
        extraInfo["has_reimbursement"] = benefits?.reimbursement != nil ? true : false
        paymentMethodDic["extra_info"] = extraInfo
        return paymentMethodDic
    }

    func getCardForTracking(amountHelper: PXAmountHelper) -> [String: Any] {
        var savedCardDic: [String: Any] = [:]
        savedCardDic["payment_method_type"] = paymentTypeId
        savedCardDic["payment_method_id"] = paymentMethodId
        var extraInfo: [String: Any] = [:]
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

        extraInfo["has_interest_free"] = benefits?.interestFree != nil ? true : false
        extraInfo["has_reimbursement"] = benefits?.reimbursement != nil ? true : false

        savedCardDic["extra_info"] = extraInfo
        return savedCardDic
    }
}
