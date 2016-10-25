//
//  MPStepBuilder.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit


open class MPStepBuilder : NSObject {
    
    @objc
    public enum CongratsState : Int {
        case ok = 0
        case cancel_SELECT_OTHER = 1
        case cancel_RETRY = 2
        case cancel_RECOVER = 3
        case call_FOR_AUTH = 4
    }
    
    open class func startCustomerCardsStep(_ cards: [Card],
                                             callback: @escaping (_ selectedCard: Card?) -> Void) -> CustomerCardsViewController {
        
     MercadoPagoContext.initFlavor2()
        return CustomerCardsViewController(cards: cards, callback: callback)
    }
    
    open class func startNewCardStep(_ paymentMethod: PaymentMethod, requireSecurityCode: Bool = true,
                        callback: @escaping (_ cardToken: CardToken) -> Void) -> NewCardViewController {
     MercadoPagoContext.initFlavor2()
        return NewCardViewController(paymentMethod: paymentMethod, requireSecurityCode: requireSecurityCode, callback: callback)
        
    }
    
    open class func startPaymentMethodsStep(withPreference paymentPreference: PaymentPreference? = nil,
                                              callback:@escaping (_ paymentMethod: PaymentMethod) -> Void) -> PaymentMethodsViewController {
      MercadoPagoContext.initFlavor2()
        return PaymentMethodsViewController(paymentPreference: paymentPreference, callback: callback)
    }
    
    @available(*, deprecated: 2.0.0, message: "Use startPaymentMethodsStep with paymentPreference instead")
    open class func startPaymentMethodsStep(_ supportedPaymentTypes: Set<String>, callback:@escaping (_ paymentMethod: PaymentMethod) -> Void) -> PaymentMethodsViewController {
     MercadoPagoContext.initFlavor2()
        let paymentPreference = PaymentPreference()
        paymentPreference.excludedPaymentTypeIds = PaymentType.allPaymentIDs.subtracting(supportedPaymentTypes)
        return PaymentMethodsViewController(paymentPreference: paymentPreference, callback: callback)
    }

    

    open class func startInstallmentsStep(_ payerCosts: [PayerCost]? = nil, paymentPreference: PaymentPreference? = nil, amount: Double, issuer: Issuer?, paymentMethodId: String?,
                                callback: @escaping (_ payerCost: PayerCost?) -> Void) -> InstallmentsViewController {
      MercadoPagoContext.initFlavor2()
        return InstallmentsViewController(payerCosts: payerCosts, paymentPreference: paymentPreference,amount: amount, issuer: issuer, paymentMethodId: paymentMethodId, callback: callback)
    }
    
    

    @available(*, deprecated: 2.0.0, message: "Use startPaymentCongratsStep instead")
    open class func startCongratsStep(_ payment: Payment, paymentMethod: PaymentMethod) -> CongratsViewController {
      MercadoPagoContext.initFlavor2()
        return CongratsViewController(payment: payment, paymentMethod: paymentMethod)
    }

    
    open class func startPaymentResultStep(_ payment: Payment, paymentMethod : PaymentMethod,
                                               callback : @escaping (_ payment : Payment, _ status : CongratsState) -> Void) -> MercadoPagoUIViewController {
        
      MercadoPagoContext.initFlavor2()
        if (!paymentMethod.isOnlinePaymentMethod()){
            return self.startInstructionsStep(payment, paymentTypeId: paymentMethod.paymentTypeId, callback: callback)
        } else {
            return self.startPaymentCongratsStep(payment, paymentMethod: paymentMethod, callback : callback)
        }

    }
    
    open class func startPaymentCongratsStep(_ payment: Payment, paymentMethod : PaymentMethod,
                         callback : @escaping (_ payment : Payment, _ status : CongratsState) -> Void) -> PaymentCongratsViewController {
        
      MercadoPagoContext.initFlavor2()
        return PaymentCongratsViewController(payment: payment, paymentMethod : paymentMethod, callback : callback)
    }
    
    open class func startInstructionsStep(_ payment: Payment, paymentTypeId : String,
                        callback : @escaping (_ payment : Payment, _ status: CongratsState) -> Void) -> InstructionsViewController {
        
        MercadoPagoContext.initFlavor2()
        return InstructionsViewController(payment: payment, paymentTypeId : PaymentTypeId(rawValue: paymentTypeId)!, callback : {(payment : Payment) -> Void in
            callback(payment, CongratsState.ok)
        })
    }
    
