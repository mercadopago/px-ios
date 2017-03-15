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
        let accountMoneyOption = MockBuilder.buildCustomerPaymentMethod("account_money", paymentMethodId : "account_money")
        let customerCardOption = MockBuilder.buildCustomerPaymentMethod("customerCardId", paymentMethodId: "visa")
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        let paymentMethodVisa = MockBuilder.buildPaymentMethod("visa")
        let paymentMethodAM = MockBuilder.buildPaymentMethod("account_money", paymentTypeId: "account_money")
        
        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups : [creditCardOption], paymentMethods : [paymentMethodVisa, paymentMethodAM], customOptions : [customerCardOption, accountMoneyOption])
        mpCheckout.viewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchMock)
    }
    
    static func selectAccountMoney(mpCheckout : MercadoPagoCheckout){
        let accountMoneyOption = MockBuilder.buildCustomerPaymentMethod("account_money", paymentMethodId : "account_money")
        mpCheckout.viewModel.updateCheckoutModel(paymentOptionSelected: accountMoneyOption as! PaymentMethodOption)
    }
    
    static func selectCreditCardOption(mpCheckout : MercadoPagoCheckout){
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        mpCheckout.viewModel.paymentOptionSelected = creditCardOption
    }
    
    static func selectCustomerCardOption(mpCheckout : MercadoPagoCheckout){
        let customerCardOption = MockBuilder.buildCustomerPaymentMethod("customerCardId", paymentMethodId: "visa")
        mpCheckout.viewModel.updateCheckoutModel(paymentOptionSelected: customerCardOption as! PaymentMethodOption)
    }
    
}
