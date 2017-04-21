//
//  MPPaymentTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/26/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import XCTest

class MPPaymentTest: BaseTest {

    var mpPayment : MPPayment?
    var transactionDetails : TransactionDetails?
    var payer : Payer?
    var financialInstitution : FinancialInstitution?

    func testToJSON() {
        self.financialInstitution = FinancialInstitution()
        self.financialInstitution?._id = 1050
        self.financialInstitution?._description = "FIdescription"
        self.transactionDetails = TransactionDetails(financialInstitution: self.financialInstitution)
        
        self.payer = Payer(_id: "id", email: "email", type: "type", identification: nil, entityType: nil)
        
        self.mpPayment = MPPayment(preferenceId: "prefId", publicKey: "pk", paymentMethodId: "pmId", transactionDetails: self.transactionDetails!, payer: self.payer!)
        var jsonResult = mpPayment!.toJSON()
    
        XCTAssertEqual(jsonResult["pref_id"] as? String, "prefId")
        XCTAssertEqual(jsonResult["public_key"] as? String, "pk")
        XCTAssertEqual(jsonResult["payment_method_id"] as? String, "pmId")
        
        var TDs = jsonResult["transaction_details"] as? NSDictionary
        XCTAssertNotNil(TDs)
        XCTAssertEqual(TDs?["financial_institution"] as? String, String(describing: self.financialInstitution!._id!))
        var payer = jsonResult["payer"] as? NSDictionary
        XCTAssertNotNil(payer)
        XCTAssertEqual(payer?["id"] as? String, "id")
        XCTAssertEqual(payer?["email"] as? String, "email")
    
        
        self.mpPayment = MPPayment(preferenceId: "prefId", publicKey: "pk_test", paymentMethodId: "pmId", installments: 3, issuerId: "issuerId", tokenId: "123", transactionDetails: self.transactionDetails!, payer: self.payer!)
        jsonResult = self.mpPayment!.toJSON()
    
        XCTAssertEqual(jsonResult["pref_id"] as? String, "prefId")
        XCTAssertEqual(jsonResult["public_key"] as? String, "pk_test")
        XCTAssertEqual(jsonResult["payment_method_id"] as? String, "pmId")
        XCTAssertEqual(jsonResult["installments"] as? Int, 3)
        XCTAssertEqual(jsonResult["issuer_id"] as? String, "issuerId")
        XCTAssertEqual(jsonResult["token"] as? String, "123")
        
        TDs = jsonResult["transaction_details"] as? NSDictionary
        XCTAssertNotNil(TDs)
        XCTAssertEqual(TDs?["financial_institution"] as? String, String(describing: self.financialInstitution!._id!))
        payer = jsonResult["payer"] as? NSDictionary
        XCTAssertNotNil(payer)
        XCTAssertEqual(payer?["id"] as? String, "id")
        XCTAssertEqual(payer?["email"] as? String, "email")

    }
}


class CustomerPaymentTest: BaseTest {

    var customerPayment : CustomerPayment?
    var transactionDetails : TransactionDetails?
    var payer : Payer?
    var financialInstitution : FinancialInstitution?
    
    func testToJSON() {
        self.financialInstitution = FinancialInstitution()
        self.financialInstitution?._id = 1050
        self.financialInstitution?._description = "FIdescription"
        self.transactionDetails = TransactionDetails(financialInstitution: self.financialInstitution)
        self.payer = Payer(_id: "id", email: "email", type: "type", identification: nil, entityType: nil)
        
        self.customerPayment = CustomerPayment(preferenceId: "prefId", publicKey: "pk_test", paymentMethodId: "pmId", customerId: "customerId", transactionDetails: self.transactionDetails!, payer: self.payer!)
        var customerPaymentResult = self.customerPayment!.toJSON()

        XCTAssertEqual(customerPaymentResult["pref_id"] as? String, "prefId")
        XCTAssertEqual(customerPaymentResult["public_key"] as? String, "pk_test")
        XCTAssertEqual(customerPaymentResult["payment_method_id"] as? String, "pmId")
        XCTAssertEqual(customerPaymentResult["installments"] as? Int, 0)
        XCTAssertNil(customerPaymentResult["issuerId"] as? String, "issuerId")
        XCTAssertNil(customerPaymentResult["tokenId"] as? String, "123")
        
        var TDs = customerPaymentResult["transaction_details"] as? NSDictionary
        XCTAssertNotNil(TDs)
        XCTAssertEqual(TDs?["financial_institution"] as? String, String(describing: self.financialInstitution!._id!))
        var payer = customerPaymentResult["payer"] as? NSDictionary
        XCTAssertNotNil(payer)
        XCTAssertEqual(payer?["id"] as? String, "customerId")
        XCTAssertEqual(payer?["email"] as? String, "email")

        
        self.customerPayment = CustomerPayment(preferenceId: "prefId", publicKey: "", paymentMethodId: "pmId", installments : 3, issuerId : "issuerId", tokenId : "123", customerId : "111", transactionDetails: self.transactionDetails!, payer: self.payer!)
        customerPaymentResult = self.customerPayment!.toJSON()
        
        XCTAssertEqual(customerPaymentResult["pref_id"] as? String, "prefId")
        XCTAssertEqual(customerPaymentResult["public_key"] as? String, "")
        XCTAssertEqual(customerPaymentResult["payment_method_id"] as? String, "pmId")
        XCTAssertEqual(customerPaymentResult["installments"] as? Int, 3)
        XCTAssertEqual(customerPaymentResult["issuer_id"] as? String, "issuerId")
        XCTAssertEqual(customerPaymentResult["token"] as? String, "123")
        
        TDs = customerPaymentResult["transaction_details"] as? NSDictionary
        XCTAssertNotNil(TDs)
        XCTAssertEqual(TDs?["financial_institution"] as? String, String(describing: self.financialInstitution!._id!))
        payer = customerPaymentResult["payer"] as? NSDictionary
        XCTAssertNotNil(payer)
        XCTAssertEqual(payer?["id"] as? String, "111")
        XCTAssertEqual(payer?["email"] as? String, "email")

    }
    
}

