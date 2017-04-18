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
                         callback : @escaping (_ payment : Payment, _ status : CongratsState) -> Void) -> CongratsRevampViewController {
        
      MercadoPagoContext.initFlavor2()
        return CongratsRevampViewController(payment: payment, paymentMethod : paymentMethod, callback : callback)

    }
    
    open class func startInstructionsStep(_ payment: Payment, paymentTypeId : String,
                                          callback : @escaping (_ payment : Payment, _ status: CongratsState) -> Void) -> InstructionsRevampViewController {
        MercadoPagoContext.initFlavor2()
        return InstructionsRevampViewController(payment: payment, paymentTypeId : paymentTypeId, callback : {(payment : Payment, status: CongratsState) -> Void in
            callback(payment, CongratsState.ok)
        })
    }
    
    open class func startPromosStep(promos : [Promo]? = nil,
        _ callback : ((Void) -> (Void))? = nil) -> PromoViewController {
        MercadoPagoContext.initFlavor2()
        return PromoViewController(promos : promos, callback : callback)
    }
    
    fileprivate class func verifyPaymentMethods(paymentMethods: [PaymentMethod], cardToken: CardToken, amount: Double, cardInformation: CardInformation?, callback: @escaping ((_ paymentMethod: PaymentMethod, _ token: Token? ,  _ issuer: Issuer?) -> Void), ccf: MercadoPagoUIViewController, callbackCancel: ((Void) -> Void)?) -> Bool{
        if paymentMethods.count == 2 {
            if paymentMethods[0].paymentTypeId == PaymentTypeId.CREDIT_CARD.rawValue || paymentMethods[1].paymentTypeId == PaymentTypeId.CREDIT_CARD.rawValue {
                if paymentMethods[0].paymentTypeId == PaymentTypeId.DEBIT_CARD.rawValue || paymentMethods[1].paymentTypeId == PaymentTypeId.DEBIT_CARD.rawValue{
                    let creditDebitForm = startCreditDebitForm(paymentMethods, issuer: nil, token: cardToken, amount: amount, callback: { (selectedPaymentMethod) in
                        self.getIssuers(selectedPaymentMethod as! PaymentMethod, cardToken: cardToken, customerCard: cardInformation, ccf: ccf, callback: callback, callbackCancel: callbackCancel)
                    })
                    creditDebitForm.callbackCancel = callbackCancel
                    ccf.navigationController!.pushViewController(creditDebitForm, animated: false)
                    return true
                }
            }
        }
        return false
    }
    
    
    
    
    
    open class func startSecurityCodeForm(paymentMethod : PaymentMethod! ,cardInfo : CardInformationForm!, callback: ((_ token: Token?)->Void)! ) -> SecurityCodeViewController {
        let secVC = SecurityCodeViewController(paymentMethod: paymentMethod, cardInfo: cardInfo, callback: callback)
        return secVC
    }
    
    
    open class func startCreditCardForm(_ paymentSettings : PaymentPreference? = nil , amount: Double, cardInformation: CardInformation? = nil, paymentMethods : [PaymentMethod]? = nil, token: Token? = nil, callback : @escaping ((_ paymentMethod: PaymentMethod, _ token: Token? ,  _ issuer: Issuer?) -> Void), callbackCancel : ((Void) -> Void)?) -> UINavigationController {
        MercadoPagoContext.initFlavor2()
        var navigation : UINavigationController?
        
        var ccf : CardFormViewController = CardFormViewController()
        
        //C4A
        
        ccf = CardFormViewController(paymentSettings : paymentSettings , amount: amount, token: token, cardInformation: cardInformation, paymentMethods : paymentMethods, callback : { (paymentMethod, cardToken) -> Void in
            
            if (token != nil){ // flujo token recuperable C4A
                MPServicesBuilder.cloneToken(token!,securityCode:(cardToken?.securityCode)!, success: { (token) in
                    callback(paymentMethod[0], token, nil)
                    }, failure: { (error) in
                        
                })
                return
            }
            
            if(paymentMethod[0].isIdentificationRequired()){
                let identificationForm = MPStepBuilder.startIdentificationForm({ (identification) -> Void in
                    cardToken?.cardholder?.identification = identification
                    
                    if !verifyPaymentMethods(paymentMethods: paymentMethod, cardToken: cardToken!, amount: amount, cardInformation: cardInformation, callback: callback, ccf: ccf, callbackCancel: callbackCancel){
                        self.getIssuers(paymentMethod[0], cardToken: cardToken!, customerCard: cardInformation, ccf: ccf, callback: callback)
                    }
                    
                    })
                
                identificationForm.callbackCancel = callbackCancel
                
                ccf.navigationController!.pushViewController(identificationForm, animated: false)
                
            }else{
                
                if !verifyPaymentMethods(paymentMethods: paymentMethod, cardToken: cardToken!, amount: amount, cardInformation: cardInformation, callback: callback, ccf: ccf, callbackCancel: callbackCancel){
                    self.getIssuers(paymentMethod[0], cardToken: cardToken!, customerCard: cardInformation, ccf: ccf, callback: callback)
                }
            }
            },callbackCancel: callbackCancel)
        
        navigation = MPFlowController.createNavigationControllerWith(ccf)
        
        return navigation!
        
    }
    
    open class func startCreditDebitForm(_ paymentMethod : [PaymentMethod] , issuer:Issuer?, token : CardToken? , amount: Double, paymentPreference: PaymentPreference? = nil,
                                         callback : @escaping ((_ paymentMethod: NSObject?) -> Void),
                                         callbackCancel : ((Void) -> Void)? = nil) -> CardAdditionalStep {
        
        MercadoPagoContext.initFlavor2()
        return CardAdditionalStep(paymentMethod: paymentMethod, issuer: issuer, token: token, amount: amount, paymentPreference: paymentPreference, installment : nil, callback: callback )
    }
    
    open class func startPayerCostForm(_ paymentMethod : PaymentMethod , issuer:Issuer?, token : Token? , amount: Double, paymentPreference: PaymentPreference? = nil, installment : Installment? = nil,
                                       callback : @escaping ((_ payerCost: PayerCost?) -> Void),
                                       callbackCancel : ((Void) -> Void)? = nil) -> CardAdditionalStep {
        
        MercadoPagoContext.initFlavor2()
        let call : (_ payerCost: NSObject?) -> Void = {(payerCost: NSObject?) in
            callback(payerCost as? PayerCost)
        }
        return CardAdditionalStep(paymentMethod: [paymentMethod], issuer: issuer, token: token, amount: amount, paymentPreference: paymentPreference, installment: installment, callback: call)
    }

    public class func startPayerCostForm(cardInformation : CardInformation, amount: Double, paymentPreference: PaymentPreference? = nil, installment : Installment? = nil,
                                       callback : @escaping ((_ payerCost: NSObject?) -> Void),
                                       callbackCancel : ((Void) -> Void)? = nil) -> CardAdditionalStep {
        
        MercadoPagoContext.initFlavor2()
        return CardAdditionalStep(cardInformation: cardInformation, amount: amount, paymentPreference: paymentPreference, installment: installment, callback: callback)
    }
    
    open class func startIdentificationForm(
        
        _ callback : @escaping ((_ identification: Identification?) -> Void)) -> IdentificationViewController {
        
        MercadoPagoContext.initFlavor2()
        return IdentificationViewController(callback: callback)
    }
    
    open class func startIssuersStep(_ paymentMethod: PaymentMethod,
                                     callback: @escaping (_ issuer: Issuer) -> Void) -> IssuersViewController {
        let call : (_ issuer: NSObject) -> Void = {(issuer: NSObject) in
            callback(issuer as! Issuer)
        }
        MercadoPagoContext.initFlavor2()
        return IssuersViewController(paymentMethod: paymentMethod, callback: call)
    }
    open class func startIssuerForm(_ paymentMethod: PaymentMethod, cardToken: CardToken, issuerList: [Issuer]? = nil,
                                    callback : @escaping ((_ issuer: NSObject?) -> Void)) -> CardAdditionalStep {
        
        MercadoPagoContext.initFlavor2()
        return CardAdditionalStep(paymentMethod: [paymentMethod], issuer: nil, token: cardToken, amount: nil, paymentPreference: nil, installment : nil, callback: callback)
        
    }
    
    
    open class func startErrorViewController(_ error : MPSDKError,
                                             callback : ((Void) -> Void)? = nil,
                                             callbackCancel : ((Void) -> Void)? = nil) -> ErrorViewController {
        MercadoPagoContext.initFlavor2()
        return ErrorViewController(error: error, callback: callback, callbackCancel: callbackCancel)
    }
    
    fileprivate class func getIssuers(_ paymentMethod : PaymentMethod, cardToken : CardToken, customerCard : CardInformation? = nil, ccf : MercadoPagoUIViewController,
                                      callback : @escaping (_ paymentMethod: PaymentMethod, _ token: Token, _ issuer:Issuer?) -> Void ,
                                      callbackCancel : ((Void) -> Void)? = nil){
        MercadoPagoContext.initFlavor2()

        
        if !cardToken.isCustomerPaymentMethod() {
            MPServicesBuilder.getIssuers(paymentMethod,bin: cardToken.getBin(), success: { (issuers) -> Void in

                    if(issuers.count > 1){
                        let issuerForm = MPStepBuilder.startIssuerForm(paymentMethod, cardToken: cardToken, issuerList: issuers, callback: { (issuer) -> Void in
                            if let nav = ccf.navigationController {
                                
                            }
                            
                            self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: issuer as? Issuer, ccf : ccf, callback: callback, callbackCancel: callbackCancel)
                        })
                        issuerForm.callbackCancel = { Void -> Void in
                            ccf.navigationController!.dismiss(animated: true, completion: {})
                        }
                        
                    ccf.navigationController!.pushViewController(issuerForm, animated: false)
                } else {
                    self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: issuers[0], ccf: ccf, callback: callback, callbackCancel: callbackCancel)
                }
                }, failure: { (error) -> Void in
                    if let nav = ccf.navigationController {
                        nav.hideLoading()
                    }
                    
                    let errorVC = MPStepBuilder.startErrorViewController(MPSDKError.convertFrom(error), callback: { (Void) in
                        self.getIssuers(paymentMethod, cardToken: cardToken, ccf: ccf, callback: callback)
                        }, callbackCancel: {
                            ccf.navigationController?.dismiss(animated: true, completion: {})
                    })
                    ccf.navigationController?.present(errorVC, animated: true, completion: {})
            })
        } else {
            self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: customerCard?.getIssuer(), customerCard: customerCard, ccf: ccf, callback: callback, callbackCancel: callbackCancel)
        }
    }
    
    
    fileprivate class func createNewCardToken(_ cardToken : CardToken, paymentMethod : PaymentMethod, issuer : Issuer?, customerCard : CardInformation? = nil, ccf : MercadoPagoUIViewController,
                                              callback : @escaping (_ paymentMethod: PaymentMethod, _ token: Token, _ issuer:Issuer?) -> Void ,
                                              callbackCancel : ((Void) -> Void)? = nil){
        
        if cardToken.isCustomerPaymentMethod() {
            MPServicesBuilder.createToken(cardToken as! SavedCardToken, success: { (token) in
                if customerCard != nil && token!.lastFourDigits.isEmpty {
                    token!.lastFourDigits = customerCard!.getCardLastForDigits()
                }
                callback(paymentMethod, token!, issuer)
                }, failure: { (error) in
                    let errorVC = MPStepBuilder.startErrorViewController(MPSDKError.convertFrom(error), callback: { (Void) in
                        ccf.dismiss(animated: true, completion: {})
                        self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: issuer, ccf : ccf, callback: callback, callbackCancel: callbackCancel)
                    })
                    errorVC.callbackCancel = { ccf.hideLoading() }
                    ccf.navigationController?.present(errorVC, animated: true, completion: {})
            })
        } else {
            MPServicesBuilder.createNewCardToken(cardToken, success: {
                (token) -> Void in
                callback(paymentMethod, token!, issuer!)
                
                //ccf.hideLoading()
            }) { (error) -> Void in
                let errorVC = MPStepBuilder.startErrorViewController(MPSDKError.convertFrom(error), callback: { (Void) in
                    ccf.dismiss(animated: true, completion: {})
                    self.createNewCardToken(cardToken, paymentMethod: paymentMethod, issuer: issuer, ccf : ccf, callback: callback, callbackCancel: callbackCancel)
                })
                errorVC.callbackCancel = {
                    ccf.hideLoading()
                    if ( callbackCancel != nil ){
                        callbackCancel!()
                    }
                }
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
                let errorVC = MPStepBuilder.startErrorViewController(MPSDKError.convertFrom(error), callback: { (Void) in
                    ccf.navigationController!.popViewController(animated: true)
                    self.getInstallments(token, amount: amount, issuer: issuer, paymentTypeId: paymentTypeId, paymentMethod: paymentMethod, ccf: ccf, callback: callback)
                })
                ccf.navigationController!.present(errorVC, animated: true, completion: {})
        })
    }
}

