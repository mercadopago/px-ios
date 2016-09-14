//
//  CardViewModelManager.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/8/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class CardViewModelManager: NSObject {

    
    var paymentMethods : [PaymentMethod]?
    var paymentMethod : PaymentMethod?
    var customerCard : CardInformation?
    var token : Token?
    var cardToken : CardToken?
    var paymentSettings : PaymentPreference?
    var amount : Double?
    
    let textMaskFormater = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX")
    let textEditMaskFormater = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces :false)
    
    var cvvEmpty: Bool = true
    var cardholderNameEmpty: Bool = true
    
    init(amount : Double, paymentMethods : [PaymentMethod]?, paymentMethod : PaymentMethod? = nil, customerCard : CardInformation? = nil, token : Token? = nil, paymentSettings : PaymentPreference?){
        self.amount = amount
        self.paymentMethods = paymentMethods
        self.paymentMethod = paymentMethod
        self.customerCard = customerCard
        self.token = token
        self.paymentSettings = paymentSettings
    }
    
    
    func cvvLenght() -> Int{
        var lenght : Int
        
        if self.customerCard != nil {
            lenght = (self.customerCard?.getCardSecurityCode().length)!
        } else {
            if ((paymentMethod?.settings == nil)||(paymentMethod?.settings.count == 0)){
                lenght = 3 // Default
            }else{
                lenght = (paymentMethod?.settings[0].securityCode.length)!
            }
        }
        return lenght
    }
 
    func getLabelTextColor() -> UIColor {
        return (self.paymentMethod == nil) ? MPLabel.defaultColorText : MercadoPago.getFontColorFor(self.paymentMethod!)!
    }

    func getEditingLabelColor() -> UIColor {
        return (self.paymentMethod == nil) ? MPLabel.highlightedColorText : MercadoPago.getEditingFontColorFor(self.paymentMethod!)!
    }
    
    func getExpirationMonthFromLabel(expirationDateLabel : MPLabel)->Int {
        return Utils.getExpirationMonthFromLabelText(expirationDateLabel.text!)
    }

    func getExpirationYearFromLabel(expirationDateLabel : MPLabel)->Int {
        return Utils.getExpirationYearFromLabelText(expirationDateLabel.text!)
    }
    
    func getBIN(cardNumber : String) -> String?{
        if (token != nil){
            return token?.firstSixDigit
        }
        
        var trimmedNumber = cardNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
        trimmedNumber = trimmedNumber.stringByReplacingOccurrencesOfString(String(textMaskFormater.emptyMaskElement), withString: "")
        
        
        if (trimmedNumber.characters.count < 6){
            return nil
        }else{
            let bin = trimmedNumber.substringToIndex((trimmedNumber.startIndex.advancedBy(6)))
            return bin
        }
    }
    
    /*TODO : VER QUE ONDA, PORQUE DOS VALID CVV?? **/
    func isValidInputCVV(text : String) -> Bool{
        if( text.characters.count > self.cvvLenght() ){
            return false
        }
        let num = Int(text)
        return (num != nil)
    }
    
    func validateCardNumber(cardNumberLabel : UILabel, expirationDateLabel : MPLabel, cvvLabel : UILabel, cardholderNameLabel : MPLabel) -> Bool{
        
        if(self.paymentMethod == nil){
            return false
        }
        
        self.tokenHidratate(cardNumberLabel.text!, expirationDate: expirationDateLabel.text!, cvv: cvvLabel.text!, cardholderName: cardholderNameLabel.text!)
        
        let errorMethod = self.cardToken!.validateCardNumber(self.paymentMethod!)
        if((errorMethod) != nil){
            return false
        }
        return true
    }
    
    func validateCardholderName(cardNumberLabel : UILabel, expirationDateLabel : MPLabel, cvvLabel : UILabel, cardholderNameLabel : MPLabel) -> Bool{
        
        self.tokenHidratate(cardNumberLabel.text!, expirationDate: expirationDateLabel.text!, cvv: cvvLabel.text!, cardholderName: cardholderNameLabel.text!)
        
        if ( self.cardToken!.validateCardholderName() != nil ){
            return false
        }
        return true
    }
    
    func validateCvv(cardNumberLabel : UILabel, expirationDateLabel : MPLabel, cvvLabel : UILabel, cardholderNameLabel : MPLabel) -> Bool{
        
        self.tokenHidratate(cardNumberLabel.text!, expirationDate: expirationDateLabel.text!, cvv: cvvLabel.text!, cardholderName: cardholderNameLabel.text!)
        
        if (cvvLabel.text!.stringByReplacingOccurrencesOfString("•", withString: "").characters.count < self.paymentMethod?.secCodeLenght()){
            return false
        }
        let errorMethod = self.cardToken!.validateSecurityCode()
        if((errorMethod) != nil){
            return false
        }
        return true
    }
    
    func validateExpirationDate(cardNumberLabel : UILabel, expirationDateLabel : MPLabel, cvvLabel : UILabel, cardholderNameLabel : MPLabel) -> Bool{
        
        self.tokenHidratate(cardNumberLabel.text!, expirationDate: expirationDateLabel.text!, cvv: cvvLabel.text!, cardholderName: cardholderNameLabel.text!)
        let errorMethod = self.cardToken!.validateExpiryDate()
        if((errorMethod) != nil){
            return false
        }
        return true
    }
    
    /*TODO : deberia validarse esto acá???*/
    func isAmexCard(cardNumber : String) -> Bool{
        if(self.getBIN(cardNumber) == nil){
            return false
        }
        if(self.paymentMethod != nil){
            return self.paymentMethod!.isAmex()
        }else{
            return false
        }
    }
    
    func matchedPaymentMethod (cardNumber : String) -> PaymentMethod? {
        if self.paymentMethod != nil {
            return self.paymentMethod
        }
        if(self.paymentMethods == nil){
            return nil
        }
        if(getBIN(cardNumber) == nil){
            return nil
        }
        
        
        for (_, value) in self.paymentMethods!.enumerate() {
            
            if (value.conformsPaymentPreferences(self.paymentSettings)){
                if (value.conformsToBIN(getBIN(cardNumber)!)){
                    return value.cloneWithBIN(getBIN(cardNumber)!)
                }
            }
            
        }
        return nil
    }
    
    
    func tokenHidratate(cardNumber : String, expirationDate : String, cvv : String, cardholderName : String) {
        let number = cardNumber
        let year = Utils.getExpirationYearFromLabelText(expirationDate)
        let month = Utils.getExpirationMonthFromLabelText(expirationDate)
        let secCode = cvvEmpty ? "" :cvv
        let name = cardholderNameEmpty ? "" : cardholderName
        
        self.cardToken = CardToken(cardNumber: number, expirationMonth: month, expirationYear: year, securityCode: secCode, cardholderName: name, docType: "", docNumber: "")
    }
    
    func buildSavedCardToken(cvv : String) -> CardToken {
        let securityCode = self.customerCard!.isSecurityCodeRequired() ? cvv : ""
        self.cardToken = SavedCardToken(card: self.customerCard!, securityCode: securityCode, securityCodeRequired: self.customerCard!.isSecurityCodeRequired())
        return self.cardToken!
    }

    
    
}