class BlacklabelPaymentTest: BaseTest {
    
    var blacklabelPayment : BlacklabelPayment?
    var transactionDetails : TransactionDetails?
    var payer : Payer?
    var financialInstitution : FinancialInstitution?
    
    func testToJSON(){
        self.financialInstitution = FinancialInstitution()
        self.financialInstitution?._id = 1050
        self.financialInstitution?._description = "FIdescription"
        self.transactionDetails = TransactionDetails(financialInstitution: self.financialInstitution)
        self.payer = Payer(_id: "id", email: "email", type: "type", identification: nil, entityType: nil)
        
        MercadoPagoContext.setPayerAccessToken("payerAccessToken")
        self.blacklabelPayment = BlacklabelPayment(preferenceId: "prefId", publicKey: "pk_test", paymentMethodId: "pmId", installments : 2, issuerId : "310", tokenId : "tokenId", transactionDetails: self.transactionDetails!, payer: self.payer!)
        let jsonResult = self.blacklabelPayment!.toJSON()
        
        XCTAssertEqual(jsonResult["pref_id"] as? String, "prefId")
        XCTAssertEqual(jsonResult["public_key"] as? String, "pk_test")
        XCTAssertEqual(jsonResult["payment_method_id"] as? String, "pmId")
        XCTAssertEqual(jsonResult["installments"] as? Int, 2)
        XCTAssertEqual(jsonResult["issuer_id"] as? String, "310")
        XCTAssertEqual(jsonResult["token"] as? String, "tokenId")
        let TDs = jsonResult["transaction_details"] as? NSDictionary
        XCTAssertNotNil(TDs)
        XCTAssertEqual(TDs?["financial_institution"] as? String, String(describing: self.financialInstitution!._id!))
        let payer = jsonResult["payer"] as? NSDictionary
        XCTAssertNotNil(payer)
        XCTAssertEqual(payer?["id"] as? String, "id")
        XCTAssertEqual(payer?["email"] as? String, "email")
        XCTAssertEqual(payer?["access_token"] as? String, "payerAccessToken")
        
    }
    
}

class MPPaymentFactoryTest: BaseTest {
    
    var transactionDetails : TransactionDetails?
    var payer : Payer?
    var financialInstitution : FinancialInstitution?
    
    func testCreateMPPayment(){
        self.financialInstitution = FinancialInstitution()
        self.financialInstitution?._id = 1050
        self.financialInstitution?._description = "FIdescription"
        self.transactionDetails = TransactionDetails(financialInstitution: self.financialInstitution)
        self.payer = Payer(_id: "id", email: "email", type: "type", identification: nil, entityType: nil)
        
        let regularPayment = MPPaymentFactory.createMPPayment(preferenceId: "prefId", publicKey: "pk", paymentMethodId: "rapipago", isBlacklabelPayment : false, transactionDetails: self.transactionDetails!, payer: self.payer!)
        
        XCTAssertEqual(String(describing: regularPayment.classForCoder), String(describing: MPPayment.classForCoder()))
        
        let blacklabelPayment = MPPaymentFactory.createMPPayment(preferenceId: "prefId", publicKey: "pk", paymentMethodId: "master", isBlacklabelPayment : true, transactionDetails: self.transactionDetails!, payer: self.payer!)
        
        XCTAssertEqual(String(describing: blacklabelPayment.classForCoder), String(describing:BlacklabelPayment.classForCoder()))
        
        let customerPayment = MPPaymentFactory.createMPPayment(preferenceId: "prefId", publicKey: "pk", paymentMethodId: "visa", customerId : "customerId", isBlacklabelPayment : false, transactionDetails: self.transactionDetails!, payer: self.payer!)
        
        XCTAssertEqual(String(describing: customerPayment.classForCoder), String(describing: CustomerPayment.classForCoder()))

    }
}

