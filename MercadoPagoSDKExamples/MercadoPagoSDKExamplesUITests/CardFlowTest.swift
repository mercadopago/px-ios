//
//  CardFlowTest.swift
//  MercadoPagoSDKExamples
//
//  Created by Maria cristina rodriguez on 11/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class CardFlowTest: MercadoPagoUITest {
        
    
    func testCardForm() {
 
        let tablesQuery = application.tables
        tablesQuery.staticTexts["Components de UI"].tap()
        tablesQuery.staticTexts["Cobra con tarjeta con cuotas"].tap()
         
    }
    
    
}
