//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

open class MercadoPagoCheckout: NSObject {

    static var currentCheckout: MercadoPagoCheckout?
    var viewModel: MercadoPagoCheckoutViewModel
    var navigationController: UINavigationController!
    var viewControllerBase: UIViewController?
    var countLoadings: Int = 0

    private var currentLoadingView: UIViewController?

    internal static var firstViewControllerPushed = false
    private var rootViewController: UIViewController?

    public init(publicKey: String, accessToken: String, checkoutPreference: CheckoutPreference, paymentData: PaymentData?, paymentResult: PaymentResult?, discount: DiscountCoupon? = nil, navigationController: UINavigationController) {
        viewModel = MercadoPagoCheckoutViewModel(checkoutPreference : checkoutPreference, paymentData: paymentData, paymentResult: paymentResult, discount : discount)
        DecorationPreference.saveNavBarStyleFor(navigationController: navigationController)
        self.navigationController = navigationController

        if self.navigationController.viewControllers.count > 0 {
            let  newNavigationStack = self.navigationController.viewControllers.filter {!$0.isKind(of:MercadoPagoUIViewController.self) || $0.isKind(of:ReviewScreenViewController.self)
            }
            viewControllerBase = newNavigationStack.last
        }

        MercadoPagoContext.setPublicKey(publicKey)

        MercadoPagoContext.setPayerAccessToken(accessToken)

    }

    public func setBinaryMode(_ binaryMode: Bool) {
        self.viewModel.binaryMode = binaryMode
    }

    public func start() {
        MercadoPagoCheckout.currentCheckout = self
        executeNextStep()

    }

    func initialize() {
        MPXTracker.trackScreen(screenId: TrackingUtil.SCREEN_ID_CHECKOUT, screenName: TrackingUtil.SCREEN_NAME_CHECKOUT)
        executeNextStep()
    }
    func executeNextStep() {

        switch self.viewModel.nextStep() {
        case .START :
            self.initialize()
        case .SEARCH_PREFERENCE :
            self.collectCheckoutPreference()
        case .VALIDATE_PREFERENCE :
            self.validatePreference()
        case .SEARCH_DIRECT_DISCOUNT:
            self.collectDirectDiscount()
        case .SEARCH_PAYMENT_METHODS :
            self.collectPaymentMethodSearch()
        case .PAYMENT_METHOD_SELECTION :
            self.collectPaymentMethods()
        case .CARD_FORM:
            self.collectCard()
        case .IDENTIFICATION :
            self.collectIdentification()
        case .ENTITY_TYPE :
            self.collectEntityTypes()
        case .CREDIT_DEBIT:
            self.collectCreditDebit()
        case .GET_FINANCIAL_INSTITUTIONS:
            self.collectFinancialInstitutions()
        case .GET_ISSUERS:
            self.collectIssuers()
        case .ISSUERS_SCREEN:
            self.startIssuersScreen()
        case .CREATE_CARD_TOKEN :
            self.createCardToken()
        case .GET_PAYER_COSTS:
            self.collectPayerCosts()
        case .PAYER_COST_SCREEN:
            self.startPayerCostScreen()
        case .REVIEW_AND_CONFIRM :
            self.collectPaymentData()
        case .SECURITY_CODE_ONLY :
            self.collectSecurityCode()
        case .POST_PAYMENT :
            self.createPayment()
        case .CONGRATS :
            self.displayPaymentResult()
        case .FINISH:
            self.finish()
        case .ERROR:
            self.error()
        default: break
        }
    }

