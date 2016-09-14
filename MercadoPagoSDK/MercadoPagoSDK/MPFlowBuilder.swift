//
//  MPFlowBuilder.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

public class MPFlowBuilder : NSObject {
    
    @available(*, deprecated=2.0.0, message="Use startCheckoutViewController instead")
    public class func startVaultViewController(amount: Double, paymentPreference : PaymentPreference? = nil,
                            callback: (paymentMethod: PaymentMethod, tokenId: String?, issuer: Issuer?, installments: Int) -> Void) -> VaultViewController {
        MercadoPagoContext.initFlavor3()
        return VaultViewController(amount: amount, paymentPreference: paymentPreference, callback: callback)
        
    }
    
    public class func startCheckoutViewController(preferenceId: String,
                        callback: (Payment) -> Void,
                        callbackCancel : (Void -> Void)? = nil) -> MPNavigationController {
        
        MercadoPagoContext.initFlavor3()
        let checkoutVC = CheckoutViewController(preferenceId: preferenceId,
                                                callback: { (payment : Payment) -> Void in callback(payment) },
                                                callbackCancel :callbackCancel)
        return MPFlowController.createNavigationControllerWith(checkoutVC)
    }
    

    public class func startPaymentVaultViewController(amount: Double, paymentPreference : PaymentPreference? = nil,
                                                      callback: (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost : PayerCost?) -> Void,
                                                      callbackCancel : (Void -> Void)? = nil) -> MPNavigationController {
        
        MercadoPagoContext.initFlavor2()
        let paymentVault = PaymentVaultViewController(amount: amount, paymentPreference : paymentPreference, callback: callback)
            paymentVault.viewModel.callback = {(paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost : PayerCost?) -> Void in
                                    paymentVault.dismissViewControllerAnimated(true, completion: { () -> Void in
                                            callback(paymentMethod: paymentMethod, token: token, issuer: issuer, payerCost: payerCost)}
                                    )}
        paymentVault.modalTransitionStyle = .CrossDissolve
        return MPFlowController.createNavigationControllerWith(paymentVault)
    }

    
    public class func startPaymentVaultViewController(amount : Double, paymentPreference : PaymentPreference? = nil, paymentMethodSearch : PaymentMethodSearch, callback: (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost: PayerCost?) -> Void, callbackCancel : (Void -> Void)? = nil) -> MPNavigationController {
        MercadoPagoContext.initFlavor2()
        var paymentVault : PaymentVaultViewController?
        paymentVault = PaymentVaultViewController(amount: amount, paymentPreference: paymentPreference, paymentMethodSearch: paymentMethodSearch, callback: {(paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost : PayerCost?) -> Void in
                paymentVault!.dismissViewControllerAnimated(true, completion: { () -> Void in
                callback(paymentMethod: paymentMethod, token: token, issuer: issuer, payerCost: payerCost)}
            )}, callbackCancel: callbackCancel)
        paymentVault!.modalTransitionStyle = .CrossDissolve
        return MPFlowController.createNavigationControllerWith(paymentVault!)
    }
    
    internal class func startPaymentVaultInCheckout(amount: Double, paymentPreference: PaymentPreference?, paymentMethodSearch : PaymentMethodSearch,
                                                    callback: (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost : PayerCost?) -> Void,
                                                    callbackCancel : (Void -> Void)? = nil) -> MPNavigationController {
        
        MercadoPagoContext.initFlavor2()
        let paymentVault = PaymentVaultViewController(amount: amount, paymentPreference: paymentPreference, paymentMethodSearchItem: paymentMethodSearch.groups, paymentMethods: paymentMethodSearch.paymentMethods, tintColor: true,
                                                      callback: callback, callbackCancel : callbackCancel)
        paymentVault.modalTransitionStyle = .CrossDissolve
        return MPFlowController.createNavigationControllerWith(paymentVault)
    }

    
    public class func startCardFlow(paymentPreference: PaymentPreference? = nil  , amount: Double, cardInformation : CardInformation? = nil, paymentMethods : [PaymentMethod]? = nil, token: Token? = nil, callback: (paymentMethod: PaymentMethod, token: Token? ,  issuer: Issuer?, payerCost: PayerCost?) -> Void, callbackCancel : (Void -> Void)? = nil) -> MPNavigationController {
        MercadoPagoContext.initFlavor2()
        var cardVC : MPNavigationController?
        var ccf : CardFormViewController = CardFormViewController()
        
        var currentCallbackCancel : (Void -> Void)
        if (callbackCancel == nil){
            currentCallbackCancel = { cardVC?.dismissViewControllerAnimated(true, completion: { () -> Void in })}
        } else {
            currentCallbackCancel = callbackCancel!
        }
        cardVC = MPStepBuilder.startCreditCardForm(paymentPreference, amount: amount, cardInformation : cardInformation, paymentMethods : paymentMethods, token: token, callback: { (paymentMethod, token, issuer) -> Void in
            
            MPServicesBuilder.getInstallments(token!.firstSixDigit, amount: amount, issuer: issuer, paymentMethodId: paymentMethod._id, success: { (installments) -> Void in
                let payerCostSelected = paymentPreference?.autoSelectPayerCost(installments![0].payerCosts)
                    if(payerCostSelected == nil){ // Si tiene una sola opcion de cuotas
                        let pcvc = MPStepBuilder.startPayerCostForm(paymentMethod, issuer: issuer, token: token!, amount:amount, paymentPreference: paymentPreference, installment:installments![0] ,callback: { (payerCost) -> Void in
                            callback(paymentMethod: paymentMethod, token: token!, issuer: issuer, payerCost: payerCost)
                        })
                        pcvc.callbackCancel = currentCallbackCancel
                        
                        ccf.navigationController!.pushViewController(pcvc, animated: false)

                    }else{
                         callback(paymentMethod: paymentMethod, token: token!, issuer: issuer, payerCost: payerCostSelected)
                    }

                
                }, failure: { (error) -> Void in
                     (ccf.navigationController as! MPNavigationController).hideLoading()
            })

            
            }, callbackCancel : currentCallbackCancel)
    
        ccf = cardVC?.viewControllers[0] as! CardFormViewController
    
        if (token != nil) {
            
        }
        cardVC!.modalTransitionStyle = .CrossDissolve
        return cardVC!

    }


}
