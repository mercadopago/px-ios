//
//  OneTapFlow+Services.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 09/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
extension OneTapFlow {
    func createCardToken(cardInformation: CardInformation? = nil, securityCode: String? = nil) {
        guard let cardInfo = model.paymentOptionSelected as? CardInformation else {
            return
        }
        if self.model.mpESCManager.hasESCEnable() {
            var savedESCCardToken: SavedESCCardToken

            let esc = self.model.mpESCManager.getESC(cardId: cardInfo.getCardId())

            if !String.isNullOrEmpty(esc) {
                savedESCCardToken = SavedESCCardToken(cardId: cardInfo.getCardId(), esc: esc, requireESC: advancedConfig.escEnabled)
            } else {
                savedESCCardToken = SavedESCCardToken(cardId: cardInfo.getCardId(), securityCode: securityCode, requireESC: advancedConfig.escEnabled)
            }
            createSavedESCCardToken(savedESCCardToken: savedESCCardToken)

        } else {
            guard let securityCode = securityCode else {
                return
            }
            createSavedCardToken(cardInformation: cardInfo, securityCode: securityCode)
        }
    }

    func createSavedCardToken(cardInformation: CardInformation, securityCode: String) {
        if model.needToShowLoading() {
            self.pxNavigationHandler.presentLoading()
        }

        let cardInformation = model.paymentOptionSelected as! CardInformation
        let saveCardToken = SavedCardToken(card: cardInformation, securityCode: securityCode, securityCodeRequired: true)

        self.model.mercadoPagoServicesAdapter.createToken(savedCardToken: saveCardToken, callback: { [weak self] (token) in

            if token.lastFourDigits.isEmpty {
                token.lastFourDigits = cardInformation.getCardLastForDigits()
            }
            self?.model.updateCheckoutModel(token: token)
            self?.executeNextStep()

            }, failure: { [weak self] (error) in
                guard let strongSelf = self else {
                    return
                }
                let error = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)

                if strongSelf.model.needToShowLoading() {
                    strongSelf.pxNavigationHandler.showErrorScreen(error: error, callbackCancel: strongSelf.resultHandler?.exitCheckout, errorCallback: { [weak self] () in
                        self?.createSavedCardToken(cardInformation: cardInformation, securityCode: securityCode)
                    })
                } else {
                    strongSelf.finishPaymentFlow(error: error)
                }
        })
    }

    func createSavedESCCardToken(savedESCCardToken: SavedESCCardToken) {
        if model.needToShowLoading() {
            self.pxNavigationHandler.presentLoading()
        }

        self.model.mercadoPagoServicesAdapter.createToken(savedESCCardToken: savedESCCardToken, callback: { [weak self] (token) in

            if token.lastFourDigits.isEmpty {
                let cardInformation = self?.model.paymentOptionSelected as? CardInformation
                token.lastFourDigits = cardInformation?.getCardLastForDigits() ?? ""
            }
            self?.model.updateCheckoutModel(token: token)
            self?.executeNextStep()

            }, failure: { [weak self] (error) in
                guard let strongSelf = self else {
                    return
                }
                let error = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)

                if let apiException = error.apiException, apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_ESC.rawValue) ||  apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_FINGERPRINT.rawValue) {

                    strongSelf.model.mpESCManager.deleteESC(cardId: savedESCCardToken.cardId)
                    strongSelf.executeNextStep()
                } else {
                    if strongSelf.model.needToShowLoading() {
                        strongSelf.pxNavigationHandler.showErrorScreen(error: error, callbackCancel: strongSelf.resultHandler?.exitCheckout, errorCallback: { [weak self] () in
                            self?.createSavedESCCardToken(savedESCCardToken: savedESCCardToken)
                        })
                    } else {
                        strongSelf.finishPaymentFlow(error: error)
                    }
                }
        })
    }
}
