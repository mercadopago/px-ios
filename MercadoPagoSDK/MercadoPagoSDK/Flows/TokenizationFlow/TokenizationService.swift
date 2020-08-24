//
//  TokenizationService.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 12/04/2019.
//

import Foundation

internal class TokenizationService {
    var paymentOptionSelected: PaymentMethodOption?
    var cardToken: PXCardToken?
    var pxNavigationHandler: PXNavigationHandler
    var needToShowLoading: Bool
    var mercadoPagoServices: MercadoPagoServices
    weak var resultHandler: TokenizationServiceResultHandler?

    init(paymentOptionSelected: PaymentMethodOption?, cardToken: PXCardToken?, pxNavigationHandler: PXNavigationHandler, needToShowLoading: Bool, mercadoPagoServices: MercadoPagoServices, gatewayFlowResultHandler: TokenizationServiceResultHandler) {
        self.paymentOptionSelected = paymentOptionSelected
        self.pxNavigationHandler = pxNavigationHandler
        self.needToShowLoading = needToShowLoading
        self.mercadoPagoServices = mercadoPagoServices
        self.resultHandler = gatewayFlowResultHandler
        self.cardToken = cardToken
    }

    func createCardToken(securityCode: String? = nil, token: PXToken? = nil) {

        // Clone token
        if let token = token, token.canBeClone() {
            guard let securityCode = securityCode else {
                return
            }
            cloneCardToken(token: token, securityCode: securityCode)
            return
        }

        // New Card Token
        guard let cardInfo = paymentOptionSelected as? PXCardInformation else {
            createNewCardToken()
            return
        }

        // Saved card with esc token
        let requireESC = PXConfiguratorManager.escProtocol.hasESCEnable()
        if requireESC {
            var savedESCCardToken: PXSavedESCCardToken

            let esc = PXConfiguratorManager.escProtocol.getESC(config: PXConfiguratorManager.escConfig, cardId: cardInfo.getCardId(), firstSixDigits: cardInfo.getFirstSixDigits(), lastFourDigits: cardInfo.getCardLastForDigits())

            if !String.isNullOrEmpty(esc) {
                savedESCCardToken = PXSavedESCCardToken(cardId: cardInfo.getCardId(), esc: esc, requireESC: requireESC)
            } else {
                savedESCCardToken = PXSavedESCCardToken(cardId: cardInfo.getCardId(), securityCode: securityCode, requireESC: requireESC)
            }
            createSavedESCCardToken(savedESCCardToken: savedESCCardToken)

        // Saved card token
        } else {
            guard let securityCode = securityCode else {
                return
            }
            createSavedCardToken(cardInformation: cardInfo, securityCode: securityCode)
        }
    }

    private func createNewCardToken() {
        guard let cardToken = cardToken else {
            return
        }
        pxNavigationHandler.presentLoading()

        mercadoPagoServices.createToken(cardToken: cardToken, callback: { (token) in
            self.resultHandler?.finishFlow(token: token, shouldResetESC: false)

        }, failure: { (error) in
            let error = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)

            if error.apiException?.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_IDENTIFICATION_NUMBER.rawValue) == true {
                self.resultHandler?.finishInvalidIdentificationNumber()
            } else {
                self.resultHandler?.finishWithError(error: error, securityCode: nil)
            }
        })
    }

    private func createSavedCardToken(cardInformation: PXCardInformation, securityCode: String) {
        guard let cardInformation = paymentOptionSelected as? PXCardInformation else {
            return
        }

        if needToShowLoading {
            self.pxNavigationHandler.presentLoading()
        }

        let saveCardToken = PXSavedCardToken(card: cardInformation, securityCode: securityCode, securityCodeRequired: true)

        mercadoPagoServices.createToken(savedCardToken: saveCardToken, callback: { (token) in

            if token.lastFourDigits.isEmpty {
                token.lastFourDigits = cardInformation.getCardLastForDigits()
            }
            self.resultHandler?.finishFlow(token: token, shouldResetESC: true)
        }, failure: { (error) in
            let error = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)

            self.resultHandler?.finishWithError(error: error, securityCode: securityCode)
        })
    }

    private func createSavedESCCardToken(savedESCCardToken: PXSavedESCCardToken) {
        if needToShowLoading {
            self.pxNavigationHandler.presentLoading()
        }

        mercadoPagoServices.createToken(savedESCCardToken: savedESCCardToken, callback: { (token) in

            if token.lastFourDigits.isEmpty {
                let cardInformation = self.paymentOptionSelected as? PXCardInformation
                token.lastFourDigits = cardInformation?.getCardLastForDigits() ?? ""
            }

            var shouldResetESC = false
            if let securityCode = savedESCCardToken.securityCode, securityCode.isNotEmpty {
                shouldResetESC = true
            }
            self.resultHandler?.finishFlow(token: token, shouldResetESC: shouldResetESC)
        }, failure: { (error) in
            let error = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)
            self.trackInvalidESC(error: error, cardId: savedESCCardToken.cardId, esc_length: savedESCCardToken.esc?.count)
            PXConfiguratorManager.escProtocol.deleteESC(config: PXConfiguratorManager.escConfig, cardId: savedESCCardToken.cardId, reason: .UNEXPECTED_TOKENIZATION_ERROR, detail: error.toJSONString())
            self.resultHandler?.finishWithESCError()
        })
    }

    private func cloneCardToken(token: PXToken, securityCode: String) {
        pxNavigationHandler.presentLoading()
        mercadoPagoServices.cloneToken(tokenId: token.id, securityCode: securityCode, callback: { (token) in
            self.resultHandler?.finishFlow(token: token, shouldResetESC: true)
        }, failure: { (error) in
            let error = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)
            self.resultHandler?.finishWithError(error: error, securityCode: securityCode)
        })
    }

    func resetESCCap(cardId: String, onCompletion: @escaping () -> Void) {
        mercadoPagoServices.resetESCCap(cardId: cardId, onCompletion: onCompletion)
    }
}
