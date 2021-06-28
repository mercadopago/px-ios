//
//  PXOneTapViewModel+Tracking.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 29/11/2018.
//

import Foundation
// MARK: Tracking
extension PXOneTapViewModel {
    func getAvailablePaymentMethodForTracking() -> [Any] {
        var dic: [Any] = []
        if let expressData = expressData {
            for expressItem in expressData where expressItem.newCard == nil {
                
                var itemForTracking : [String: Any]
                
                if expressItem.oneTapCard != nil {
                    itemForTracking = expressItem.getCardForTracking(amountHelper: amountHelper)
                } else if expressItem.accountMoney != nil {
                    itemForTracking = expressItem.getAccountMoneyForTracking()
                } else {
                    itemForTracking = expressItem.getPaymentMethodForTracking()
                }
                
                if let applicationsArray = expressItem.applications {
                    var applications: [[String : Any]] = []
                    
                    applicationsArray.forEach { application in
                        applications.append(getValidationProgramProperties(oneTapApplication: application))
                    }
                    
                    if var extraInfo = itemForTracking["extra_info"] as? [String: Any] {
                        extraInfo["methods_applications"] = applications
                        itemForTracking["extra_info"] = extraInfo
                    }
                    
                }
                
                dic.append(itemForTracking)
            }
        }
        return dic
    }

    func getPaymentMethodsQuantityForTracking(enabled: Bool) -> Int {
        var availablePMQuantity = 0
        if let expressData = expressData {
            for expressItem in expressData where expressItem.status.enabled == enabled && expressItem.newCard == nil {
                availablePMQuantity += 1
            }
        }
        return availablePMQuantity
    }

