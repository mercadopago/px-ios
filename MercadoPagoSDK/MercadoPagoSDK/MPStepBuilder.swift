//
//  MPStepBuilder.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit
import MercadoPagoTracker

public class MPStepBuilder : NSObject {
    
    @objc
    public enum CongratsState : Int {
        case OK = 0
        case CANCEL_SELECT_OTHER = 1
        case CANCEL_RETRY = 2
        case CANCEL_RECOVER = 3
        case CALL_FOR_AUTH = 4
    }
    
    public class func startCustomerCardsStep(cards: [Card],
                                             callback: (selectedCard: Card?) -> Void) -> CustomerCardsViewController {
        
        MercadoPagoContext.initFlavor2()
        return CustomerCardsViewController(cards: cards, callback: callback)
    }
    
    public class func startNewCardStep(paymentMethod: PaymentMethod, requireSecurityCode: Bool = true,
                        callback: (cardToken: CardToken) -> Void) -> NewCardViewController {
        MercadoPagoContext.initFlavor2()
        return NewCardViewController(paymentMethod: paymentMethod, requireSecurityCode: requireSecurityCode, callback: callback)
        
    }
    
    public class func startPaymentMethodsStep(withPreference paymentPreference: PaymentPreference? = nil,
                                              callback:(paymentMethod: PaymentMethod) -> Void) -> PaymentMethodsViewController {
        MercadoPagoContext.initFlavor2()
        return PaymentMethodsViewController(paymentPreference: paymentPreference, callback: callback)
    }
    
    @available(*, deprecated=2.0.0, message="Use startPaymentMethodsStep with paymentPreference instead")
    public class func startPaymentMethodsStep(supportedPaymentTypes: Set<String>, callback:(paymentMethod: PaymentMethod) -> Void) -> PaymentMethodsViewController {
        MercadoPagoContext.initFlavor2()
        let paymentPreference = PaymentPreference()
        paymentPreference.excludedPaymentTypeIds = PaymentType.allPaymentIDs.subtract(supportedPaymentTypes)
        return PaymentMethodsViewController(paymentPreference: paymentPreference, callback: callback)
    }

    

    public class func startInstallmentsStep(payerCosts: [PayerCost]? = nil, paymentPreference: PaymentPreference? = nil, amount: Double, issuer: Issuer?, paymentMethodId: String?,
                                callback: (payerCost: PayerCost?) -> Void) -> InstallmentsViewController {
        MercadoPagoContext.initFlavor2()
        return InstallmentsViewController(payerCosts: payerCosts, paymentPreference: paymentPreference,amount: amount, issuer: issuer, paymentMethodId: paymentMethodId, callback: callback)
    }
    
    

    @available(*, deprecated=2.0.0, message="Use startPaymentCongratsStep instead")
    public class func startCongratsStep(payment: Payment, paymentMethod: PaymentMethod) -> CongratsViewController {
        MercadoPagoContext.initFlavor2()
        return CongratsViewController(payment: payment, paymentMethod: paymentMethod)
    }

    
    public class func startPaymentResultStep(payment: Payment, paymentMethod : PaymentMethod,
                                               callback : (payment : Payment, status : CongratsState) -> Void) -> MercadoPagoUIViewController {
        
        MercadoPagoContext.initFlavor2()
        if (paymentMethod.isOfflinePaymentMethod()){
            return self.startInstructionsStep(payment, paymentTypeId: paymentMethod.paymentTypeId, callback: callback)
        } else {
            return self.startPaymentCongratsStep(payment, paymentMethod: paymentMethod, callback : callback)
        }

    }
    
    public class func startPaymentCongratsStep(payment: Payment, paymentMethod : PaymentMethod,
                         callback : (payment : Payment, status : CongratsState) -> Void) -> PaymentCongratsViewController {
        
        MercadoPagoContext.initFlavor2()
        return PaymentCongratsViewController(payment: payment, paymentMethod : paymentMethod, callback : callback)
    }
    
    public class func startInstructionsStep(payment: Payment, paymentTypeId : String,
                        callback : (payment : Payment, status: CongratsState) -> Void) -> InstructionsViewController {
        
        MercadoPagoContext.initFlavor2()
        return InstructionsViewController(payment: payment, paymentTypeId : PaymentTypeId(rawValue: paymentTypeId)!, callback : {(payment : Payment) -> Void in
            callback(payment: payment, status: CongratsState.OK)
        })
    }
    
