//
//  CardFormActions.swift
//  MercadoPagoSDKExamples
//
//  Created by Maria cristina rodriguez on 11/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class CardFormActions: MPTestActions {

    static private func fillCreditCardForm( binNumber : String = "450995" , additionalNumbers : String = "3566233704", identificationName : String = "APRO"  ){
        
        
        
        application.textFields["Número de tarjeta"].tap()
        let cardNumberField = application.textFields["Número de tarjeta"]
        cardNumberField.typeText(binNumber)
        
        let continuarButton = application.navigationBars.buttons["Continuar"]
        continuarButton.tap()
        cardNumberField.typeText(additionalNumbers)
        continuarButton.tap()
        let cardholderNameField = application.textFields["Nombre y apellido"]
        cardholderNameField.typeText(identificationName)
        continuarButton.tap()
        
        let expirationDateField = application.textFields["Fecha de expiración"]
        expirationDateField.typeText("1122")
        continuarButton.tap()
        
        let securityCodeField = application.textFields["Código de seguridad"]
        securityCodeField.typeText("123")
        continuarButton.tap()
        
        let identificationNumberField = application.textFields["Número"]
        identificationNumberField.typeText("12123123")
        
        continuarButton.pressForDuration(0.2);
        XCUIApplication().tables.staticTexts["3 de $ 397 29 ( $ 1.191 89 ) "].pressForDuration(1.3);

    }
    
    
    static func fillVISA() {
        
    }
}