    func getInstallmentsScreenProperties(installmentData: PXInstallment, selectedCard: PXCardSliderViewModel) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["payment_method_id"] = amountHelper.getPaymentData().paymentMethod?.id
        properties["payment_method_type"] = amountHelper.getPaymentData().paymentMethod?.paymentTypeId
        properties["card_id"] =  selectedCard.getCardId()
        if let issuerId = amountHelper.getPaymentData().issuer?.id {
            properties["issuer_id"] = Int64(issuerId)
        }
        var dic: [Any] = []
        for payerCost in installmentData.payerCosts {
            dic.append(payerCost.getPayerCostForTracking())
        }
        properties["available_installments"] = dic
        return properties
    }

    func getConfirmEventProperties(selectedCard: PXCardSliderViewModel, selectedIndex: Int) -> [String: Any] {
        guard let paymentMethod = amountHelper.getPaymentData().paymentMethod else {
            return [:]
        }
        let cardIdsEsc = PXTrackingStore.sharedInstance.getData(forKey: PXTrackingStore.cardIdsESC) as? [String] ?? []

        var properties: [String: Any] = [:]
        properties["payment_method_selected_index"] = selectedIndex
        if paymentMethod.isCard {
            properties["payment_method_type"] = paymentMethod.paymentTypeId
            properties["payment_method_id"] = paymentMethod.id
            properties["review_type"] = "one_tap"
            var extraInfo: [String: Any] = [:]
            extraInfo["card_id"] = selectedCard.getCardId
            extraInfo["has_esc"] = cardIdsEsc.contains(selectedCard.getCardId() ?? "")
            extraInfo["selected_installment"] = amountHelper.getPaymentData().payerCost?.getPayerCostForTracking()
            if let issuerId = amountHelper.getPaymentData().issuer?.id {
                extraInfo["issuer_id"] = Int64(issuerId)
            }
            extraInfo["has_split"] = splitPaymentEnabled
            properties["extra_info"] = extraInfo
        } else {
            properties["payment_method_type"] = paymentMethod.id
            properties["payment_method_id"] = paymentMethod.id
            properties["review_type"] = "one_tap"
            var extraInfo: [String: Any] = [:]
            extraInfo["balance"] = selectedCard.accountMoneyBalance
            extraInfo["selected_installment"] = amountHelper.getPaymentData().payerCost?.getPayerCostForTracking(isDigitalCurrency: paymentMethod.isDigitalCurrency)
            properties["extra_info"] = extraInfo
        }
        return properties
    }

    func getOneTapScreenProperties(oneTapApplication: [PXOneTapApplication]) -> [String: Any] {
        var properties: [String: Any] = [:]
        let availablePaymentMethods = getAvailablePaymentMethodForTracking()
        let availablePMQuantity = getPaymentMethodsQuantityForTracking(enabled: true)
        let disabledPMQuantity = getPaymentMethodsQuantityForTracking(enabled: false)
        properties["available_methods"] = availablePaymentMethods
        properties["available_methods_quantity"] = availablePMQuantity
        properties["disabled_methods_quantity"] = disabledPMQuantity
        properties["total_amount"] = amountHelper.preferenceAmount
        properties["discount"] = amountHelper.getDiscountForTracking()
        var itemsDic: [Any] = []
        for item in amountHelper.preference.items {
            itemsDic.append(item.getItemForTracking())
        }
        properties["items"] = itemsDic
        return properties
    }

    func getErrorProperties(error: MPSDKError) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["path"] = TrackingPaths.Screens.OneTap.getOneTapPath()
        properties["style"] = Tracking.Style.snackbar
        properties["id"] = Tracking.Error.Id.genericError
        properties["message"] = "review_and_confirm_toast_error".localized
        properties["attributable_to"] = Tracking.Error.Atrributable.mercadopago
        var extraDic: [String: Any] = [:]
        extraDic["api_url"] =  error.requestOrigin
        properties["extra_info"] = extraDic
        return properties
    }

    func getSelectCardEventProperties(index: Int, count: Int) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["path"] = TrackingPaths.Screens.OneTap.getOneTapPath()
        properties["style"] = Tracking.Style.noScreen
        properties["id"] = Tracking.Error.Id.genericError
        properties["message"] = "No se pudo seleccionar la tarjeta ingresada"
        properties["attributable_to"] = Tracking.Error.Atrributable.mercadopago
        var extraDic: [String: Any] = [:]
        extraDic["index"] =  index
        extraDic["count"] =  count
        properties["extra_info"] = extraDic
        return properties
    }

    func getTargetBehaviourProperties(_ behaviour: PXBehaviour) -> [String: Any] {
        var properties: [String: Any] = [:]
        if let target = behaviour.target {
            properties["behaviour"] = behaviour.modal ?? ""
            properties["deepLink"] = target
        }
        return properties
    }

    func getDialogOpenProperties(_ behaviour: PXBehaviour, _ modalConfig: PXModal) -> [String: Any] {
        var properties: [String: Any] = [:]
        if behaviour.target != nil {
            return getTargetBehaviourProperties(behaviour)
        } else if let modal = behaviour.modal {
            properties["description"] = modal
            var actions = 0
            if modalConfig.mainButton != nil { actions += 1 }
            if modalConfig.secondaryButton != nil { actions += 1 }
            properties["actions"] = actions
        }
        return properties
    }

    func getDialogDismissProperties(_ behaviour: PXBehaviour, _ modalConfig: PXModal) -> [String: Any] {
        return getDialogOpenProperties(behaviour, modalConfig)
    }
    
    func getValidationProgramProperties(oneTapApplication: PXOneTapApplication) -> [String : Any] {
        var properties: [String: Any] = [:]
        var subProperties: [[String: Any]] = []
        properties["enable"] = oneTapApplication.status.enabled
        properties["payment_method_id"] = oneTapApplication.paymentMethod.id
        properties["payment_type_id"] = oneTapApplication.paymentMethod.type
        properties["status_detail"] = oneTapApplication.status.detail
        oneTapApplication.validationPrograms?.forEach { program in
            var programDict: [String: Any] = [:]
            programDict["id"] = program.id
            programDict["mandatory"] = program.mandatory
            subProperties.append(programDict)
        }
        properties["validation_programs"] = subProperties
        return properties
    }

    func getDialogActionProperties(_ behaviour: PXBehaviour, _ modalConfig: PXModal, _ type: String, _ button: PXRemoteAction?) -> [String: Any]? {
        guard let button = button else { return nil }
        var properties = getDialogOpenProperties(behaviour, modalConfig)
        properties["type"] = type
        properties["deepLink"] = button.target ?? ""
        return properties
    }
}
