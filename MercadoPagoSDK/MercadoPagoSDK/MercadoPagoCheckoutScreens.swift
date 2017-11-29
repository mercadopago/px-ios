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
        self.viewModel.paymentData.clearCollectedData()
        let paymentMethodSelectionStep = PaymentVaultViewController(viewModel: self.viewModel.paymentVaultViewModel(), callback : { [weak self] (paymentOptionSelected: PaymentMethodOption) -> Void  in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(paymentOptionSelected : paymentOptionSelected)
            strongSelf.viewModel.rootVC = false
            strongSelf.executeNextStep()
        })
        self.pushViewController(viewController : paymentMethodSelectionStep, animated: true)

    }
    func showCardForm() {
        let cardFormStep = CardFormViewController(cardFormManager: self.viewModel.cardFormManager(), callback: { [weak self](paymentMethods, cardToken) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(paymentMethods: paymentMethods, cardToken:cardToken)
            strongSelf.executeNextStep()
        })
        self.pushViewController(viewController : cardFormStep, animated: true)
    }

    func showIdentificationScreen() {
        let identificationStep = IdentificationViewController (identificationTypes: self.viewModel.identificationTypes!, callback: { [weak self] (identification : Identification) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(identification : identification)
            strongSelf.executeNextStep()
            }, errorExitCallback: { [weak self] in
                self?.finish()
        })

        identificationStep.callbackCancel = {[weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        self.pushViewController(viewController : identificationStep, animated: true)
    }

    func showPayerInfoFlow() {
        let viewModel = self.viewModel.payerInfoFlow()
        let vc = PayerInfoViewController(viewModel: viewModel) { [weak self] (payer) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(payer : payer)
            strongSelf.executeNextStep()
        }
        self.pushViewController(viewController : vc, animated: true)
    }

    func showIssuersScreen() {
        let issuerStep = AdditionalStepViewController(viewModel: self.viewModel.issuerViewModel(), callback: { [weak self](issuer) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(issuer: issuer as! Issuer)
            strongSelf.executeNextStep()

        })
        self.navigationController.pushViewController(issuerStep, animated: true)
    }

    func showPayerCostScreen() {
        let payerCostViewModel = self.viewModel.payerCostViewModel()

        let payerCostStep = AdditionalStepViewController(viewModel: payerCostViewModel, callback: { [weak self] (payerCost) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(payerCost: payerCost as! PayerCost)
            strongSelf.executeNextStep()
        })

        payerCostStep.viewModel.couponCallback = {[weak self] (discount) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.viewModel.paymentData.discount = discount
            payerCostStep.viewModel.discount = discount

            strongSelf.getPayerCosts(updateCallback: {
                payerCostStep.updateDataSource(dataSource: (strongSelf.viewModel.payerCosts)!)
            })

        }
        self.pushViewController(viewController : payerCostStep, animated: true)
    }

    func showReviewAndConfirmScreen() {
        let checkoutVC = ReviewScreenViewController(viewModel: self.viewModel.checkoutViewModel(), callbackPaymentData: { [weak self] (paymentData : PaymentData) -> Void in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(paymentData: paymentData)
            if !paymentData.hasPaymentMethod() && MercadoPagoCheckoutViewModel.changePaymentMethodCallback != nil {
                MercadoPagoCheckoutViewModel.changePaymentMethodCallback!()
            }
            strongSelf.executeNextStep()

            }, callbackExit : { [weak self] () -> Void in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.cancel()

            }, callbackConfirm : {[weak self] (paymentData: PaymentData) -> Void in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.viewModel.updateCheckoutModel(paymentData: paymentData)
                if MercadoPagoCheckoutViewModel.paymentDataConfirmCallback != nil {
                    MercadoPagoCheckoutViewModel.paymentDataCallback = MercadoPagoCheckoutViewModel.paymentDataConfirmCallback
                    strongSelf.finish()
                } else {
                    strongSelf.executeNextStep()
                }
        })

        checkoutVC.callbackCancel = {
            self.viewModel.readyToPay = false
        }

        self.pushViewController(viewController: checkoutVC, animated: true, completion: {
            self.cleanNavigationStack()
        })
    }

    func showSecurityCodeScreen() {
        let securityCodeVc = SecurityCodeViewController(viewModel: self.viewModel.savedCardSecurityCodeViewModel(), collectSecurityCodeCallback : { [weak self] (cardInformation: CardInformationForm, securityCode: String) -> Void in
            self?.createCardToken(cardInformation: cardInformation as!  CardInformation, securityCode: securityCode)

        })
        self.pushViewController(viewController : securityCodeVc, animated: true)

    }

    func collectSecurityCodeForRetry() {
        let securityCodeVc = SecurityCodeViewController(viewModel: self.viewModel.cloneTokenSecurityCodeViewModel(), collectSecurityCodeCallback: { [weak self] (cardInformation: CardInformationForm, securityCode: String) -> Void in
            self?.cloneCardToken(token: cardInformation as! Token, securityCode: securityCode)

        })
        self.pushViewController(viewController : securityCodeVc, animated: true)

    }

    func showPaymentResultScreen() {
        if self.viewModel.paymentResult == nil {
            self.viewModel.paymentResult = PaymentResult(payment: self.viewModel.payment!, paymentData: self.viewModel.paymentData)
        }

       self.viewModel.saveOrDeleteESC()

        let congratsViewController: MercadoPagoUIViewController

        if PaymentTypeId.isOnlineType(paymentTypeId: self.viewModel.paymentData.getPaymentMethod()!.paymentTypeId) || self.viewModel.paymentResult?.status == PaymentStatus.REJECTED {
            congratsViewController = PaymentResultViewController(paymentResult: self.viewModel.paymentResult!, checkoutPreference: self.viewModel.checkoutPreference, paymentResultScreenPreference: self.viewModel.paymentResultScreenPreference, callback: { [weak self] (state: PaymentResult.CongratsState) in

                guard let strongSelf = self else {
                    return
                }

                strongSelf.navigationController.setNavigationBarHidden(false, animated: false)
                if state == PaymentResult.CongratsState.call_FOR_AUTH {
                    strongSelf.viewModel.prepareForClone()
                    strongSelf.collectSecurityCodeForRetry()
                } else if state == PaymentResult.CongratsState.cancel_RETRY || state == PaymentResult.CongratsState.cancel_SELECT_OTHER {
                    strongSelf.viewModel.prepareForNewSelection()
                    strongSelf.executeNextStep()

                } else {
                    strongSelf.finish()
                }

            })
        } else {
            congratsViewController = InstructionsViewController(paymentResult: self.viewModel.paymentResult!, instructionsInfo: self.viewModel.instructionsInfo!, callback: { [weak self] (_ :PaymentResult.CongratsState) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.navigationController.setNavigationBarHidden(false, animated: false)
                strongSelf.finish()
                }, paymentResultScreenPreference: self.viewModel.paymentResultScreenPreference)
        }
        self.pushViewController(viewController : congratsViewController, animated: false)
    }

    func showErrorScreen() {
        let errorStep = ErrorViewController(error: MercadoPagoCheckoutViewModel.error, callback: nil, callbackCancel: {[weak self] in

            guard let strongSelf = self else {
                return
            }
            strongSelf.finish()
        })

        MercadoPagoCheckoutViewModel.error = nil
        errorStep.callback = {
            self.navigationController.dismiss(animated: true, completion: {
                self.viewModel.errorCallback?()
            })
        }
        self.navigationController.present(errorStep, animated: true, completion: {})
    }

    func showFinancialInstitutionsScreen() {
        if let financialInstitutions = self.viewModel.paymentData.getPaymentMethod()!.financialInstitutions {
            self.viewModel.financialInstitutions = financialInstitutions

            if financialInstitutions.count == 1 {
                self.viewModel.updateCheckoutModel(financialInstitution: financialInstitutions[0])
                self.executeNextStep()
            } else {
                let financialInstitutionStep = AdditionalStepViewController(viewModel: self.viewModel.financialInstitutionViewModel(), callback: { (financialInstitution) in
                    self.viewModel.updateCheckoutModel(financialInstitution: (financialInstitution as! FinancialInstitution))
                    self.executeNextStep()
                })

                financialInstitutionStep.callbackCancel = {[weak self] in
                    guard let object = self else {
                        return
                    }
                    object.viewModel.financialInstitutions = nil
                    object.viewModel.paymentData.transactionDetails?.financialInstitution = nil
                }

                self.navigationController.pushViewController(financialInstitutionStep, animated: true)
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

        let entityTypeStep = AdditionalStepViewController(viewModel: self.viewModel.entityTypeViewModel(), callback: { (entityType) in
            self.viewModel.updateCheckoutModel(entityType: (entityType as! EntityType))
            self.executeNextStep()
        })

        entityTypeStep.callbackCancel = {[weak self] in
            guard let object = self else {
                return
            }
            object.viewModel.entityTypes = nil
            object.viewModel.paymentData.payer.entityType = nil
        }

        self.navigationController.pushViewController(entityTypeStep, animated: true)
    }

    func showHookScreen(hookStep : PXHookStep) {

        if let targetHook = MercadoPagoCheckoutViewModel.flowPreference.getHookForStep(hookStep: hookStep) {

            let vc = MercadoPagoUIViewController()
            vc.view.backgroundColor = .clear

            vc.callbackCancel = {
                self.viewModel.wentBackFrom(hook: hookStep)
            }

            self.viewModel.copyViewModelAndAssignToHookStore()

            // Set custom attributes to Hook NavigationBar
            vc.title = targetHook.titleForNavigationBar()
            vc.shouldShowBackArrow = targetHook.shouldShowBackArrow()
            vc.shouldHideNavigationBar = !targetHook.shouldShowNavigationBar()
            if let navBarColor = targetHook.colorForNavigationBar() {
                vc.setNavBarBackgroundColor(color: navBarColor)
            }

            let hookView = targetHook.render()
            hookView.removeFromSuperview()
            hookView.frame = vc.view.frame
            vc.view.addSubview(hookView)

            targetHook.renderDidFinish()

            self.navigationController.pushViewController(vc, animated: true)
            
            self.viewModel.continueFrom(hook: hookStep)
        }
    }
}
