//
//  MercadoPagoCheckoutScreens.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/18/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

extension MercadoPagoCheckout {

    func showPaymentMethodsScreen() {
        viewModel.clearCollectedData()
        let paymentMethodSelectionStep = PaymentVaultViewController(viewModel: self.viewModel.paymentVaultViewModel(), callback: { [weak self] (paymentOptionSelected: PaymentMethodOption) -> Void  in

            guard let strongSelf = self else {
                return
            }

            // Clean account money paymentData on PaymentVault selection.
            // Because this flow doesn´t support split payments.
            strongSelf.viewModel.splitAccountMoney = nil

            strongSelf.viewModel.updateCheckoutModel(paymentOptionSelected: paymentOptionSelected)

            if let payerCosts = strongSelf.viewModel.paymentConfigurationService.getPayerCostsForPaymentMethod(paymentOptionSelected.getId()) {
                strongSelf.viewModel.payerCosts = payerCosts
                let defaultPayerCost = strongSelf.viewModel.checkoutPreference.paymentPreference.autoSelectPayerCost(payerCosts)
                if let defaultPC = defaultPayerCost {
                    strongSelf.viewModel.updateCheckoutModel(payerCost: defaultPC)
                }
            } else {
                strongSelf.viewModel.payerCosts = nil
            }
            if let discountConfiguration = strongSelf.viewModel.paymentConfigurationService.getDiscountConfigurationForPaymentMethod(paymentOptionSelected.getId()) {
                strongSelf.viewModel.attemptToApplyDiscount(discountConfiguration)
            } else {
                strongSelf.viewModel.applyDefaultDiscountOrClear()
            }

            strongSelf.viewModel.rootVC = false
            strongSelf.executeNextStep()
        })

        viewModel.pxNavigationHandler.pushViewController(viewController: paymentMethodSelectionStep, animated: true)
    }

    func showCardForm() {
        let cardFormStep = CardFormViewController(cardFormManager: self.viewModel.cardFormManager(), callback: { [weak self](paymentMethods, cardToken) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(paymentMethods: paymentMethods, cardToken: cardToken)
            strongSelf.executeNextStep()
        })
        viewModel.pxNavigationHandler.pushViewController(viewController: cardFormStep, animated: true)
    }

    func showIdentificationScreen() {
        guard let identificationTypes = self.viewModel.cardFlowSupportedIdentificationTypes() else {
            let error = MPSDKError(message: "Hubo un error".localized, errorDetail: "", retry: false)
            MercadoPagoCheckoutViewModel.error = error
            showErrorScreen()
            return
        }

        let identificationStep = IdentificationViewController(identificationTypes: identificationTypes, paymentMethod: viewModel.paymentData.paymentMethod, callback: { [weak self] (identification : PXIdentification) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(identification: identification)
            strongSelf.executeNextStep()
            }, errorExitCallback: { [weak self] in
                self?.finish()
        })

        identificationStep.callbackCancel = {[weak self] in
            self?.viewModel.pxNavigationHandler.navigationController.popViewController(animated: true)
        }
        viewModel.pxNavigationHandler.pushViewController(viewController: identificationStep, animated: true)
    }

    func showPayerInfoFlow() {
        let viewModel = self.viewModel.payerInfoFlow()
        let vc = PayerInfoViewController(viewModel: viewModel) { [weak self] (payer) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(payer: payer)
            strongSelf.executeNextStep()
        }
        self.viewModel.pxNavigationHandler.pushViewController(viewController: vc, animated: true)
    }

    func showIssuersScreen() {
        let issuerStep = AdditionalStepViewController(viewModel: self.viewModel.issuerViewModel(), callback: { [weak self](issuer) in

            guard let issuer = issuer as? PXIssuer else {
                fatalError("Cannot convert issuer to type Issuer")
            }
            self?.viewModel.updateCheckoutModel(issuer: issuer)
            self?.executeNextStep()

        })
        viewModel.pxNavigationHandler.pushViewController(viewController: issuerStep, animated: true)
    }

    func showPayerCostScreen() {
        let payerCostViewModel = self.viewModel.payerCostViewModel()

        let payerCostStep = AdditionalStepViewController(viewModel: payerCostViewModel, callback: { [weak self] (payerCost) in
            guard let payerCost = payerCost as? PXPayerCost else {
                fatalError("Cannot convert payerCost to type PayerCost")
            }

            self?.viewModel.updateCheckoutModel(payerCost: payerCost)
            self?.executeNextStep()
        })

        viewModel.pxNavigationHandler.pushViewController(viewController: payerCostStep, animated: true)
    }

