//
//  Utils.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 21/4/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    class func getDateFromString(string: String!) -> NSDate! {
        if string == nil {
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var dateArr = string.characters.split {$0 == "T"}.map(String.init)
        return dateFormatter.dateFromString(dateArr[0])
    }
    

    class func getAttributedAmount(formattedString : String, thousandSeparator: String, decimalSeparator: String, currencySymbol : String, color : UIColor = UIColor.whiteColor(), fontSize : CGFloat = 20, baselineOffset : Int = 7) -> NSAttributedString {
        let cents = getCentsFormatted(formattedString, decimalSeparator: decimalSeparator)
        let amount = getAmountFormatted(formattedString, thousandSeparator : thousandSeparator, decimalSeparator: decimalSeparator)

        let normalAttributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: fontSize)!,NSForegroundColorAttributeName: color]
        let smallAttributes : [String:AnyObject] = [NSFontAttributeName : UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 10)!,NSForegroundColorAttributeName: color, NSBaselineOffsetAttributeName : baselineOffset]

        let attributedSymbol = NSMutableAttributedString(string: currencySymbol + " ", attributes: smallAttributes)
        let attributedAmount = NSMutableAttributedString(string: amount, attributes: normalAttributes)
        let attributedCents = NSAttributedString(string: cents, attributes: smallAttributes)
        attributedSymbol.appendAttributedString(attributedAmount)
        attributedSymbol.appendAttributedString(attributedCents)
        return attributedSymbol
    }
    
    class func getAttributedAmount(amount : Double, thousandSeparator: String, decimalSeparator: String, currencySymbol : String, color : UIColor = UIColor.whiteColor(), fontSize : CGFloat = 20, baselineOffset : Int = 7) -> NSAttributedString {
        let cents = getCentsFormatted(String(amount), decimalSeparator: ".")
        let amount = getAmountFormatted(String(amount), thousandSeparator : thousandSeparator, decimalSeparator: ".")
        
        let normalAttributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: fontSize)!,NSForegroundColorAttributeName: color]
        let smallAttributes : [String:AnyObject] = [NSFontAttributeName : UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 10)!,NSForegroundColorAttributeName: color, NSBaselineOffsetAttributeName : baselineOffset]
        
        let attributedSymbol = NSMutableAttributedString(string: currencySymbol + " ", attributes: smallAttributes)
        let attributedAmount = NSMutableAttributedString(string: amount, attributes: normalAttributes)
        let attributedCents = NSAttributedString(string: cents, attributes: smallAttributes)
        attributedSymbol.appendAttributedString(attributedAmount)
        attributedSymbol.appendAttributedString(attributedCents)
        return attributedSymbol
    }
    
    class func getTransactionInstallmentsDescription(installments : String, installmentAmount : Double, additionalString : NSAttributedString) -> NSAttributedString {
        let mpTurquesaColor = UIColor(netHex: 0x3F9FDA)
        let mpLightGrayColor = UIColor(netHex: 0x999999)
        
        let descriptionAttributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 22)!,NSForegroundColorAttributeName:mpTurquesaColor]
        
        let totalAttributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 16)!,NSForegroundColorAttributeName:mpLightGrayColor]
        

        
        let stringToWrite = NSMutableAttributedString()
        
        stringToWrite.appendAttributedString(NSMutableAttributedString(string: installments + " de ".localized, attributes: descriptionAttributes))
        
        stringToWrite.appendAttributedString(Utils.getAttributedAmount(String(installmentAmount), thousandSeparator: ",", decimalSeparator: ".", currencySymbol: "$" , color:mpTurquesaColor))
        
        stringToWrite.appendAttributedString(additionalString)
        
        return stringToWrite
    }
    
    class func getCentsFormatted(formattedString : String, decimalSeparator : String) -> String {
        let range = formattedString.rangeOfString(decimalSeparator)
        var cents = ""
        if range != nil {
            let centsIndex = range!.startIndex.advancedBy(1)
            cents = formattedString.substringFromIndex(centsIndex)
        }

        if cents.isEmpty || cents.characters.count < 2 {
            var missingZeros = 2 - cents.characters.count
            while missingZeros > 0 {
                cents.appendContentsOf("0")
                missingZeros = missingZeros - 1
            }
        }
        return cents
    }
    
    
    class func getAmountFormatted(formattedString : String, thousandSeparator: String, decimalSeparator: String) -> String {
        
        if formattedString.containsString(thousandSeparator){
            return formattedString
        }
 
        let amount = self.getAmountDigits(formattedString, decimalSeparator : decimalSeparator)
        let length = amount.characters.count
        if length <= 3 {
            return amount
        }
        
        var finalAmountStr = ""
        
        var cantSeparators = length % 3 + (Int(length / 3))
        var separatorPosition = length % 3
        var initialPosition = amount.startIndex
        
        while cantSeparators > 0 && separatorPosition <= length {
            let range = initialPosition..<amount.startIndex.advancedBy(separatorPosition)
            finalAmountStr.appendContentsOf(amount.substringWithRange(range))
            finalAmountStr.appendContentsOf(String(thousandSeparator))
            cantSeparators = cantSeparators - 1
            initialPosition = amount.startIndex.advancedBy(separatorPosition)
            separatorPosition = separatorPosition + 3
        }

        return finalAmountStr.substringToIndex(finalAmountStr.startIndex.advancedBy(finalAmountStr.characters.count-1))
    }
    
    /**
     Extract only amount digits
     Ex: formattedString = "1000.00" with decimalSeparator = "."
     returns 1000
    **/
    class func getAmountDigits(formattedString : String, decimalSeparator : String) -> String {
        let range = formattedString.rangeOfString(decimalSeparator)
        if range != nil {
            return formattedString.substringToIndex(range!.startIndex)
        }
        return formattedString
    }

    static public func findPaymentMethodSearchItemInGroups(paymentMethodSearch : PaymentMethodSearch, paymentMethodId : String, paymentTypeId : PaymentTypeId) -> PaymentMethodSearchItem? {
        for item in paymentMethodSearch.groups {
            if let result = self.findPaymentMethodSearchItemById(item, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
                return result
            }
        }
        return nil
    }
    
    static private func findPaymentMethodSearchItemById(paymentMethodSearchItem : PaymentMethodSearchItem, paymentMethodId : String, paymentTypeId : PaymentTypeId) -> PaymentMethodSearchItem? {
        
        if paymentMethodSearchItem.idPaymentMethodSearchItem == paymentMethodId {
            return paymentMethodSearchItem
        } else if (paymentMethodSearchItem.idPaymentMethodSearchItem.startsWith(paymentMethodId) && paymentMethodSearchItem.idPaymentMethodSearchItem == paymentMethodId + "_" + paymentTypeId.rawValue) {
            return paymentMethodSearchItem
        }
        
        for item in paymentMethodSearchItem.children {
            if let paymentMethodSearchItemFound = findPaymentMethodSearchItemById(item, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
                return paymentMethodSearchItemFound
            }
        }
        
        if paymentMethodSearchItem.children.count == 0 {
            return nil
        }
        return nil
    }
    
    public static func findPaymentMethod(paymentMethods : [PaymentMethod], var paymentMethodId : String) -> PaymentMethod {
        var paymentTypeSelected = ""
        
        let paymentMethod = paymentMethods.filter({ (paymentMethod : PaymentMethod) -> Bool in
            let paymentMethodIdRange = paymentMethodId.rangeOfString(paymentMethod._id)
            if paymentMethodIdRange != nil {
                paymentTypeSelected = paymentMethodId.substringFromIndex(paymentMethodIdRange!.endIndex)
                if paymentTypeSelected.characters.count > 0 {
                    paymentTypeSelected.removeAtIndex(paymentTypeSelected.startIndex)
                }
                return true
            }
            return false
        })
        
        
        if paymentTypeSelected.characters.count > 0 {
            paymentMethod[0].paymentTypeId = PaymentTypeId(rawValue : paymentTypeSelected)
        }
        
        return paymentMethod[0]
    }
    
    public static func getAccreditationTitle(paymentMethod : PaymentMethod) -> String{
        if paymentMethod.accreditationTime == nil || !(paymentMethod.accreditationTime > 0) {
            return ""
        }
        
        var title = "Se acreditará en ".localized
        let hours = paymentMethod.accreditationTime!/(1000*60*60)
        if hours > 24 {
            title = title + String(hours/24) + " dias".localized
        } else {
            title = title + String(hours) + " horas".localized
        }
        return title
    }

}