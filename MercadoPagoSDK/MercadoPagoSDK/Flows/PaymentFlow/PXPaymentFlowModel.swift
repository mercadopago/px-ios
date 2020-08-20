//
//  PXPaymentFlowModel.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 16/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal final class PXPaymentFlowModel: NSObject {
    var amountHelper: PXAmountHelper?
    var checkoutPreference: PXCheckoutPreference?
    let paymentPlugin: PXSplitPaymentProcessor?

    let mercadoPagoServices: MercadoPagoServices

    var paymentResult: PaymentResult?
    var instructionsInfo: PXInstructions?
    var pointsAndDiscounts: PXPointsAndDiscounts?
    var businessResult: PXBusinessResult?

    var productId: String?
    var shouldSearchPointsAndDiscounts: Bool = true
    let ESCBlacklistedStatus: [String]?

    init(paymentPlugin: PXSplitPaymentProcessor?, mercadoPagoServices: MercadoPagoServices, ESCBlacklistedStatus: [String]?) {
        self.paymentPlugin = paymentPlugin
        self.mercadoPagoServices = mercadoPagoServices
        self.ESCBlacklistedStatus = ESCBlacklistedStatus
    }

    enum Steps: String {
        case createPaymentPlugin
        case createDefaultPayment
        case getPointsAndDiscounts
        case getInstructions
        case createPaymentPluginScreen
        case finish
    }

    func nextStep() -> Steps {
        if needToCreatePaymentForPaymentPlugin() {
            return .createPaymentPlugin
        } else if needToShowPaymentPluginScreenForPaymentPlugin() {
            return .createPaymentPluginScreen
        } else if needToCreatePayment() {
            return .createDefaultPayment
        } else if needToGetPointsAndDiscounts() {
            return .getPointsAndDiscounts
        } else if needToGetInstructions() {
            return .getInstructions
        } else {
            return .finish
        }
    }

    func needToCreatePaymentForPaymentPlugin() -> Bool {
        if paymentPlugin == nil {
            return false
        }

        if !needToCreatePayment() {
            return false
        }

        if hasPluginPaymentScreen() {
            return false
        }

        assignToCheckoutStore()
        paymentPlugin?.didReceive?(checkoutStore: PXCheckoutStore.sharedInstance)

        if let shouldSupport = paymentPlugin?.support() {
            return shouldSupport
        }

        return false
    }

    func needToCreatePayment() -> Bool {
        return paymentResult == nil && businessResult == nil
    }

    func needToGetPointsAndDiscounts() -> Bool {
        if let paymentResult = paymentResult, shouldSearchPointsAndDiscounts, (paymentResult.isApproved() || needToGetInstructions()) {
            return true
        } else if let businessResult = businessResult, shouldSearchPointsAndDiscounts, businessResult.isApproved(), businessResult.isAccepted() {
            return true
        }
        return false
    }

    func needToGetInstructions() -> Bool {
        guard let paymentResult = self.paymentResult else {
            return false
        }

        guard !String.isNullOrEmpty(paymentResult.paymentId) else {
            return false
        }

        return isOfflinePayment() && instructionsInfo == nil
    }

    func needToShowPaymentPluginScreenForPaymentPlugin() -> Bool {
        if !needToCreatePayment() {
            return false
        }
        return hasPluginPaymentScreen()
    }

    func isOfflinePayment() -> Bool {
        guard let paymentTypeId = amountHelper?.getPaymentData().paymentMethod?.paymentTypeId else {
            return false
        }
        return !PXPaymentTypes.isOnlineType(paymentTypeId: paymentTypeId)
    }

    func assignToCheckoutStore() {
        if let amountHelper = amountHelper {
            PXCheckoutStore.sharedInstance.paymentDatas = [amountHelper.getPaymentData()]
            if let splitAccountMoney = amountHelper.splitAccountMoney {
                PXCheckoutStore.sharedInstance.paymentDatas.append(splitAccountMoney)
            }
        }
        PXCheckoutStore.sharedInstance.checkoutPreference = checkoutPreference
    }

    func cleanData() {
        paymentResult = nil
        businessResult = nil
        instructionsInfo = nil
    }
}

internal extension PXPaymentFlowModel {
    func hasPluginPaymentScreen() -> Bool {
        guard let paymentPlugin = paymentPlugin else {
            return false
        }
        assignToCheckoutStore()
        paymentPlugin.didReceive?(checkoutStore: PXCheckoutStore.sharedInstance)
        let processorViewController = paymentPlugin.paymentProcessorViewController()
        return processorViewController != nil
    }
}

// MARK: Manage ESC
internal extension PXPaymentFlowModel {
    func handleESCForPayment(status: String, statusDetails: String, errorPaymentType: String?) {
        guard let token = amountHelper?.getPaymentData().getToken() else {
            return
        }
        if let paymentStatus = PXPaymentStatus(rawValue: status),
            paymentStatus == PXPaymentStatus.APPROVED {
            // If payment was approved
            if let esc = token.esc {
                PXConfiguratorManager.escProtocol.saveESC(config: PXConfiguratorManager.escConfig, token: token, esc: esc)
            }
        } else {
            guard let errorPaymentType = errorPaymentType else {
                return
            }

            // If it has error Payment Type, check if the error was from a card
            if let isCard = PXPaymentTypes(rawValue: errorPaymentType)?.isCard(), isCard {
                if let ESCBlacklistedStatus = ESCBlacklistedStatus, ESCBlacklistedStatus.contains(statusDetails) {
                    PXConfiguratorManager.escProtocol.deleteESC(config: PXConfiguratorManager.escConfig, token: token, reason: .REJECTED_PAYMENT, detail: statusDetails)
                }
            }
        }
    }
}

extension PXPaymentFlowModel {
    func generateIdempotecyKey() -> String {
        return String(arc4random()) + String(Date().timeIntervalSince1970)
    }
}