     public class func startPromosStep(
                        callback : (Void -> (Void))? = nil) -> PromoViewController {
        MercadoPagoContext.initFlavor2()
        return PromoViewController(callback : callback)
    }
    


    public class func startCreditCardForm(paymentSettings : PaymentPreference? = nil , amount: Double, cardInformation: CardInformation? = nil, paymentMethods : [PaymentMethod]? = nil, token: Token? = nil ,callback : ((paymentMethod: PaymentMethod, token: Token? ,  issuer: Issuer?) -> Void), callbackCancel : (Void -> Void)?) -> MPNavigationController {
        MercadoPagoContext.initFlavor2()
        var navigation : MPNavigationController?
        var ccf : CardFormViewController = CardFormViewController()

        ccf = CardFormViewController(paymentSettings : paymentSettings , amount: amount, cardInformation: cardInformation, paymentMethods : paymentMethods, token: token, callback : { (paymentMethod, cardToken) -> Void in
            
            if (token != nil){ // flujo token recuperable C4A
                MPServicesBuilder.cloneToken(token!,securityCode:(cardToken?.securityCode)!, success: { (token) in
                    callback(paymentMethod: paymentMethod, token: token, issuer: nil)
                    }, failure: { (error) in
                        
                })
                return
            }
            
            if(paymentMethod.isIdentificationRequired()){
                let identificationForm = MPStepBuilder.startIdentificationForm({ (identification) -> Void in
                    
                    cardToken?.cardholder?.identification = identification
                    self.getIssuers(paymentMethod, cardToken: cardToken!, ccf: ccf, callback: callback)
                    
                })

                identificationForm.callbackCancel = callbackCancel                
                
                ccf.navigationController!.pushViewController(identificationForm, animated: false)
                
                
            }else{
                 self.getIssuers(paymentMethod, cardToken: cardToken!, ccf: ccf, callback: callback)
            }
            
            },callbackCancel: callbackCancel)
        navigation = MPFlowController.createNavigationControllerWith(ccf)
        
        return navigation!

    }
    
    public class func startPayerCostForm(paymentMethod : PaymentMethod? , issuer:Issuer?, token : Token , amount: Double, paymentPreference: PaymentPreference? = nil, installment : Installment? = nil,
                                         callback : ((payerCost: PayerCost?) -> Void),
                                         callbackCancel : (Void -> Void)? = nil) -> PayerCostViewController {
        
        MercadoPagoContext.initFlavor2()
        return PayerCostViewController(paymentMethod: paymentMethod, issuer: issuer, token: token, amount: amount, paymentPreference: paymentPreference, installment : installment, callback: callback)
    }
    
    
    public class func startIdentificationForm(
                      callback : ((identification: Identification?) -> Void)) -> IdentificationViewController {
        
        MercadoPagoContext.initFlavor2()
        return IdentificationViewController(callback: callback)
    }
    
     public class func startIssuersStep(paymentMethod: PaymentMethod,
                        callback: (issuer: Issuer) -> Void) -> IssuersViewController {
        
        MercadoPagoContext.initFlavor2()
        return IssuersViewController(paymentMethod: paymentMethod, callback: callback)
    }
    
    public class func startIssuerForm(paymentMethod: PaymentMethod, cardToken: CardToken, issuerList: [Issuer]? = nil,
                        callback : ((issuer: Issuer?) -> Void)) -> IssuerCardViewController {
        
        MercadoPagoContext.initFlavor2()
        return IssuerCardViewController(paymentMethod: paymentMethod, cardToken: cardToken, callback: callback)
    }
    
    public class func startErrorViewController(error : MPError,
                        callback : (Void -> Void)? = nil,
                        callbackCancel : (Void -> Void)? = nil) -> ErrorViewController {
        
        MercadoPagoContext.initFlavor2()
        return ErrorViewController(error: error, callback: callback, callbackCancel: callbackCancel)
    }
    
