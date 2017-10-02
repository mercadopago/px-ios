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
        MPServicesBuilder.getPreference(self.viewModel.checkoutPreference._id, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: { [weak self] (checkoutPreference : CheckoutPreference) -> Void in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.checkoutPreference = checkoutPreference
            strongSelf.viewModel.paymentData.payer = checkoutPreference.getPayer()
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

            }, failure: { [weak self] (error: NSError) -> Void in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.dismissLoading()
                strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.GET_PREFERENCE.rawValue), errorCallback: { [weak self] (_) -> Void in
                    self?.getCheckoutPreference()
                })
                strongSelf.executeNextStep()
        })
    }

    func getDirectDiscount() {
        self.presentLoading()
        CustomServer.getDirectDiscount(transactionAmount: self.viewModel.getFinalAmount(), payerEmail: self.viewModel.checkoutPreference.payer.email, url: MercadoPagoCheckoutViewModel.servicePreference.getDiscountURL(), uri: MercadoPagoCheckoutViewModel.servicePreference.getDiscountURI(), discountAdditionalInfo: MercadoPagoCheckoutViewModel.servicePreference.discountAdditionalInfo, success: { [weak self] (discount) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.paymentData.discount = discount
            strongSelf.executeNextStep()
            strongSelf.dismissLoading()

        }) { [weak self] (_: NSError) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.dismissLoading()
            strongSelf.executeNextStep()
        }
    }

    func getPaymentMethodSearch() {
        self.presentLoading()
        MPServicesBuilder.searchPaymentMethods(self.viewModel.getFinalAmount(), defaultPaymenMethodId: self.viewModel.getDefaultPaymentMethodId(), excludedPaymentTypeIds: self.viewModel.getExcludedPaymentTypesIds(), excludedPaymentMethodIds: self.viewModel.getExcludedPaymentMethodsIds(),
                                               baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: {  [weak self](paymentMethodSearchResponse: PaymentMethodSearch) -> Void in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchResponse)
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

            }, failure: { [weak self] (error) -> Void in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.dismissLoading()
                strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.PAYMENT_METHOD_SEARCH.rawValue), errorCallback: { [weak self] (_) -> Void in

                    self?.getPaymentMethodSearch()
                })
                strongSelf.executeNextStep()
        })
    }

    func getIssuers() {
        self.presentLoading()
        guard let paymentMethod = self.viewModel.paymentData.getPaymentMethod() else {
            return
        }
        let bin = self.viewModel.cardToken?.getBin()
        MPServicesBuilder.getIssuers(paymentMethod, bin: bin, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: { [weak self] (issuers) -> Void in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.issuers = issuers

            if issuers.count == 1 {
                strongSelf.viewModel.updateCheckoutModel(issuer: issuers[0])
            }
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

        }) { [weak self] (error) -> Void in
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

        MPServicesBuilder.createNewCardToken(self.viewModel.cardToken!, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getGatewayURL(), success: { [weak self] (token : Token?) -> Void in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(token: token!)
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

            }, failure : { [weak self] (error) -> Void in
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
        })
    }

    func createSavedCardToken(cardInformation: CardInformation, securityCode: String) {
        self.presentLoading()

        let cardInformation = self.viewModel.paymentOptionSelected as! CardInformation
        let saveCardToken = SavedCardToken(card: cardInformation, securityCode: securityCode, securityCodeRequired: true)

        MPServicesBuilder.createSavedCardToken(saveCardToken, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getGatewayURL(), success: { [weak self] (token) in
            guard let strongSelf = self else {
                return
            }

            if token.lastFourDigits.isEmpty {
                token.lastFourDigits = cardInformation.getCardLastForDigits()
            }
            strongSelf.viewModel.updateCheckoutModel(token: token)
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

            }, failure: { [weak self] (error) in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.dismissLoading()
                strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue), errorCallback: { [weak self] (_) in
                    self?.createSavedCardToken(cardInformation: cardInformation, securityCode: securityCode)
                })
                strongSelf.executeNextStep()
        })
    }

    func createSavedESCCardToken(savedESCCardToken: SavedESCCardToken) {
        self.presentLoading()
        MPServicesBuilder.createSavedESCCardToken(savedESCCardToken: savedESCCardToken, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getGatewayURL(), success: { [weak self] (token) in
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

            }, failure: { [weak self] (error) in
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
        })
    }

    func cloneCardToken(token: Token, securityCode: String) {
        self.presentLoading()
        MPServicesBuilder.cloneToken(token, securityCode:securityCode, success: { [weak self] (token) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(token: token)
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()

            }, failure: { [weak self] (error) in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.dismissLoading()
                strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin:  ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue), errorCallback: { [weak self] (_) in
                    self?.cloneCardToken(token: token, securityCode: securityCode)
                })
                strongSelf.executeNextStep()
        })
    }

    func getPayerCosts(updateCallback: (() -> Void)? = nil) {
        self.presentLoading()

        guard let paymentMethod = self.viewModel.paymentData.getPaymentMethod() else {
            return
        }

        let bin = self.viewModel.cardToken?.getBin()

        MPServicesBuilder.getInstallments(bin, amount: self.viewModel.getFinalAmount(), issuer: self.viewModel.paymentData.getIssuer(), paymentMethodId: paymentMethod._id, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: { [weak self] (installments) -> Void in
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

        }) { [weak self] (error) -> Void in
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

        var paymentBody: [String:Any]
        if MercadoPagoCheckoutViewModel.servicePreference.isUsingDeafaultPaymentSettings() {
            let mpPayment = MercadoPagoCheckoutViewModel.createMPPayment(preferenceId: self.viewModel.checkoutPreference._id, paymentData: self.viewModel.paymentData, binaryMode: self.viewModel.binaryMode)
            paymentBody = mpPayment.toJSON()
        } else {
            paymentBody = self.viewModel.paymentData.toJSON()
        }

        let createPaymentQuery = MercadoPagoCheckoutViewModel.servicePreference.getPaymentAddionalInfo()

        CustomServer.createPayment(url: MercadoPagoCheckoutViewModel.servicePreference.getPaymentURL(), uri: MercadoPagoCheckoutViewModel.servicePreference.getPaymentURI(), paymentData: paymentBody as NSDictionary, query: createPaymentQuery, success: { [weak self] (payment : Payment) -> Void in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(payment: payment)
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()
            }, failure: {[weak self] (error: NSError) -> Void in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.dismissLoading()
                let mpError = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_PAYMENT.rawValue)

                if let apiException = mpError.apiException, apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_PAYMENT_WITH_ESC.rawValue) {
                    strongSelf.viewModel.prepareForInvalidPaymentWithESC()
                } else {
                    strongSelf.viewModel.errorInputs(error: mpError, errorCallback: { [weak self] (_) in
                        self?.createPayment()
                    })
                }
                strongSelf.executeNextStep()
        })
    }
    
    func getInstructions() {
        self.presentLoading()
        
        guard let paymentResult = self.viewModel.paymentResult else {
            return
        }
        
        guard let paymentId = paymentResult._id else {
            return
        }
        
        guard let paymentTypeId = paymentResult.paymentData?.getPaymentMethod()?.paymentTypeId else {
            return
        }
        
        MPServicesBuilder.getInstructions(for: paymentId, paymentTypeId: paymentTypeId, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: { [weak self] (instructionsInfo) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.viewModel.instructionsInfo = instructionsInfo
            strongSelf.dismissLoading()
            strongSelf.executeNextStep()
            
        }) { [weak self] (error) -> Void in
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
}
