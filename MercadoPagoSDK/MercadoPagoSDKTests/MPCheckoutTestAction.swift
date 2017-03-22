//
//  TestAction.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 3/13/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class MPCheckoutTestAction: NSObject {

    
    static func loadGroupsInViewModel(mpCheckout : MercadoPagoCheckout) {
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckoutViewModel : mpCheckout.viewModel)
    }
    
    static func selectAccountMoney(mpCheckout : MercadoPagoCheckout){
        MPCheckoutTestAction.selectAccountMoney(mpCheckoutViewModel: mpCheckout.viewModel)
    }
    
    static func selectCreditCardOption(mpCheckout : MercadoPagoCheckout){
        MPCheckoutTestAction.selectCreditCardOption(mpCheckoutViewModel : mpCheckout.viewModel)
    }
    
    static func selectCustomerCardOption(mpCheckout : MercadoPagoCheckout){
        MPCheckoutTestAction.selectCustomerCardOption(mpCheckoutViewModel: mpCheckout.viewModel)
    }
    
    static func selectAccountMoney(mpCheckoutViewModel : MercadoPagoCheckoutViewModel){
        let accountMoneyOption = MockBuilder.buildCustomerPaymentMethod("account_money", paymentMethodId : "account_money")
        mpCheckoutViewModel.updateCheckoutModel(paymentOptionSelected: accountMoneyOption as! PaymentMethodOption)
    }
    
    static func selectCreditCardOption(mpCheckoutViewModel : MercadoPagoCheckoutViewModel){
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        mpCheckoutViewModel.paymentOptionSelected = creditCardOption
    }
    
    static func selectCustomerCardOption(mpCheckoutViewModel : MercadoPagoCheckoutViewModel){
        let customerCardOption = MockBuilder.buildCustomerPaymentMethod("customerCardId", paymentMethodId: "visa")
        mpCheckoutViewModel.updateCheckoutModel(paymentOptionSelected: customerCardOption as! PaymentMethodOption)
    }
    
    static func loadGroupsInViewModel(mpCheckoutViewModel : MercadoPagoCheckoutViewModel) {
        
        let accountMoneyOption = MockBuilder.buildCustomerPaymentMethod("account_money", paymentMethodId : "account_money")
        let customerCardOption = MockBuilder.buildCustomerPaymentMethod("customerCardId", paymentMethodId: "visa")
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        let paymentMethodVisa = MockBuilder.buildPaymentMethod("visa")
        let paymentMethodAM = MockBuilder.buildPaymentMethod("account_money", paymentTypeId: "account_money")
        
        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups : [creditCardOption], paymentMethods : [paymentMethodVisa, paymentMethodAM], customOptions : [customerCardOption, accountMoneyOption])
        mpCheckoutViewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchMock)
    }
    
}
