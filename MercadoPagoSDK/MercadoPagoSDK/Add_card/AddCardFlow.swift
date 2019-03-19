//
//  AddCardFlow.swift
//  MercadoPagoSDK
//
//  Created by Diego Flores Domenech on 6/9/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

@objc public protocol AddCardFlowProtocol {
    func addCardFlowSucceded(result: [String: Any])
    func addCardFlowFailed(shouldRestart: Bool)
}

@objcMembers
public class AddCardFlow: NSObject, PXFlow {

    public var delegate: AddCardFlowProtocol?

    private let accessToken: String
    private let model = AddCardFlowModel()
    private let navigationHandler: PXNavigationHandler

    private lazy var mercadoPagoServicesAdapter = MercadoPagoServicesAdapter(publicKey: "APP_USR-5bd14fdd-3807-446f-babd-095788d5ed4d", privateKey: self.accessToken)

    public init(accessToken: String, locale: String, navigationController: UINavigationController) {
        self.accessToken = accessToken
        self.navigationHandler = PXNavigationHandler(navigationController: navigationController)
        super.init()
        Localizator.sharedInstance.setLanguage(string: locale)
        ThemeManager.shared.saveNavBarStyleFor(navigationController: navigationController)
        PXNotificationManager.SuscribeTo.attemptToClose(self, selector: #selector(goBack))
    }

    public func start() {
        self.executeNextStep()
    }

    public func setTheme(theme: PXTheme) {
        ThemeManager.shared.setTheme(theme: theme)
    }

    func executeNextStep() {
        if self.model.lastStepFailed {
            self.navigationHandler.presentLoading()
        }
        switch self.model.nextStep() {
        case .getPaymentMethods:
            self.getPaymentMethods()
        case .getIdentificationTypes:
            self.getIdentificationTypes()
        case .openCardForm:
            self.openCardForm()
        case .openIdentificationTypes:
            self.openIdentificationTypesScreen()
        case .createToken:
            self.createCardToken()
        case .associateTokenWithUser:
            self.associateTokenWithUser()
        case .showCongrats:
            self.showCongrats()
        case .finish:
            self.finish()
        default:
            break
        }
    }

    func cancelFlow() {
    }

    func finishFlow() {
    }

    func exitCheckout() {
    }

    // MARK: steps

    private func getPaymentMethods() {
        self.navigationHandler.presentLoading()
        let service = PaymentMethodsUserService(accessToken: self.accessToken)
        service.getPaymentMethods(success: { [weak self] (paymentMethods) in
            self?.model.paymentMethods = paymentMethods
            self?.executeNextStep()
        }) { [weak self] (error) in
            self?.model.lastStepFailed = true
            if error.code == ErrorTypes.NO_INTERNET_ERROR {
                let sdkError = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_PAYMENT_METHODS.rawValue)
                self?.navigationHandler.showErrorScreen(error: sdkError, callbackCancel: {
                    self?.finish()
                }, errorCallback: nil)
            } else {
                self?.showErrorScreen()
            }
        }
    }