    func collectCheckoutPreference() {
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
                strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_PREFERENCE.rawValue), errorCallback: { [weak self] (_) -> Void in
                    self?.collectCheckoutPreference()
                })
                strongSelf.executeNextStep()
        })
    }

    func validatePreference() {
        let errorMessage = self.viewModel.checkoutPreference.validate()
        if errorMessage != nil {
            self.viewModel.errorInputs(error: MPSDKError(message: "Hubo un error".localized, errorDetail: errorMessage!, retry: false), errorCallback : { (_) -> Void in })
        }
        self.executeNextStep()
    }

    func collectDirectDiscount() {
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

    func collectPaymentMethodSearch() {
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
                strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.PAYMENT_METHOD_SEARCH.rawValue), errorCallback: { [weak self] (_) -> Void in

                    self?.collectPaymentMethodSearch()
                })
                strongSelf.executeNextStep()
        })
    }

    func collectPaymentMethods() {
        // Se limpia paymentData antes de ofrecer selección de medio de pago

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

    func collectCard() {

        let cardFormStep = CardFormViewController(cardFormManager: self.viewModel.cardFormManager(), callback: { [weak self](paymentMethods, cardToken) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(paymentMethods: paymentMethods, cardToken:cardToken)
            strongSelf.executeNextStep()
        })
        self.pushViewController(viewController : cardFormStep, animated: true)
    }

    func collectIdentification() {
        let identificationStep = IdentificationViewController (callback: { [weak self] (identification : Identification) in
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

    func collectCreditDebit() {
        let crediDebitStep = AdditionalStepViewController(viewModel: self.viewModel.debitCreditViewModel(), callback: { [weak self] (paymentMethod) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(paymentMethod: paymentMethod as! PaymentMethod)
            strongSelf.executeNextStep()
        })
        self.pushViewController(viewController : crediDebitStep, animated: true)
    }

    func collectFinancialInstitutions() {
        if let financialInstitutions = self.viewModel.paymentData.paymentMethod.financialInstitutions {
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

    func collectEntityTypes() {
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

    func collectIssuers() {
        self.presentLoading()
        let bin = self.viewModel.cardToken?.getBin()
        MPServicesBuilder.getIssuers(self.viewModel.paymentData.paymentMethod, bin: bin, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: { [weak self] (issuers) -> Void in
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
            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_ISSUERS.rawValue), errorCallback: { [weak self] (_) in
                self?.collectIssuers()
            })
            strongSelf.executeNextStep()
        }

    }

    func startIssuersScreen() {
        let issuerStep = AdditionalStepViewController(viewModel: self.viewModel.issuerViewModel(), callback: { [weak self](issuer) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(issuer: issuer as! Issuer)
            strongSelf.executeNextStep()

        })
        issuerStep.callbackCancel = {
            self.viewModel.issuers = nil
            self.viewModel.paymentData.issuer = nil
        }
        self.navigationController.pushViewController(issuerStep, animated: true)
    }

    func createCardToken(cardInformation: CardInformation? = nil, securityCode: String? = nil) {
        guard let cardInfo = cardInformation else {
            createNewCardToken()
            return
        }
        if cardInfo.canBeClone() {
            guard let token = cardInfo as? Token else {
                return // TODO Refactor : Tenemos unos lios barbaros con CardInformation y CardInformationForm, no entiendo porque hay uno y otr
            }
            cloneCardToken(token: token, securityCode: securityCode!)

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
                let error = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)

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

        MPServicesBuilder.createToken(saveCardToken, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getGatewayURL(), success: { [weak self] (token) in
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
                strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue), errorCallback: { [weak self] (_) in
                    self?.createSavedCardToken(cardInformation: cardInformation, securityCode: securityCode)
                })
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
                strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue), errorCallback: { [weak self] (_) in
                    self?.cloneCardToken(token: token, securityCode: securityCode)
                })
                strongSelf.executeNextStep()
        })
    }

    func collectPayerCosts(updateCallback: (() -> Void)? = nil) {
        self.presentLoading()
        let bin = self.viewModel.cardToken?.getBin()

        MPServicesBuilder.getInstallments(bin, amount: self.viewModel.getFinalAmount(), issuer: self.viewModel.paymentData.issuer, paymentMethodId: self.viewModel.paymentData.paymentMethod._id, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: { [weak self] (installments) -> Void in
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
            strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_INSTALLMENTS.rawValue), errorCallback: { [weak self] (_) in
                self?.collectPayerCosts()
            })
            strongSelf.executeNextStep()
        }

    }

    func startPayerCostScreen() {
        let payerCostViewModel = self.viewModel.payerCostViewModel()

        let payerCostStep = AdditionalStepViewController(viewModel: payerCostViewModel, callback: { [weak self] (payerCost) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(payerCost: payerCost as! PayerCost)
            strongSelf.executeNextStep()
        })
        payerCostStep.callbackCancel = {
            self.viewModel.payerCosts = nil
            self.viewModel.paymentData.payerCost = nil
        }
        payerCostStep.viewModel.couponCallback = {[weak self] (discount) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.viewModel.paymentData.discount = discount
            payerCostStep.viewModel.discount = discount

            strongSelf.collectPayerCosts(updateCallback: {
                payerCostStep.updateDataSource(dataSource: (strongSelf.viewModel.payerCosts)!)
            })

        }
        self.pushViewController(viewController : payerCostStep, animated: true)
    }

    func collectPaymentData() {
        let checkoutVC = ReviewScreenViewController(viewModel: self.viewModel.checkoutViewModel(), callbackPaymentData: { [weak self] (paymentData : PaymentData) -> Void in
            guard let strongSelf = self else {
                return
            }

            strongSelf.viewModel.updateCheckoutModel(paymentData: paymentData)
            if paymentData.paymentMethod == nil && MercadoPagoCheckoutViewModel.changePaymentMethodCallback != nil {
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
                    MercadoPagoCheckoutViewModel.paymentDataConfirmCallback!(strongSelf.viewModel.paymentData)
                } else {
                    strongSelf.executeNextStep()
                }
        })

        self.pushViewController(viewController: checkoutVC, animated: true, completion: {
            self.cleanNavigationStack()
        })
    }

    func cleanNavigationStack () {

        // TODO WALLET
        var  newNavigationStack = self.navigationController.viewControllers.filter {!$0.isKind(of:MercadoPagoUIViewController.self) || $0.isKind(of:ReviewScreenViewController.self)
        }
        self.navigationController.viewControllers = newNavigationStack

    }

    private func executePaymentDataCallback() {
        if MercadoPagoCheckoutViewModel.paymentDataCallback != nil {
            MercadoPagoCheckoutViewModel.paymentDataCallback!(self.viewModel.paymentData)
        }
    }

    func collectSecurityCode() {
        let securityCodeVc = SecurityCodeViewController(viewModel: self.viewModel.savedCardSecurityCodeViewModel(), collectSecurityCodeCallback : { [weak self] (cardInformation: CardInformationForm, securityCode: String) -> Void in
            self?.createCardToken(cardInformation: cardInformation as! CardInformation, securityCode: securityCode)

        })
        self.pushViewController(viewController : securityCodeVc, animated: true)

    }

    func collectSecurityCodeForRetry() {
        let securityCodeVc = SecurityCodeViewController(viewModel: self.viewModel.cloneTokenSecurityCodeViewModel(), collectSecurityCodeCallback: { [weak self] (cardInformation: CardInformationForm, securityCode: String) -> Void in
            self?.cloneCardToken(token: cardInformation as! Token, securityCode: securityCode)

        })
        self.pushViewController(viewController : securityCodeVc, animated: true)

    }

    public func updateReviewAndConfirm() {
        let currentViewController = self.navigationController.viewControllers
        if let checkoutVC = currentViewController.last as? ReviewScreenViewController {
            checkoutVC.showNavBar()
            checkoutVC.viewModel = viewModel.checkoutViewModel()
            checkoutVC.checkoutTable.reloadData()
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

            strongSelf.executeNextStep()
            strongSelf.dismissLoading()
            }, failure: {[weak self] (error: NSError) -> Void in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.dismissLoading()
                strongSelf.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_PAYMENT.rawValue), errorCallback: { [weak self] (_) in
                    self?.createPayment()
                })
                strongSelf.executeNextStep()
        })
    }

    func displayPaymentResult() {
        if self.viewModel.paymentResult == nil {
            self.viewModel.paymentResult = PaymentResult(payment: self.viewModel.payment!, paymentData: self.viewModel.paymentData)
        }

        if viewModel.shouldDisplayPaymentResult() {

            let congratsViewController: MercadoPagoUIViewController
            if PaymentTypeId.isOnlineType(paymentTypeId: self.viewModel.paymentData.paymentMethod.paymentTypeId) {
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
                congratsViewController = InstructionsViewController(paymentResult: self.viewModel.paymentResult!, callback: { [weak self] (_ :PaymentResult.CongratsState) in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.navigationController.setNavigationBarHidden(false, animated: false)
                    strongSelf.finish()
                    }, paymentResultScreenPreference: self.viewModel.paymentResultScreenPreference)
            }
            self.pushViewController(viewController : congratsViewController, animated: true)
        } else {
            finish()
        }
    }

    func error() {
        // Display error
        let errorStep = ErrorViewController(error: MercadoPagoCheckoutViewModel.error, callback: nil, callbackCancel: {[weak self] in

            guard let strongSelf = self else {
                return
            }
            strongSelf.finish()

        })
        // Limpiar error anterior
        MercadoPagoCheckoutViewModel.error = nil

        errorStep.callback = {
            self.navigationController.dismiss(animated: true, completion: {
                self.viewModel.errorCallback?()
            })
        }
        self.navigationController.present(errorStep, animated: true, completion: {})
    }

    func finish() {
        DecorationPreference.applyAppNavBarDecorationPreferencesTo(navigationController: self.navigationController)

        removeRootLoading()

        if self.viewModel.paymentData.isComplete() && !MercadoPagoCheckoutViewModel.flowPreference.isReviewAndConfirmScreenEnable() && MercadoPagoCheckoutViewModel.paymentDataCallback != nil && !self.viewModel.isCheckoutComplete() {
            MercadoPagoCheckoutViewModel.paymentDataCallback!(self.viewModel.paymentData)
            return

        } else if let payment = self.viewModel.payment, let paymentCallback = MercadoPagoCheckoutViewModel.paymentCallback {
            paymentCallback(payment)
            return

        }

        goToRootViewController()
    }

    func cancel() {
        DecorationPreference.applyAppNavBarDecorationPreferencesTo(navigationController: self.navigationController)

        if let callback = viewModel.callbackCancel {
            callback()
            return
        }

        goToRootViewController()
    }

    public func goToRootViewController() {
        if let rootViewController = viewControllerBase {
            self.navigationController.popToViewController(rootViewController, animated: true)
            self.navigationController.setNavigationBarHidden(false, animated: false)
        } else {
            self.navigationController.dismiss(animated: true, completion: {
                // --- Nothing
                self.navigationController.setNavigationBarHidden(false, animated: false)
            })
        }
    }

    func presentLoading(animated: Bool = false, completion: (() -> Swift.Void)? = nil) {
        self.countLoadings += 1
        if self.countLoadings == 1 {
            let when = DispatchTime.now() + 0.3
            DispatchQueue.main.asyncAfter(deadline: when) {
                if self.countLoadings > 0 && self.currentLoadingView == nil {
                    self.createCurrentLoading()
                    self.navigationController.present(self.currentLoadingView!, animated: animated, completion: completion)
                }
            }

        }
    }

    func dismissLoading(animated: Bool = false, completion: (() -> Swift.Void)? = nil) {
        self.countLoadings -= 1
        if self.currentLoadingView != nil && countLoadings == 0 {
            self.currentLoadingView!.dismiss(animated: animated, completion: completion)
            self.currentLoadingView?.view.alpha = 0
            self.currentLoadingView = nil
        }
    }

    private func createCurrentLoading() {
        let vcLoading = MPXLoadingViewController()
        vcLoading.view.backgroundColor = MercadoPagoCheckoutViewModel.decorationPreference.baseColor
        let loadingInstance = LoadingOverlay.shared.showOverlay(vcLoading.view, backgroundColor: MercadoPagoCheckoutViewModel.decorationPreference.baseColor)

        vcLoading.view.addSubview(loadingInstance)
        loadingInstance.bringSubview(toFront: vcLoading.view)

        self.currentLoadingView = vcLoading
    }

    private func pushViewController(viewController: MercadoPagoUIViewController,
                                    animated: Bool,
                                    completion : (() -> Swift.Void)? = nil) {

        viewController.hidesBottomBarWhenPushed = true
        let mercadoPagoViewControllers = self.navigationController.viewControllers.filter {$0.isKind(of:MercadoPagoUIViewController.self)}
        if mercadoPagoViewControllers.count == 0 {
            self.navigationController.navigationBar.isHidden = false
            viewController.callbackCancel = { self.cancel() }
        }
        self.navigationController.pushViewController(viewController, animated: animated)
    }

    internal func removeRootLoading() {
        let currentViewControllers = self.navigationController.viewControllers.filter { (vc: UIViewController) -> Bool in
            return vc != self.rootViewController
        }
        self.navigationController.viewControllers = currentViewControllers
    }

    public func popToWhenFinish(viewController: UIViewController) {
        if self.navigationController.viewControllers.contains(viewController) {
            self.viewControllerBase = viewController
        }
    }

}
