//
//  MercadoPagoCheckoutServices.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/18/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

extension MercadoPagoCheckout {

    func getIssuers() {
        viewModel.pxNavigationHandler.presentLoading()
        guard let paymentMethod = self.viewModel.paymentData.getPaymentMethod() else {
            return
        }
        let bin = self.viewModel.cardToken?.getBin()
        self.viewModel.mercadoPagoServicesAdapter.getIssuers(paymentMethodId: paymentMethod.id, bin: bin, callback: { [weak self] (issuers) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.issuers = issuers

            if issuers.count == 1 {
                strongSelf.viewModel.updateCheckoutModel(issuer: issuers[0])
            }
            strongSelf.executeNextStep()

        }, failure: { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_ISSUERS.rawValue), errorCallback: { [weak self] () in
                self?.getIssuers()
            })
            strongSelf.executeNextStep()
        })
    }

    func createCardToken(cardInformation: PXCardInformation? = nil, securityCode: String? = nil) {
        guard let cardInfo = self.viewModel.paymentOptionSelected as? PXCardInformation else {
            createNewCardToken()
            return
        }
        if cardInfo.canBeClone() {
            guard let token = cardInfo as? PXToken else {
                return // TODO Refactor : Tenemos unos lios barbaros con CardInformation y CardInformationForm, no entiendo porque hay uno y otr
            }
            cloneCardToken(token: token, securityCode: securityCode!)

        } else if self.viewModel.mpESCManager.hasESCEnable() {
            var savedESCCardToken: PXSavedESCCardToken

            let esc = self.viewModel.mpESCManager.getESC(cardId: cardInfo.getCardId())

            if !String.isNullOrEmpty(esc) {
                savedESCCardToken = PXSavedESCCardToken(cardId: cardInfo.getCardId(), esc: esc, requireESC: viewModel.getAdvancedConfiguration().escEnabled)
            } else {
                savedESCCardToken = PXSavedESCCardToken(cardId: cardInfo.getCardId(), securityCode: securityCode, requireESC: viewModel.getAdvancedConfiguration().escEnabled)
            }

            createSavedESCCardToken(savedESCCardToken: savedESCCardToken)
        } else {
            guard let securityCode = securityCode else {
                return
            }
            createSavedCardToken(cardInformation: cardInfo, securityCode: securityCode)
        }
    }

    func createNewCardToken() {
        viewModel.pxNavigationHandler.presentLoading()

        self.viewModel.mercadoPagoServicesAdapter.createToken(cardToken: self.viewModel.cardToken!, callback: { [weak self] (token) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(token: token)
            strongSelf.executeNextStep()

        }, failure: { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }
            let error = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)

            if error.apiException?.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_IDENTIFICATION_NUMBER.rawValue) == true {
                if let identificationViewController = strongSelf.viewModel.pxNavigationHandler.navigationController.viewControllers.last as? IdentificationViewController {
                    identificationViewController.showErrorMessage("Revisa este dato".localized)
                }
            } else {
                strongSelf.viewModel.pxNavigationHandler.dismissLoading()
                strongSelf.viewModel.errorInputs(error: error, errorCallback: { [weak self] () in
                    self?.createNewCardToken()
                })
                strongSelf.executeNextStep()
            }
        })
    }

    func createSavedCardToken(cardInformation: PXCardInformation, securityCode: String) {
        viewModel.pxNavigationHandler.presentLoading()

        let cardInformation = self.viewModel.paymentOptionSelected as! PXCardInformation
        let saveCardToken = PXSavedCardToken(card: cardInformation, securityCode: securityCode, securityCodeRequired: true)

        self.viewModel.mercadoPagoServicesAdapter.createToken(savedCardToken: saveCardToken, callback: { [weak self] (token) in

            guard let strongSelf = self else {
                return
            }

            if token.lastFourDigits.isEmpty {
                token.lastFourDigits = cardInformation.getCardLastForDigits() ?? ""
            }
            strongSelf.viewModel.updateCheckoutModel(token: token)
            strongSelf.executeNextStep()

        }, failure: { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue), errorCallback: { [weak self] () in
                self?.createSavedCardToken(cardInformation: cardInformation, securityCode: securityCode)
            })
            strongSelf.executeNextStep()

        })
    }

    func createSavedESCCardToken(savedESCCardToken: PXSavedESCCardToken) {
        viewModel.pxNavigationHandler.presentLoading()
        self.viewModel.mercadoPagoServicesAdapter.createToken(savedESCCardToken: savedESCCardToken, callback: { [weak self] (token) in

            guard let strongSelf = self else {
                return
            }

            if token.lastFourDigits.isEmpty {
                let cardInformation = strongSelf.viewModel.paymentOptionSelected as? PXCardInformation
                token.lastFourDigits = cardInformation?.getCardLastForDigits() ?? ""
            }
            strongSelf.viewModel.updateCheckoutModel(token: token)
            strongSelf.executeNextStep()

        }, failure: { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }
            let mpError = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)

            if let apiException = mpError.apiException, apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_ESC.rawValue) ||  apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_FINGERPRINT.rawValue) {
                    strongSelf.viewModel.mpESCManager.deleteESC(cardId: savedESCCardToken.cardId)
            } else {
                strongSelf.viewModel.errorInputs(error: mpError, errorCallback: { [weak self] () in
                    self?.createSavedESCCardToken(savedESCCardToken: savedESCCardToken)
                })

            }
            strongSelf.executeNextStep()

        })
    }

    func cloneCardToken(token: PXToken, securityCode: String) {
        viewModel.pxNavigationHandler.presentLoading()
        self.viewModel.mercadoPagoServicesAdapter.cloneToken(tokenId: token.id, securityCode: securityCode, callback: { [weak self] (token) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(token: token)
            strongSelf.executeNextStep()

        }, failure: { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue), errorCallback: { [weak self] () in
                self?.cloneCardToken(token: token, securityCode: securityCode)
            })
            strongSelf.executeNextStep()

        })
    }

    func getPayerCosts(updateCallback: (() -> Void)? = nil) {
        viewModel.pxNavigationHandler.presentLoading()

        guard let paymentMethod = self.viewModel.paymentData.getPaymentMethod() else {
            return
        }

        let bin = self.viewModel.cardToken?.getBin()

        var diffPricingString: String? = nil
        if let differentialPricing = self.viewModel.checkoutPreference.differentialPricing?.id {
            diffPricingString = String(describing: differentialPricing)
        }
        self.viewModel.mercadoPagoServicesAdapter.getInstallments(bin: bin, amount: self.viewModel.amountHelper.amountToPay, issuer: self.viewModel.paymentData.getIssuer(), paymentMethodId: paymentMethod.id, differentialPricingId: diffPricingString, callback: { [weak self] (installments) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.payerCosts = installments[0].payerCosts

            let defaultPayerCost = strongSelf.viewModel.checkoutPreference.paymentPreference.autoSelectPayerCost(installments[0].payerCosts)
            if let defaultPC = defaultPayerCost {
                strongSelf.viewModel.updateCheckoutModel(payerCost: defaultPC)
            }

            if let updateCallback = updateCallback {
                updateCallback()
            } else {
                strongSelf.executeNextStep()
            }

        }, failure: {[weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_INSTALLMENTS.rawValue), errorCallback: { [weak self] () in
                self?.getPayerCosts()
            })
            strongSelf.executeNextStep()

        })
    }

    func createPayment() {
        let paymentFlow = viewModel.createPaymentFlow(paymentErrorHandler: self)
        paymentFlow.setData(paymentData: viewModel.paymentData, checkoutPreference: viewModel.checkoutPreference, resultHandler: self)
        paymentFlow.start()
    }

    func getIdentificationTypes() {
        viewModel.pxNavigationHandler.presentLoading()
        self.viewModel.mercadoPagoServicesAdapter.getIdentificationTypes(callback: { [weak self] (identificationTypes) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(identificationTypes: identificationTypes)
            strongSelf.executeNextStep()

        }, failure: { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_IDENTIFICATION_TYPES.rawValue), errorCallback: { [weak self] () in
                self?.getIdentificationTypes()
            })
            strongSelf.executeNextStep()

        })
    }
}