     open class func startPromosStep(
                        _ callback : ((Void) -> (Void))? = nil) -> PromoViewController {
        MercadoPagoContext.initFlavor2()
        return PromoViewController(callback : callback)
    }
    


    open class func startCreditCardForm(_ paymentSettings : PaymentPreference? = nil , amount: Double, cardInformation: CardInformation? = nil, paymentMethods : [PaymentMethod]? = nil, token: Token? = nil, timer : CountdownTimer? = nil, callback : @escaping ((_ paymentMethod: PaymentMethod, _ token: Token? ,  _ issuer: Issuer?) -> Void), callbackCancel : ((Void) -> Void)?) -> MPNavigationController {
        MercadoPagoContext.initFlavor2()
        var navigation : MPNavigationController?
        var ccf : CardFormViewController = CardFormViewController()

        ccf = CardFormViewController(paymentSettings : paymentSettings , amount: amount, token: token, cardInformation: cardInformation, paymentMethods : paymentMethods, timer : timer, callback : { (paymentMethod, cardToken) -> Void in
            
            if (token != nil){ // flujo token recuperable C4A
                MPServicesBuilder.cloneToken(token!,securityCode:(cardToken?.securityCode)!, success: { (token) in
                    callback(paymentMethod, token, nil)
                    }, failure: { (error) in
                        
                })
                return
            }
            
            if(paymentMethod.isIdentificationRequired()){
                let identificationForm = MPStepBuilder.startIdentificationForm({ (identification) -> Void in
                    
                    cardToken?.cardholder?.identification = identification
                    self.getIssuers(paymentMethod, cardToken: cardToken!, customerCard: cardInformation, ccf: ccf, callback: callback)
                    
                }, timer : timer)

                identificationForm.callbackCancel = callbackCancel                
                
                ccf.navigationController!.pushViewController(identificationForm, animated: false)
                
                
            }else{
                self.getIssuers(paymentMethod, cardToken: cardToken!, customerCard: cardInformation, ccf: ccf, callback: callback)
            }
            
            },callbackCancel: callbackCancel)
        navigation = MPFlowController.createNavigationControllerWith(ccf)
        
        return navigation!

    }
    
    open class func startPayerCostForm(_ paymentMethod : PaymentMethod? , issuer:Issuer?, token : Token , amount: Double, paymentPreference: PaymentPreference? = nil, installment : Installment? = nil, timer: CountdownTimer? = nil,
                                         callback : @escaping ((_ payerCost: PayerCost?) -> Void),
                                         callbackCancel : ((Void) -> Void)? = nil) -> PayerCostViewController {
        
        MercadoPagoContext.initFlavor2()
        return PayerCostViewController(paymentMethod: paymentMethod, issuer: issuer, token: token, amount: amount, paymentPreference: paymentPreference, installment : installment, timer : timer, callback: callback)
    }
    
    
    open class func startIdentificationForm(
        _ callback : @escaping ((_ identification: Identification?) -> Void), timer : CountdownTimer? = nil) -> IdentificationViewController {
        
        MercadoPagoContext.initFlavor2()
        return IdentificationViewController(callback: callback, timer : timer)
    }
    
     open class func startIssuersStep(_ paymentMethod: PaymentMethod,
                        callback: @escaping (_ issuer: Issuer) -> Void) -> IssuersViewController {
        
        MercadoPagoContext.initFlavor2()
        return IssuersViewController(paymentMethod: paymentMethod, callback: callback)
    }
    
    open class func startIssuerForm(_ paymentMethod: PaymentMethod, cardToken: CardToken, issuerList: [Issuer]? = nil, timer : CountdownTimer? = nil,
                        callback : @escaping ((_ issuer: Issuer?) -> Void)) -> IssuerCardViewController {
        
        MercadoPagoContext.initFlavor2()
        return IssuerCardViewController(paymentMethod: paymentMethod, cardToken: cardToken, timer : timer, callback: callback)
    }
    
    open class func startErrorViewController(_ error : MPError,
                        callback : ((Void) -> Void)? = nil,
                        callbackCancel : ((Void) -> Void)? = nil) -> ErrorViewController {
        
        MercadoPagoContext.initFlavor2()
        return ErrorViewController(error: error, callback: callback, callbackCancel: callbackCancel)
    }
    