    private class func getIssuers(paymentMethod : PaymentMethod, cardToken : CardToken, ccf : MercadoPagoUIViewController,
                         callback : (paymentMethod: PaymentMethod, token: Token, issuer:Issuer?) -> Void){
        MercadoPagoContext.initFlavor2()
        (ccf.navigationController as! MPNavigationController).showLoading()
        if !cardToken.isCustomerPaymentMethod() {
            MPServicesBuilder.getIssuers(paymentMethod,bin: cardToken.getBin(), success: { (issuers) -> Void in
                    if(issuers!.count > 1){
                        let issuerForm = MPStepBuilder.startIssuerForm(paymentMethod, cardToken: cardToken, issuerList: issuers, callback: { (issuer) -> Void in
                            (ccf.navigationController as! MPNavigationController).showLoading()
                            self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: issuer!, ccf : ccf, callback: callback)
                        })
                        issuerForm.callbackCancel = { Void -> Void in
                            ccf.navigationController!.dismissViewControllerAnimated(true, completion: {})
                        }
                        ccf.navigationController!.pushViewController(issuerForm, animated: false)
                    } else {
                        self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: issuers![0], ccf: ccf, callback: callback)
                    }
                }, failure: { (error) -> Void in
                    (ccf.navigationController as! MPNavigationController).hideLoading()
                    let errorVC = MPStepBuilder.startErrorViewController(MPError.convertFrom(error), callback: { (Void) in
                        self.getIssuers(paymentMethod, cardToken: cardToken, ccf: ccf, callback: callback)
                        }, callbackCancel: {
                            ccf.navigationController?.dismissViewControllerAnimated(true, completion: {})
                    })
                    ccf.navigationController?.presentViewController(errorVC, animated: true, completion: {})
                })
        } else {
            self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: nil, ccf: ccf, callback: callback)
        }
    }
    
    
    private class func createNewCardToken(cardToken : CardToken, paymentMethod : PaymentMethod, issuer : Issuer?, ccf : MercadoPagoUIViewController,
                          callback : (paymentMethod: PaymentMethod, token: Token, issuer:Issuer?) -> Void){
        
        if cardToken.isCustomerPaymentMethod() {
            MPServicesBuilder.createToken(cardToken as! SavedCardToken, success: { (token) in
                callback(paymentMethod: paymentMethod, token: token!, issuer: issuer)
                }, failure: { (error) in
                    let errorVC = MPStepBuilder.startErrorViewController(MPError.convertFrom(error), callback: { (Void) in
                    ccf.dismissViewControllerAnimated(true, completion: {})
                        //                        self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: issuer, ccf : ccf, callback: callback)
                    })
                    errorVC.callbackCancel = { ccf.hideLoading() }
                    ccf.navigationController?.presentViewController(errorVC, animated: true, completion: {})
                })
        } else {
            MPServicesBuilder.createNewCardToken(cardToken, success: {
                (token) -> Void in
                callback(paymentMethod: paymentMethod, token: token!, issuer: issuer!)
                
                ccf.hideLoading()
            }) { (error) -> Void in
                let errorVC = MPStepBuilder.startErrorViewController(MPError.convertFrom(error), callback: { (Void) in
                    ccf.dismissViewControllerAnimated(true, completion: {})
                    self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: issuer, ccf : ccf, callback: callback)
                })
                errorVC.callbackCancel = { ccf.hideLoading() }
                ccf.navigationController?.presentViewController(errorVC, animated: true, completion: {})
            }
        }
        
    }
    
    internal class func getInstallments(token : Token, amount : Double, issuer: Issuer, paymentTypeId : String, paymentMethod : PaymentMethod, ccf : MercadoPagoUIViewController,
                                        callback : (paymentMethod: PaymentMethod, token: Token? ,  issuer: Issuer?, payerCost: PayerCost?) -> Void,
                                        callbackCancel : (Void -> Void)? = nil){
        
        MercadoPagoContext.initFlavor2()
       MPServicesBuilder.getInstallments(token.firstSixDigit, amount: amount, issuer: issuer, paymentMethodId: paymentMethod._id, success: { (installments) -> Void in
            
            let pcvc = MPStepBuilder.startPayerCostForm(paymentMethod, issuer: issuer, token: token, amount:amount, paymentPreference: nil, callback: { (payerCost) -> Void in
                callback(paymentMethod: paymentMethod, token: token, issuer: issuer, payerCost: payerCost)
            })
            
            ccf.navigationController!.pushViewController(pcvc, animated: false)
            
            }, failure: { (error) -> Void in
                let errorVC = MPStepBuilder.startErrorViewController(MPError.convertFrom(error), callback: { (Void) in
                    ccf.navigationController!.popViewControllerAnimated(true)
                    self.getInstallments(token, amount: amount, issuer: issuer, paymentTypeId: paymentTypeId, paymentMethod: paymentMethod, ccf: ccf, callback: callback)
                })
                ccf.navigationController!.presentViewController(errorVC, animated: true, completion: {})
        })
    }
}