    private func getIdentificationTypes() {
        self.mercadoPagoServicesAdapter.getIdentificationTypes(callback: { [weak self] identificationTypes in
            self?.model.identificationTypes = identificationTypes
            self?.executeNextStep()
        }, failure: { [weak self] error in
            self?.model.lastStepFailed = true
            if error.code == ErrorTypes.NO_INTERNET_ERROR {
                let sdkError = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_IDENTIFICATION_TYPES.rawValue)
                self?.navigationHandler.showErrorScreen(error: sdkError, callbackCancel: {
                    self?.navigationHandler.dismissLoading()
                    self?.finish()
                }, errorCallback: nil)
            } else {
                if let status = error.userInfo["status"] as? Int, status == 404 {
                    self?.navigationHandler.dismissLoading()
                    self?.model.identificationTypes = []
                    self?.model.lastStepFailed = false
                    self?.executeNextStep()
                } else {
                    self?.navigationHandler.dismissLoading()
                    self?.showErrorScreen()
                }
            }
        })
    }

    private func openCardForm() {
        guard let paymentMethods = self.model.paymentMethods else {
            return
        }
        let cardFormViewModel = CardFormViewModel(paymentMethods: paymentMethods, guessedPaymentMethods: nil, customerCard: nil, token: nil, mercadoPagoServicesAdapter: nil, bankDealsEnabled: false)
        let cardFormViewController = CardFormViewController(cardFormManager: cardFormViewModel, callback: { [weak self](paymentMethods, cardToken) in
            self?.model.cardToken = cardToken
            self?.model.selectedPaymentMethod = paymentMethods.first
            self?.executeNextStep()
        })
        self.navigationHandler.pushViewController(cleanCompletedCheckouts: false, targetVC: cardFormViewController, animated: true)
        self.navigationHandler.dismissLoading()
    }

    private func openIdentificationTypesScreen() {
        guard let identificationTypes = self.model.identificationTypes else {
            return
        }
        let identificationViewController = IdentificationViewController(identificationTypes: identificationTypes, paymentMethod: model.selectedPaymentMethod, callback: { [weak self] (identification) in
            self?.model.cardToken?.cardholder?.identification = identification
            self?.executeNextStep()
        }) { [weak self] in
            self?.showErrorScreen()
        }
        self.navigationHandler.pushViewController(cleanCompletedCheckouts: false, targetVC: identificationViewController, animated: true)
    }

    private func createCardToken() {
        guard let cardToken = self.model.cardToken else {
            return
        }
        self.navigationHandler.presentLoading()
        self.mercadoPagoServicesAdapter.createToken(cardToken: cardToken, callback: { [weak self] (token) in
            self?.model.tokenizedCard = token
            self?.executeNextStep()
            }, failure: {[weak self] (error) in
                let reachabilityManager = PXReach()
                if reachabilityManager.connectionStatus().description == ReachabilityStatus.offline.description {
                    self?.model.lastStepFailed = true
                    let sdkError = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)
                    self?.navigationHandler.showErrorScreen(error: sdkError, callbackCancel: {
                        self?.finish()
                    }, errorCallback: nil)
                } else {
                    self?.showErrorScreen()
                }
        })
    }

    private func associateTokenWithUser() {
        guard let selectedPaymentMethod = self.model.selectedPaymentMethod, let token = self.model.tokenizedCard else {
            return
        }
        let associateCardService = AssociateCardService(accessToken: self.accessToken)
        associateCardService.associateCardToUser(paymentMethod: selectedPaymentMethod, cardToken: token, success: { [weak self] (json) in
            print(json)
            self?.navigationHandler.dismissLoading()
            self?.model.associateCardResult = json
            if let esc = token.esc {
                let escManager = MercadoPagoESCImplementation(enabled: false)
                _ = escManager.saveESC(cardId: token.cardId, esc: esc)
            }
            self?.executeNextStep()
        }) { [weak self] (error) in
            if error.code == ErrorTypes.NO_INTERNET_ERROR {
                self?.model.lastStepFailed = true
                let sdkError = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.ASSOCIATE_TOKEN.rawValue)
                self?.navigationHandler.showErrorScreen(error: sdkError, callbackCancel: {
                    self?.finish()
                }, errorCallback: nil)
            } else {
                self?.showErrorScreen()
            }
        }
    }

    private func showCongrats() {
        let viewModel = PXResultAddCardSuccessViewModel(buttonCallback: { [weak self] in
            self?.executeNextStep()
        })
        let congratsVc = PXResultViewController(viewModel: viewModel) { (_) in
        }
        self.navigationHandler.pushViewController(cleanCompletedCheckouts: false, targetVC: congratsVc, animated: true)
    }

    private func finish() {
        if let associateCardResult = self.model.associateCardResult {
            self.delegate?.addCardFlowSucceded(result: associateCardResult)
        } else {
            self.delegate?.addCardFlowFailed(shouldRestart: false)
        }
        ThemeManager.shared.applyAppNavBarStyle(navigationController: self.navigationHandler.navigationController)
    }

    private func showErrorScreen() {
        let viewModel = PXResultAddCardFailedViewModel(buttonCallback: { [weak self] in
            self?.reset()
            }, linkCallback: { [weak self] in
                self?.finish()
        })
        let failVc = PXResultViewController(viewModel: viewModel) { (_) in
        }
        self.navigationHandler.pushViewController(cleanCompletedCheckouts: false, targetVC: failVc, animated: true)
    }

    private func reset() {
        PXNotificationManager.Post.cardFormReset()
        if let cardForm = self.navigationHandler.navigationController.viewControllers.filter({$0 is CardFormViewController}).first {
            self.navigationHandler.navigationController.popToViewController(cardForm, animated: true)
            self.model.reset()
        } else {
            self.delegate?.addCardFlowFailed(shouldRestart: true)
            ThemeManager.shared.applyAppNavBarStyle(navigationController: self.navigationHandler.navigationController)
        }
        self.navigationHandler.navigationController.setNavigationBarHidden(false, animated: true)
    }

    @objc private func goBack() {
        self.navigationHandler.popViewController(animated: true)
        ThemeManager.shared.applyAppNavBarStyle(navigationController: self.navigationHandler.navigationController)
    }

}