    fileprivate class func getIssuers(_ paymentMethod : PaymentMethod, cardToken : CardToken, customerCard : CardInformation? = nil, timer : CountdownTimer? = nil, ccf : MercadoPagoUIViewController,
                         callback : @escaping (_ paymentMethod: PaymentMethod, _ token: Token, _ issuer:Issuer?) -> Void){
        MercadoPagoContext.initFlavor2()
        (ccf.navigationController as! MPNavigationController).showLoading()
        if !cardToken.isCustomerPaymentMethod() {
            MPServicesBuilder.getIssuers(paymentMethod,bin: cardToken.getBin(), success: { (issuers) -> Void in
                    if(issuers!.count > 1){
                        let issuerForm = MPStepBuilder.startIssuerForm(paymentMethod, cardToken: cardToken, issuerList: issuers, timer : timer, callback: { (issuer) -> Void in
                            (ccf.navigationController as! MPNavigationController).showLoading()
                            self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: issuer!, ccf : ccf, callback: callback)
                        })
                        issuerForm.callbackCancel = { Void -> Void in
                            ccf.navigationController!.dismiss(animated: true, completion: {})
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
                            ccf.navigationController?.dismiss(animated: true, completion: {})
                    })
                    ccf.navigationController?.present(errorVC, animated: true, completion: {})
                })
        } else {
            self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: nil, customerCard: customerCard, ccf: ccf, callback: callback)
        }
    }
    
    
    fileprivate class func createNewCardToken(_ cardToken : CardToken, paymentMethod : PaymentMethod, issuer : Issuer?, customerCard : CardInformation? = nil, ccf : MercadoPagoUIViewController,
                          callback : @escaping (_ paymentMethod: PaymentMethod, _ token: Token, _ issuer:Issuer?) -> Void){
        
        if cardToken.isCustomerPaymentMethod() {
            MPServicesBuilder.createToken(cardToken as! SavedCardToken, success: { (token) in
                if customerCard != nil && token!.lastFourDigits.isEmpty {
                    token!.lastFourDigits = customerCard!.getCardLastForDigits()
                }
                callback(paymentMethod, token!, issuer)
                }, failure: { (error) in
                    let errorVC = MPStepBuilder.startErrorViewController(MPError.convertFrom(error), callback: { (Void) in
                    ccf.dismiss(animated: true, completion: {})
                        self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: issuer, ccf : ccf, callback: callback)
                    })
                    errorVC.callbackCancel = { ccf.hideLoading() }
                    ccf.navigationController?.present(errorVC, animated: true, completion: {})
                })
        } else {
            MPServicesBuilder.createNewCardToken(cardToken, success: {
                (token) -> Void in
                callback(paymentMethod, token!, issuer!)
                
                ccf.hideLoading()
            }) { (error) -> Void in
                let errorVC = MPStepBuilder.startErrorViewController(MPError.convertFrom(error), callback: { (Void) in
                    ccf.dismiss(animated: true, completion: {})
                    self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: issuer, ccf : ccf, callback: callback)
                })
                errorVC.callbackCancel = { ccf.hideLoading() }
                ccf.navigationController?.present(errorVC, animated: true, completion: {})
            }
        }
        
    }
    
    internal class func getInstallments(_ token : Token, amount : Double, issuer: Issuer, paymentTypeId : String, paymentMethod : PaymentMethod, ccf : MercadoPagoUIViewController,
                                        callback : @escaping (_ paymentMethod: PaymentMethod, _ token: Token? ,  _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void,
                                        callbackCancel : ((Void) -> Void)? = nil){
        
        MercadoPagoContext.initFlavor2()
       MPServicesBuilder.getInstallments(token.firstSixDigit, amount: amount, issuer: issuer, paymentMethodId: paymentMethod._id, success: { (installments) -> Void in
            
            let pcvc = MPStepBuilder.startPayerCostForm(paymentMethod, issuer: issuer, token: token, amount:amount, paymentPreference: nil, callback: { (payerCost) -> Void in
                callback(paymentMethod, token, issuer, payerCost)
            })
            
            ccf.navigationController!.pushViewController(pcvc, animated: false)
            
            }, failure: { (error) -> Void in
                let errorVC = MPStepBuilder.startErrorViewController(MPError.convertFrom(error), callback: { (Void) in
                    ccf.navigationController!.popViewController(animated: true)
                    self.getInstallments(token, amount: amount, issuer: issuer, paymentTypeId: paymentTypeId, paymentMethod: paymentMethod, ccf: ccf, callback: callback)
                })
                ccf.navigationController!.present(errorVC, animated: true, completion: {})
        })
    }
}