    func showReviewAndConfirmScreen() {
        let paymentFlow = viewModel.createPaymentFlow(paymentErrorHandler: self)
        let timeOut = paymentFlow.getPaymentTimeOut()
        let shouldShowAnimatedPayButton = !paymentFlow.needToShowPaymentPluginScreen()

        let reviewVC = PXReviewViewController(viewModel: self.viewModel.reviewConfirmViewModel(), timeOutPayButton: timeOut, shouldAnimatePayButton: shouldShowAnimatedPayButton, callbackPaymentData: { [weak self] (paymentData: PXPaymentData) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(paymentData: paymentData)

            strongSelf.executeNextStep()

        }, callbackConfirm: { [weak self] (paymentData: PXPaymentData) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(paymentData: paymentData)
            strongSelf.executeNextStep()

        }, finishButtonAnimation: {
            self.executeNextStep()
        }, changePayerInformation: { [weak self] (paymentData: PXPaymentData) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(paymentData: paymentData)
            strongSelf.executeNextStep()
        })

        if let changePaymentMethodAction = viewModel.lifecycleProtocol?.changePaymentMethodTapped?() {
            reviewVC.changePaymentMethodCallback = changePaymentMethodAction
        } else {
            reviewVC.changePaymentMethodCallback = nil
        }

        viewModel.pxNavigationHandler.pushViewController(viewController: reviewVC, animated: true)
    }

    func showSecurityCodeScreen() {

        let securityCodeVc = SecurityCodeViewController(viewModel: self.viewModel.savedCardSecurityCodeViewModel(), collectSecurityCodeCallback: { [weak self] (_, securityCode: String) -> Void in
            self?.getTokenizationService().createCardToken(securityCode: securityCode)
        })
        viewModel.pxNavigationHandler.pushViewController(viewController: securityCodeVc, animated: true, backToFirstPaymentVault: true)
    }

    func collectSecurityCodeForRetry() {
        let securityCodeVc = SecurityCodeViewController(viewModel: self.viewModel.cloneTokenSecurityCodeViewModel(), collectSecurityCodeCallback: { [weak self] (cardInformation: PXCardInformationForm, securityCode: String) -> Void in
            guard let token = cardInformation as? PXToken else {
                fatalError("Cannot convert cardInformation to Token")
            }
            self?.getTokenizationService().createCardToken(securityCode: securityCode, token: token)

        })
        viewModel.pxNavigationHandler.pushViewController(viewController: securityCodeVc, animated: true)

    }

    func showPaymentResultScreen() {
        if self.viewModel.businessResult != nil {
            self.showBusinessResultScreen()
            return
        }
        if self.viewModel.paymentResult == nil {
            self.viewModel.paymentResult = PaymentResult(payment: self.viewModel.payment!, paymentData: self.viewModel.paymentData)
        }

        var congratsViewController: MercadoPagoUIViewController
        let congratsViewControllerCallback: ( _ status: PaymentResult.CongratsState) -> Void = {[weak self] (state: PaymentResult.CongratsState) in
        guard let strongSelf = self else {
            return
        }
        strongSelf.viewModel.pxNavigationHandler.navigationController.setNavigationBarHidden(false, animated: false)
        if state == PaymentResult.CongratsState.call_FOR_AUTH {
            strongSelf.viewModel.prepareForClone()
            strongSelf.collectSecurityCodeForRetry()
        } else if state == PaymentResult.CongratsState.cancel_RETRY || state == PaymentResult.CongratsState.cancel_SELECT_OTHER {
            if let changePaymentMethodAction = strongSelf.viewModel.lifecycleProtocol?.changePaymentMethodTapped?(), state == PaymentResult.CongratsState.cancel_SELECT_OTHER {
                changePaymentMethodAction()
            } else {
                strongSelf.viewModel.prepareForNewSelection()
                strongSelf.executeNextStep()
            }
        } else {
            strongSelf.finish()
        }
    }

        let resultViewModel = self.viewModel.resultViewModel()
        if self.viewModel.paymentResult?.isApproved() ?? false || viewModel.instructionsInfo != nil {
            congratsViewController = PXNewResultViewController(viewModel: resultViewModel, callback: congratsViewControllerCallback)
        } else {
            congratsViewController = PXResultViewController(viewModel: resultViewModel, callback: congratsViewControllerCallback)
        }

        viewModel.pxNavigationHandler.pushViewController(viewController: congratsViewController, animated: false)
    }

