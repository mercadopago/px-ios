//
//  MPFlowBuilder.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

open class MPFlowBuilder : NSObject {
    
    @available(*, deprecated: 2.0.0, message: "Use startCheckoutViewController instead")
    open class func startVaultViewController(_ amount: Double, paymentPreference : PaymentPreference? = nil,
                                             callback: @escaping (_ paymentMethod: PaymentMethod, _ tokenId: String?, _ issuer: Issuer?, _ installments: Int) -> Void) -> VaultViewController {
        MercadoPagoContext.initFlavor3()
        return VaultViewController(amount: amount, paymentPreference: paymentPreference, callback: callback)
        
    }
    
    open class func startCheckoutViewController(_ preferenceId: String,
                                                callback: @escaping (Payment) -> Void,
                                                callbackCancel : ((Void) -> Void)? = nil) -> UINavigationController {
        
        MercadoPagoContext.initFlavor3()
        let checkoutVC = CheckoutViewController(preferenceId: preferenceId,
                                                callback: { (payment : Payment) -> Void in callback(payment) },
                                                callbackCancel :callbackCancel)
        return MPFlowController.createNavigationControllerWith(checkoutVC)
    }
    
    open class func startPaymentVaultViewController(_ amount: Double, paymentPreference : PaymentPreference? = nil,
                                                    callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost : PayerCost?) -> Void,
                                                    callbackCancel : ((Void) -> Void)? = nil) -> UINavigationController {
        
        MercadoPagoContext.initFlavor2()
        let paymentVault = PaymentVaultViewController(amount: amount, paymentPreference : paymentPreference, callback: callback, callbackCancel: callbackCancel)
        if let callbackCancel = callbackCancel{
            paymentVault.callbackCancel = {(Void) -> Void in
            paymentVault.dismiss(animated: true, completion: { callbackCancel()}
            )}
        }
        paymentVault.viewModel.callback = {(paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost : PayerCost?) -> Void in
            paymentVault.dismiss(animated: true, completion: { () -> Void in
                callback(paymentMethod, token, issuer, payerCost)}
            )}
        paymentVault.modalTransitionStyle = .crossDissolve
        return MPFlowController.createNavigationControllerWith(paymentVault)
    }
    
    
    open class func startPaymentVaultViewController(_ amount : Double, paymentPreference : PaymentPreference? = nil, paymentMethodSearch : PaymentMethodSearch, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void, callbackCancel : ((Void) -> Void)? = nil) -> UINavigationController {
        MercadoPagoContext.initFlavor2()
        var paymentVault : PaymentVaultViewController?
        paymentVault = PaymentVaultViewController(amount: amount, paymentPreference: paymentPreference, paymentMethodSearch: paymentMethodSearch, callback: {(paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost : PayerCost?) -> Void in
            paymentVault!.dismiss(animated: true, completion: { () -> Void in
                callback(paymentMethod, token, issuer, payerCost)}
            )}, callbackCancel: callbackCancel)
        if let callbackCancel = callbackCancel{
            paymentVault?.callbackCancel = {(Void) -> Void in
                paymentVault?.dismiss(animated: true, completion: { callbackCancel()}
                )}
        }
        paymentVault!.modalTransitionStyle = .crossDissolve
        return MPFlowController.createNavigationControllerWith(paymentVault!)
    }
    
    internal class func startPaymentVaultInCheckout(_ amount: Double, paymentPreference: PaymentPreference?, paymentMethodSearch : PaymentMethodSearch,
                                                    callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost : PayerCost?) -> Void,
                                                    callbackCancel : ((Void) -> Void)? = nil) -> UINavigationController {
        
        MercadoPagoContext.initFlavor2()
        let paymentVault =
            PaymentVaultViewController(amount: amount, paymentPreference: paymentPreference, paymentMethodSearch: paymentMethodSearch, tintColor: true,
                                                      callback: callback, callbackCancel : callbackCancel)
        paymentVault.modalTransitionStyle = .crossDissolve
        return MPFlowController.createNavigationControllerWith(paymentVault)
    }
    
    
    open class func startCardFlow(_ paymentPreference: PaymentPreference? = nil, amount: Double, cardInformation : CardInformation? = nil, paymentMethods : [PaymentMethod]? = nil, token: Token? = nil, timer : CountdownTimer? = nil, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token? ,  _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void, callbackCancel : ((Void) -> Void)? = nil) -> UINavigationController {
        MercadoPagoContext.initFlavor2()

        
        if (cardInformation == nil){
            return startDefaultCardFlow(paymentPreference, amount: amount, cardInformation: cardInformation, paymentMethods: paymentMethods, token: token, timer: timer, callback: callback, callbackCancel: callbackCancel)
        }else{
            return startCustomerCardFlow(paymentPreference, amount: amount, cardInformation: cardInformation, timer: timer, callback: callback, callbackCancel: callbackCancel)

        }
    }
    
    
    open class func startDefaultCardFlow(_ paymentPreference: PaymentPreference? = nil, amount: Double, cardInformation : CardInformation? = nil, paymentMethods : [PaymentMethod]? = nil, token: Token? = nil, timer : CountdownTimer? = nil, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token? ,  _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void, callbackCancel : ((Void) -> Void)? = nil) -> UINavigationController {
        MercadoPagoContext.initFlavor2()
        
        var cardVC : UINavigationController?
        
        var ccf : CardFormViewController = CardFormViewController()
        
        var currentCallbackCancel : ((Void) -> Void)
        if (callbackCancel == nil){
            currentCallbackCancel = { cardVC?.dismiss(animated: true, completion: { () -> Void in })}
        } else {
            currentCallbackCancel = callbackCancel!
        }
        
        cardVC = MPStepBuilder.startCreditCardForm(paymentPreference, amount: amount, cardInformation : cardInformation, paymentMethods : paymentMethods, token: token, timer: timer, callback: { (paymentMethod, token, issuer) -> Void in
            
            
            MPServicesBuilder.getInstallments(token!.firstSixDigit, amount: amount, issuer: issuer, paymentMethodId: paymentMethod._id, success: { (installments) -> Void in
                let payerCostSelected = paymentPreference?.autoSelectPayerCost(installments![0].payerCosts)
                if(payerCostSelected == nil){ // Si tiene una sola opcion de cuotas
                    
                    if installments![0].payerCosts.count>1{
                        let pcvc = MPStepBuilder.startPayerCostForm(paymentMethod, issuer: issuer, token: token!, amount:amount, paymentPreference: paymentPreference, installment:installments![0], timer: timer, callback: { (payerCost) -> Void in
                            callback(paymentMethod, token!, issuer, payerCost)
                        })
                        
                        pcvc.callbackCancel = currentCallbackCancel
                        
                        ccf.navigationController!.pushViewController(pcvc, animated: false)
                    }else {
                        callback(paymentMethod, token!, issuer, installments![0].payerCosts[0])

                    }
                    
                }else{
                    callback(paymentMethod, token!, issuer, payerCostSelected)
                }
                
                
                }, failure: { (error) -> Void in
                    if let nav = ccf.navigationController {
                        nav.hideLoading()
                    }
                    
                    
            })
            
            
            }, callbackCancel : currentCallbackCancel)
        
        ccf = cardVC?.viewControllers[0] as! CardFormViewController
        
        
        cardVC!.modalTransitionStyle = .crossDissolve
        return cardVC!
        
    }
    

    
    
    
    open class func startCustomerCardFlow(_ paymentPreference: PaymentPreference? = nil, amount: Double, cardInformation : CardInformation!, timer : CountdownTimer? = nil, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token? ,  _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void, callbackCancel : ((Void) -> Void)? = nil) -> UINavigationController {
        let mpNav =  UINavigationController()
        var pcvc : CardAdditionalStep!
        pcvc = MPStepBuilder.startPayerCostForm(cardInformation: cardInformation, amount:amount, paymentPreference: paymentPreference, installment:nil, timer: timer, callback: { (payerCost) -> Void in
                let secCode = MPStepBuilder.startSecurityCodeForm(paymentMethod: cardInformation.getPaymentMethod(), cardInfo: cardInformation) { (token) in
                    if String.isNullOrEmpty(token!.lastFourDigits) {
                        token!.lastFourDigits = cardInformation?.getCardLastForDigits()
                    }
                    callback(cardInformation.getPaymentMethod(),token,cardInformation.getIssuer(),payerCost as? PayerCost)
                }
                pcvc.navigationController!.pushViewController(secCode, animated: true)
            })
        pcvc.callbackCancel = callbackCancel
                    
        mpNav.pushViewController(pcvc, animated: true)
        
        
        return mpNav
    }
    
    

}


































