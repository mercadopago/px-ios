//
//  NextStepHelper.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 2/3/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

extension MercadoPagoCheckoutViewModel {
    
    func needSearch() -> Bool {
        return search == nil
    }
    func isPaymentTypeSelected() -> Bool {
        
        if self.paymentData.isComplete() && (self.search != nil){
            if self.paymentOptionSelected == nil {
                self.setPaymentOptionSelected()
            }
            return true
        }
        
        guard let selectedType = self.paymentOptionSelected else {
                return false
        }
        return !selectedType.hasChildren()
    }
    func needCompleteCard() -> Bool {
        guard let selectedType = self.paymentOptionSelected else {
            return false
        }
        if selectedType.isCustomerPaymentMethod(){
            return false
        }
        if !selectedType.isCard() {
            return false
        }
        return self.cardToken == nil && self.paymentData.paymentMethod == nil
    }
    
    func showConfirm() -> Bool {
        return self.paymentData.isComplete()
    }
    
    func showCongrats() -> Bool {
        return self.payment != nil
    }
    func needGetIdentification() -> Bool {
        guard let pm = self.paymentData.paymentMethod , let option = self.paymentOptionSelected else {
            return false
        }
        guard let holder = self.cardToken?.cardholder else {
            return false
        }
        if let identification = holder.identification{
            if String.isNullOrEmpty(identification.number) && pm.isIdentificationRequired() && !option.isCustomerPaymentMethod(){
                return true
            }
        }
        return false
    
    }
    func needGetIssuers() -> Bool {
        guard let selectedType = self.paymentOptionSelected else {
            return false
        }
        guard let pm = self.paymentData.paymentMethod else {
            return false
        }
        if selectedType.isCustomerPaymentMethod(){
            return false
        }
        if paymentData.issuer == nil  && pm.isCard() && Array.isNullOrEmpty(issuers) {
            return true
        }
        return false
    }
    
    func needIssuerSelectionScreen() -> Bool {
        guard let selectedType = self.paymentOptionSelected else {
            return false
        }
        guard let pm = self.paymentData.paymentMethod else {
            return false
        }
        if selectedType.isCustomerPaymentMethod(){
            return false
        }
        if paymentData.issuer == nil  && pm.isCard() && !Array.isNullOrEmpty(issuers) {
            return true
        }
        return false
    }
    
    func needSelectCreditDebit() -> Bool {
        if self.paymentMethods != nil && self.paymentMethods?.count == 2 {//&&
            //((self.paymentMethods![0].paymentTypeId == PaymentTypeId.CREDIT_CARD && self.paymentMethods![1].paymentTypeId == PaymentTypeId.CREDIT_CARD) ||
            //    (self.paymentMethods![1].paymentTypeId == PaymentTypeId.CREDIT_CARD && self.paymentMethods![0].paymentTypeId == PaymentTypeId.CREDIT_CARD))) {
            return true
        }
        return false
    }
    
    func needChosePayerCost() -> Bool {
        guard let pm = self.paymentData.paymentMethod else {
            return false
        }
        if pm.isCreditCard() && self.paymentData.payerCost == nil && installment == nil {
            return true
        }
        return false
    }
    
    func needPayerCostSelectionScreen() -> Bool {
        guard let pm = self.paymentData.paymentMethod else {
            return false
        }
        if pm.isCreditCard() && self.paymentData.payerCost == nil && installment != nil {
            return true
        }
        return false
    }
    
    func needSecurityCode() -> Bool {
        guard let pmSelected = self.paymentOptionSelected else {
            return false
        }
        if pmSelected.isCustomerPaymentMethod() && self.paymentData.token == nil && pmSelected.getId() != PaymentTypeId.ACCOUNT_MONEY.rawValue {
            return true
        }
        return false
    }

    func needCreateToken() -> Bool {
        
        guard let pm = self.paymentData.paymentMethod else {
            return false
        }
        return self.paymentData.token == nil && pm.isCard()
    }
    
    func needReviewAndConfirm() -> Bool {
        
        guard let _ = self.paymentOptionSelected else {
            return false
        }
        
        if paymentData.isComplete() {
            return MercadoPagoCheckoutViewModel.flowPreference.isReviewAndConfirmScreenEnable()
        }
        
        return false
    }
    
    func shouldShowCongrats() -> Bool {
        if (self.payment != nil || self.paymentResult != nil) {
            self.setIsCheckoutComplete(isCheckoutComplete: true)
            return true
        }
        return false
    }
    
    func shouldExitCheckout() -> Bool {
        return self.isCheckoutComplete()
    }
    
    func setPaymentOptionSelected(){
        if self.paymentData.hasCustomerPaymentOption() {
            // Account_money o customer cards
            let customOption = Utils.findCardInformationIn(customOptions: self.customPaymentOptions!, paymentData: self.paymentData)
            self.paymentOptionSelected = customOption as? PaymentMethodOption
        } else if !self.paymentData.paymentMethod.isOnlinePaymentMethod() {
            // Medios off
            if let paymentTypeId = PaymentTypeId(rawValue : paymentData.paymentMethod.paymentTypeId) {
                self.paymentOptionSelected = Utils.findPaymentMethodSearchItemInGroups(self.search!, paymentMethodId: paymentData.paymentMethod._id, paymentTypeId: paymentTypeId)
            }
        } else {
            // Tarjetas, efectivo, crédito, debito
            if let paymentTypeId = PaymentTypeId(rawValue : paymentData.paymentMethod.paymentTypeId) {
                self.paymentOptionSelected = Utils.findPaymentMethodTypeId(self.search!.groups, paymentTypeId: paymentTypeId)
            }
        }
    }
}