    func showBusinessResultScreen() {
        var congratsViewController: MercadoPagoUIViewController
        let congratsViewControllerCallback: ( _ status: PaymentResult.CongratsState) -> Void = {[weak self] (_: PaymentResult.CongratsState) in
            self?.finish()
        }

        guard let businessResult = self.viewModel.businessResult else {
            return
        }

        let viewModel = PXBusinessResultViewModel(businessResult: businessResult, paymentData: self.viewModel.paymentData, amountHelper: self.viewModel.amountHelper, pointsAndDiscounts: self.viewModel.pointsAndDiscounts)

        if businessResult.isApproved() {
            congratsViewController = PXNewResultViewController(viewModel: viewModel, callback: congratsViewControllerCallback)
        } else {
            congratsViewController = PXResultViewController(viewModel: viewModel, callback: congratsViewControllerCallback)
        }

        self.viewModel.pxNavigationHandler.pushViewController(viewController: congratsViewController, animated: false)
    }

    func showErrorScreen() {
        viewModel.pxNavigationHandler.showErrorScreen(error: MercadoPagoCheckoutViewModel.error, callbackCancel: finish, errorCallback: self.viewModel.errorCallback)
        MercadoPagoCheckoutViewModel.error = nil
    }

    func showFinancialInstitutionsScreen() {
        if let financialInstitutions = self.viewModel.paymentData.getPaymentMethod()!.financialInstitutions {
            self.viewModel.financialInstitutions = financialInstitutions

            if financialInstitutions.count == 1 {
                self.viewModel.updateCheckoutModel(financialInstitution: financialInstitutions[0])
                self.executeNextStep()
            } else {
                let financialInstitutionStep = AdditionalStepViewController(viewModel:
                    self.viewModel.financialInstitutionViewModel(), callback: { [weak self] (financialInstitution) in
                        guard let financialInstitution = financialInstitution as? PXFinancialInstitution else {
                            fatalError("Cannot convert entityType to type EntityType")
                        }
                        self?.viewModel.updateCheckoutModel(financialInstitution: financialInstitution)
                        self?.executeNextStep()
                })

                financialInstitutionStep.callbackCancel = {[weak self] in
                    guard let object = self else {
                        return
                    }
                    object.viewModel.financialInstitutions = nil
                    object.viewModel.paymentData.transactionDetails?.financialInstitution = nil
                    self?.viewModel.pxNavigationHandler.navigationController.popViewController(animated: true)
                }

                viewModel.pxNavigationHandler.pushViewController(viewController: financialInstitutionStep, animated: true)
            }
        }
    }

    func showEntityTypesScreen() {
        let entityTypes = viewModel.getEntityTypes()

        self.viewModel.entityTypes = entityTypes

        if entityTypes.count == 1 {
            self.viewModel.updateCheckoutModel(entityType: entityTypes[0])
            self.executeNextStep()
        }

        let entityTypeStep = AdditionalStepViewController(viewModel: self.viewModel.entityTypeViewModel(), callback: { [weak self]  (entityType) in

            guard let entityType = entityType as? EntityType else {
                fatalError("Cannot convert entityType to type EntityType")
            }

            self?.viewModel.updateCheckoutModel(entityType: entityType)
            self?.executeNextStep()
        })

        entityTypeStep.callbackCancel = {[weak self] in
            guard let object = self else {
                return
            }
            object.viewModel.entityTypes = nil
            object.viewModel.paymentData.payer?.entityType = nil
            self?.viewModel.pxNavigationHandler.navigationController.popViewController(animated: true)
        }

        viewModel.pxNavigationHandler.pushViewController(viewController: entityTypeStep, animated: true)
    }

    func startOneTapFlow() {
        guard let search = viewModel.search, let paymentOtionSelected = viewModel.paymentOptionSelected else {
            return
        }

        let paymentFlow = viewModel.createPaymentFlow(paymentErrorHandler: self)

        let onetapFlow = OneTapFlow(navigationController: viewModel.pxNavigationHandler, paymentData: viewModel.paymentData, checkoutPreference: viewModel.checkoutPreference, search: search, paymentOptionSelected: paymentOtionSelected, reviewConfirmConfiguration: viewModel.getAdvancedConfiguration().reviewConfirmConfiguration, chargeRules: viewModel.chargeRules, oneTapResultHandler: self, advancedConfiguration: viewModel.getAdvancedConfiguration(), mercadoPagoServicesAdapter: viewModel.mercadoPagoServicesAdapter, paymentConfigurationService: self.viewModel.paymentConfigurationService, disabledOption: viewModel.disabledOption, escManager: viewModel.escManager)

        onetapFlow.setCustomerPaymentMethods(viewModel.customPaymentOptions)
        onetapFlow.setPaymentMethodPlugins(viewModel.paymentMethodPlugins)
        onetapFlow.setPaymentFlow(paymentFlow: paymentFlow)
        onetapFlow.start()
    }
}
