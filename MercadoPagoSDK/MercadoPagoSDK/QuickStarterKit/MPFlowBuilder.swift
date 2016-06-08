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
    
    @available(*, deprecated=2.0, message="Use startCheckoutViewController instead")
    public class func startVaultViewController(amount: Double, supportedPaymentTypes: Set<PaymentTypeId>?, callback: (paymentMethod: PaymentMethod, tokenId: String?, issuer: Issuer?, installments: Int) -> Void) -> VaultViewController {
        
        return VaultViewController(amount: amount, supportedPaymentTypes: supportedPaymentTypes, callback: callback)
        
    }
    
    public class func startCheckoutViewController(preferenceId: String, callback: (Payment) -> Void) -> MPNavigationController {
            let checkoutVC = CheckoutViewController(preferenceId: preferenceId, callback: { (payment : Payment) -> Void in
            callback(payment)
        })
        return MPFlowController.createNavigationControllerWith(checkoutVC)
    }
    
    
    public class func startPaymentVaultViewController(amount: Double, currencyId : String!,paymentPreference : PaymentPreference, pictureUrl : String = "", callback: (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost : PayerCost?) -> Void) -> MPNavigationController {
        
        let paymentVault = PaymentVaultViewController(amount: amount, currencyId : currencyId, paymentPreference : paymentPreference, callback: callback)

        paymentVault.callback = {(paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost : PayerCost?) -> Void in
            paymentVault.dismissViewControllerAnimated(true, completion: { () -> Void in
                callback(paymentMethod: paymentMethod, token: token, issuer: issuer, payerCost: payerCost)
            })
        }
        
        paymentVault.modalTransitionStyle = .CrossDissolve
        return MPFlowController.createNavigationControllerWith(paymentVault)
    }
    
    internal class func startPaymentVaultInCheckout(amount: Double, currencyId : String!, paymentSettings: PaymentPreference?, paymentMethodSearch : PaymentMethodSearch, callback: (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost : PayerCost?) -> Void) -> MPNavigationController {
        
        let paymentVault = PaymentVaultViewController(amount: amount, currencyId : currencyId, paymentSettings: paymentSettings, paymentMethodSearchItem: paymentMethodSearch.groups, paymentMethods: paymentMethodSearch.paymentMethods, tintColor: true, callback: callback)
        
        paymentVault.modalTransitionStyle = .CrossDissolve
        return MPFlowController.createNavigationControllerWith(paymentVault)
    }

    
    
    public class func startCardFlow(paymentSettings: PaymentPreference? , amount: Double, paymentMethods : [PaymentMethod]? = nil, callback: (paymentMethod: PaymentMethod, token: Token? ,  issuer: Issuer?, payerCost: PayerCost?) -> Void, var callbackCancel : (Void -> Void)? = nil) -> MPNavigationController {
    
        var cardVC : MPNavigationController?
        var ccf : CardFormViewController = CardFormViewController()
        
        if (callbackCancel == nil){
            callbackCancel = { cardVC?.dismissViewControllerAnimated(true, completion: { () -> Void in
            }) }
        }
        cardVC = MPStepBuilder.startCreditCardForm(paymentSettings, amount: amount, paymentMethods : paymentMethods, callback: { (paymentMethod, token, issuer) -> Void in
            
            MPServicesBuilder.getInstallments(token!.firstSixDigit, amount: amount, issuer: issuer, paymentTypeId: PaymentTypeId.CREDIT_CARD, success: { (installments) -> Void in
                 //(ccf.navigationController as! MPNavigationController).hideLoading()
                let payerCostSelected = paymentSettings?.autoSelectPayerCost(installments![0].payerCosts)
                    if(payerCostSelected == nil){ // Si tiene una sola opcion de cuotas
                        let pcvc = MPStepBuilder.startPayerCostForm(paymentMethod, issuer: issuer, token: token!, amount:amount, maxInstallments: paymentSettings?.maxAcceptedInstallments, installment:installments![0] ,callback: { (payerCost) -> Void in
                            callback(paymentMethod: paymentMethod, token: token!, issuer: issuer, payerCost: payerCost)
                        })
                        pcvc.callbackCancel = callbackCancel
                        
                        ccf.navigationController!.pushViewController(pcvc, animated: false)

                    }else{
                         callback(paymentMethod: paymentMethod, token: token!, issuer: issuer, payerCost: payerCostSelected)
                    }

                
                }, failure: { (error) -> Void in
                     (ccf.navigationController as! MPNavigationController).hideLoading()
            })

            
            }, callbackCancel : callbackCancel)
    
        ccf = cardVC?.viewControllers[0] as! CardFormViewController
    
        cardVC!.modalTransitionStyle = .CrossDissolve
        return cardVC!

    }


}
