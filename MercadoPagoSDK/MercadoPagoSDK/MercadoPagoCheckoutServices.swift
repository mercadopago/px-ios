//
//  MercadoPagoCheckoutServices.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/18/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

extension MercadoPagoCheckout {

    func getCheckoutPreference() {
        self.presentLoading()
        self.viewModel.mercadoPagoServicesAdapter.getCheckoutPreference(checkoutPreferenceId: self.viewModel.checkoutPreference._id, callback: { [weak self] (checkoutPreference) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.checkoutPreference = checkoutPreference
            strongSelf.viewModel.paymentData.payer = checkoutPreference.getPayer()
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }) { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.dismissLoading()
            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.GET_PREFERENCE.rawValue), errorCallback: { [weak self] (_) -> Void in
                self?.getCheckoutPreference()
            })
            strongSelf.executeNextStep()

        }
    }

    func getDirectDiscount() {
        self.presentLoading()
        self.viewModel.mercadoPagoServicesAdapter.getDirectDiscount(amount: self.viewModel.getAmount(), payerEmail: self.viewModel.checkoutPreference.payer.email, callback: { [weak self] (discount) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.paymentData.discount = discount
            strongSelf.executeNextStep()
            strongSelf.dismissLoading()

        }) { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }
    }

    func getPaymentMethodSearch() {
        self.presentLoading()

        self.viewModel.mercadoPagoServicesAdapter.getPaymentMethodSearch(amount: self.viewModel.getAmount(), excludedPaymentTypesIds: self.viewModel.getExcludedPaymentTypesIds(), excludedPaymentMethodsIds: self.viewModel.getExcludedPaymentMethodsIds(), defaultPaymentMethod: self.viewModel.getDefaultPaymentMethodId(), payer: Payer(), site: MercadoPagoContext.getSite(), callback: { [weak self] (paymentMethodSearch) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearch)
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }) { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.dismissLoading()
            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.PAYMENT_METHOD_SEARCH.rawValue), errorCallback: { [weak self] (_) -> Void in

                self?.getPaymentMethodSearch()
            })
            strongSelf.executeNextStep()

        }
    }

    func getIssuers() {
        self.presentLoading()
        guard let paymentMethod = self.viewModel.paymentData.getPaymentMethod() else {
            return
        }
        let bin = self.viewModel.cardToken?.getBin()
        self.viewModel.mercadoPagoServicesAdapter.getIssuers(paymentMethodId: paymentMethod._id, bin: bin, callback: { [weak self] (issuers) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.issuers = issuers

            if issuers.count == 1 {
                strongSelf.viewModel.updateCheckoutModel(issuer: issuers[0])
            }
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }) { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.dismissLoading()
            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.GET_ISSUERS.rawValue), errorCallback: { [weak self] (_) in
                self?.getIssuers()
            })
            strongSelf.executeNextStep()

        }
    }

    func createCardToken(cardInformation: CardInformation? = nil, securityCode: String? = nil) {
        guard let cardInfo = self.viewModel.paymentOptionSelected as? CardInformation else {
            createNewCardToken()
            return
        }
        if cardInfo.canBeClone() {
            guard let token = cardInfo as? Token else {
                return // TODO Refactor : Tenemos unos lios barbaros con CardInformation y CardInformationForm, no entiendo porque hay uno y otr
            }
            cloneCardToken(token: token, securityCode: securityCode!)

        } else if self.viewModel.mpESCManager.hasESCEnable() {
            var savedESCCardToken: SavedESCCardToken

            let esc = self.viewModel.mpESCManager.getESC(cardId: cardInfo.getCardId())

            if !String.isNullOrEmpty(esc) {
                savedESCCardToken = SavedESCCardToken(cardId: cardInfo.getCardId(), esc: esc)
            } else {
                savedESCCardToken = SavedESCCardToken(cardId: cardInfo.getCardId(), securityCode: securityCode)
            }
            createSavedESCCardToken(savedESCCardToken: savedESCCardToken)

        } else {
            createSavedCardToken(cardInformation: cardInfo, securityCode: securityCode!)
        }
    }

    func createNewCardToken() {
        self.presentLoading()

        self.viewModel.mercadoPagoServicesAdapter.createToken(cardToken: self.viewModel.cardToken!, callback: { [weak self] (token) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(token: token)
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }) { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }
            let error = MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)

            if error.apiException?.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_IDENTIFICATION_NUMBER.rawValue) == true {
                if let identificationViewController = strongSelf.navigationController.viewControllers.last as? IdentificationViewController {
                    identificationViewController.showErrorMessage("Revisa este dato".localized)
                }
                strongSelf.dismissLoading()
            } else {
                strongSelf.viewModel.errorInputs(error: error, errorCallback: { [weak self] (_) in
                    self?.createNewCardToken()
                })
                strongSelf.dismissLoading()
                strongSelf.executeNextStep()
            }

        }
    }

    func createSavedCardToken(cardInformation: CardInformation, securityCode: String) {
        self.presentLoading()

        let cardInformation = self.viewModel.paymentOptionSelected as! CardInformation
        let saveCardToken = SavedCardToken(card: cardInformation, securityCode: securityCode, securityCodeRequired: true)

        self.viewModel.mercadoPagoServicesAdapter.createToken(savedCardToken: saveCardToken, callback: { [weak self] (token) in

            guard let strongSelf = self else {
                return
            }

            if token.lastFourDigits.isEmpty {
                token.lastFourDigits = cardInformation.getCardLastForDigits()
            }
            strongSelf.viewModel.updateCheckoutModel(token: token)
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }) { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.dismissLoading()
            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue), errorCallback: { [weak self] (_) in
                self?.createSavedCardToken(cardInformation: cardInformation, securityCode: securityCode)
            })
            strongSelf.executeNextStep()

        }
    }

    func createSavedESCCardToken(savedESCCardToken: SavedESCCardToken) {
        self.presentLoading()
        self.viewModel.mercadoPagoServicesAdapter.createToken(savedESCCardToken: savedESCCardToken, callback: { [weak self] (token) in

            guard let strongSelf = self else {
                return
            }

            if token.lastFourDigits.isEmpty {
                let cardInformation = strongSelf.viewModel.paymentOptionSelected as? CardInformation
                token.lastFourDigits = cardInformation?.getCardLastForDigits() ?? ""
            }
            strongSelf.viewModel.updateCheckoutModel(token: token)
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }) { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }
            let mpError = MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)

            if let apiException = mpError.apiException, apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_ESC.rawValue) ||  apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_FINGERPRINT.rawValue) {

                strongSelf.viewModel.mpESCManager.deleteESC(cardId: savedESCCardToken.cardId)

            } else {
                strongSelf.viewModel.errorInputs(error: mpError, errorCallback: { [weak self] (_) in
                    self?.createSavedESCCardToken(savedESCCardToken: savedESCCardToken)
                })

            }
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }
    }

    func cloneCardToken(token: Token, securityCode: String) {
        self.presentLoading()
        self.viewModel.mercadoPagoServicesAdapter.cloneToken(tokenId: token._id, securityCode: securityCode, callback: { [weak self] (token) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(token: token)
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }) { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.dismissLoading()
            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue), errorCallback: { [weak self] (_) in
                self?.cloneCardToken(token: token, securityCode: securityCode)
            })
            strongSelf.executeNextStep()

        }
    }

    func getPayerCosts(updateCallback: (() -> Void)? = nil) {
        self.presentLoading()

        guard let paymentMethod = self.viewModel.paymentData.getPaymentMethod() else {
            return
        }

        let bin = self.viewModel.cardToken?.getBin()

        self.viewModel.mercadoPagoServicesAdapter.getInstallments(bin: bin, amount: self.viewModel.getAmount(), issuer: self.viewModel.paymentData.getIssuer(), paymentMethodId: paymentMethod._id, callback: { [weak self] (installments) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.payerCosts = installments[0].payerCosts

            let defaultPayerCost = strongSelf.viewModel.checkoutPreference.paymentPreference?.autoSelectPayerCost(installments[0].payerCosts)
            if let defaultPC = defaultPayerCost {
                strongSelf.viewModel.updateCheckoutModel(payerCost: defaultPC)
            }

            if let updateCallback = updateCallback {
                updateCallback()
                strongSelf.dismissLoading()
            } else {
                strongSelf.dismissLoading()
                strongSelf.executeNextStep()
            }

        }) { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.dismissLoading()
            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.GET_INSTALLMENTS.rawValue), errorCallback: { [weak self] (_) in
                self?.getPayerCosts()
            })
            strongSelf.executeNextStep()

        }
    }

    func createPayment() {
        self.presentLoading()

        var paymentBody: [String: Any]
        if MercadoPagoCheckoutViewModel.servicePreference.isUsingDeafaultPaymentSettings() {
            let mpPayment = MercadoPagoCheckoutViewModel.createMPPayment(preferenceId: self.viewModel.checkoutPreference._id, paymentData: self.viewModel.paymentData, binaryMode: self.viewModel.binaryMode)
            paymentBody = mpPayment.toJSON()
        } else {
            paymentBody = self.viewModel.paymentData.toJSON()
        }

        var createPaymentQuery: [String: String]? = [:]
        if let paymentAdditionalInfo = MercadoPagoCheckoutViewModel.servicePreference.getPaymentAddionalInfo() as? [String: String] {
            createPaymentQuery = paymentAdditionalInfo
        } else {
            createPaymentQuery = nil
        }

        self.viewModel.mercadoPagoServicesAdapter.createPayment(url: MercadoPagoCheckoutViewModel.servicePreference.getPaymentURL(), uri: MercadoPagoCheckoutViewModel.servicePreference.getPaymentURI(), paymentData: paymentBody as NSDictionary, query: createPaymentQuery, callback: { [weak self] (payment) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(payment: payment)
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }) { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.dismissLoading()
            let mpError = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_PAYMENT.rawValue)

            if let apiException = mpError.apiException, apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_PAYMENT_WITH_ESC.rawValue) {
                strongSelf.viewModel.prepareForInvalidPaymentWithESC()
            } else if let apiException = mpError.apiException, apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_PAYMENT_IDENTIFICATION_NUMBER.rawValue) {
                self?.viewModel.paymentData.clearCollectedData()
                let mpInvalidIdentificationError = MPSDKError.init(message: "Algo salió mal...".localized, errorDetail: "El número de identificación es inválido".localized, retry: true)
                strongSelf.viewModel.errorInputs(error: mpInvalidIdentificationError, errorCallback: { [weak self] (_) in
                    self?.viewModel.prepareForNewSelection()
                    self?.executeNextStep()
                })
            } else {
                strongSelf.viewModel.errorInputs(error: mpError, errorCallback: { [weak self] (_) in
                    self?.createPayment()
                })
            }
            strongSelf.executeNextStep()

        }
    }

    func getInstructions() {
        self.presentLoading()

        guard let paymentResult = self.viewModel.paymentResult else {
            fatalError("Get Instructions - Payment Result does no exist")
        }

        guard let paymentId = paymentResult._id else {
           fatalError("Get Instructions - Payment Id does no exist")
        }

        guard let paymentTypeId = paymentResult.paymentData?.getPaymentMethod()?.paymentTypeId else {
            fatalError("Get Instructions - Payment Method Type Id does no exist")
        }

        self.viewModel.mercadoPagoServicesAdapter.getInstructions(paymentId: paymentId, paymentTypeId: paymentTypeId, callback: { [weak self] (instructionsInfo) in

            guard let strongSelf = self else {
                return
            }
            strongSelf.viewModel.instructionsInfo = instructionsInfo
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }) { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }
            strongSelf.dismissLoading()
            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.GET_INSTRUCTIONS.rawValue), errorCallback: { [weak self] (_) in
                self?.getInstructions()
            })
            strongSelf.executeNextStep()

        }
    }

    func getIdentificationTypes() {
        self.presentLoading()
        self.viewModel.mercadoPagoServicesAdapter.getIdentificationTypes(callback: { [weak self] (identificationTypes) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(identificationTypes: identificationTypes)
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }) { [weak self] (error) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.dismissLoading()
            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.GET_IDENTIFICATION_TYPES.rawValue), errorCallback: { [weak self] (_) in
                self?.getIdentificationTypes()
            })
            strongSelf.executeNextStep()

        }
    }
}
