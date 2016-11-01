//
//  Utils.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 21/4/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Utils {
    class func getDateFromString(_ string: String!) -> Date! {
        if string == nil {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var dateArr = string.characters.split {$0 == "T"}.map(String.init)
        return dateFormatter.date(from: dateArr[0])
    }
    
    class func getStringFromDate(_ date: Date!) -> String! {
        
        if date == nil {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

    class func getAttributedAmount(_ formattedString : String, thousandSeparator: String, decimalSeparator: String, currencySymbol : String, color : UIColor = UIColor.white(), fontSize : CGFloat = 20, baselineOffset : Int = 7) -> NSAttributedString {
        let cents = getCentsFormatted(formattedString, decimalSeparator: decimalSeparator)
        let amount = getAmountFormatted(formattedString, thousandSeparator : thousandSeparator, decimalSeparator: decimalSeparator)


        let normalAttributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),NSForegroundColorAttributeName: color]
        let smallAttributes : [String:AnyObject] = [NSFontAttributeName : UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 10) ?? UIFont.systemFont(ofSize: 10),NSForegroundColorAttributeName: color, NSBaselineOffsetAttributeName : baselineOffset as AnyObject]


        let attributedSymbol = NSMutableAttributedString(string: currencySymbol + " ", attributes: smallAttributes)
        let attributedAmount = NSMutableAttributedString(string: amount, attributes: normalAttributes)
        let attributedCents = NSAttributedString(string: cents, attributes: smallAttributes)
        let space = NSAttributedString(string: " ", attributes: smallAttributes)
        attributedSymbol.append(attributedAmount)
        attributedSymbol.append(space)
        attributedSymbol.append(attributedCents)
        return attributedSymbol
    }
    
    
    class func getAttributedAmount(_ amount : Double, thousandSeparator: String, decimalSeparator: String, currencySymbol : String, color : UIColor = UIColor.white(), fontSize : CGFloat = 20, baselineOffset : Int = 7) -> NSAttributedString {
        let cents = getCentsFormatted(String(amount), decimalSeparator: ".")
        let amount = getAmountFormatted(String(amount), thousandSeparator : thousandSeparator, decimalSeparator: ".")
        

        let normalAttributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),NSForegroundColorAttributeName: color]
        let smallAttributes : [String:AnyObject] = [NSFontAttributeName : UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 10) ?? UIFont.systemFont(ofSize: 10),NSForegroundColorAttributeName: color, NSBaselineOffsetAttributeName : baselineOffset as AnyObject]

        
        let attributedSymbol = NSMutableAttributedString(string: currencySymbol + " ", attributes: smallAttributes)
        let attributedAmount = NSMutableAttributedString(string: amount, attributes: normalAttributes)
        let attributedCents = NSAttributedString(string: cents, attributes: smallAttributes)
        let space = NSAttributedString(string: " ", attributes: smallAttributes)
        attributedSymbol.append(attributedAmount)
        attributedSymbol.append(space)
        attributedSymbol.append(attributedCents)
        return attributedSymbol
    }
    
    class func getTransactionInstallmentsDescription(_ installments : String, installmentAmount : Double, additionalString : NSAttributedString) -> NSAttributedString {
        let mpTurquesaColor = UIColor(netHex: 0x3F9FDA)
        
        let descriptionAttributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 22) ?? UIFont.systemFont(ofSize: 22),NSForegroundColorAttributeName:mpTurquesaColor]
        
        let stringToWrite = NSMutableAttributedString()
        
        stringToWrite.append(NSMutableAttributedString(string: installments + " de ".localized, attributes: descriptionAttributes))
        
        stringToWrite.append(Utils.getAttributedAmount(installmentAmount, thousandSeparator: ".", decimalSeparator: ",", currencySymbol: "$" , color:mpTurquesaColor))
        
        stringToWrite.append(additionalString)
        
        return stringToWrite
    }
    
    /**
     Returns cents string formatted
     Ex: formattedString = "100.2", decimalSeparator = "."
     returns 20
     **/
    class func getCentsFormatted(_ formattedString : String, decimalSeparator : String) -> String {
        let range = formattedString.range(of: decimalSeparator)
        var cents = ""
        if range != nil {
            let centsIndex = formattedString.index(range!.lowerBound, offsetBy: 1)
            cents = formattedString.substring(from: centsIndex)
        }

        if cents.isEmpty || cents.characters.count < 2 {
            var missingZeros = 2 - cents.characters.count
            while missingZeros > 0 {
                cents.append("0")
                missingZeros = missingZeros - 1
            }
        }
        return cents
    }
    
    /**
     Returns amount string formatted according to separators
     Ex: formattedString = "10200.90", decimalSeparator = ".", thousandSeparator: ","
     returns 10,200.90
     **/
    class func getAmountFormatted(_ formattedString : String, thousandSeparator: String, decimalSeparator: String) -> String {
 
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
            let range = initialPosition..<amount.characters.index(amount.startIndex, offsetBy: separatorPosition)
            finalAmountStr.append(amount.substring(with: range))
            finalAmountStr.append(String(thousandSeparator))
            cantSeparators = cantSeparators - 1
            initialPosition = amount.characters.index(amount.startIndex, offsetBy: separatorPosition)
            separatorPosition = separatorPosition + 3
        }

        return finalAmountStr.substring(to: finalAmountStr.characters.index(finalAmountStr.startIndex, offsetBy: finalAmountStr.characters.count-1))
    }
    
    /**
     Extract only amount digits
     Ex: formattedString = "1000.00" with decimalSeparator = "."
     returns 1000
    **/
    class func getAmountDigits(_ formattedString : String, decimalSeparator : String) -> String {
        let range = formattedString.range(of: decimalSeparator)
        if range != nil {
            return formattedString.substring(to: range!.lowerBound)
        }
        return formattedString
    }

    static internal func findPaymentMethodSearchItemInGroups(_ paymentMethodSearch : PaymentMethodSearch, paymentMethodId : String, paymentTypeId : PaymentTypeId?) -> PaymentMethodSearchItem? {
        
        if let result = Utils.findPaymentMethodSearchItemById(paymentMethodSearch.groups, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
            return result
        }
        return nil
    }
    
    static fileprivate func findPaymentMethodSearchItemById(_ paymentMethodSearchList : [PaymentMethodSearchItem], paymentMethodId : String, paymentTypeId : PaymentTypeId?) -> PaymentMethodSearchItem? {
       
        var filterPaymentMethodSearchFound = paymentMethodSearchList.filter { (arg : PaymentMethodSearchItem) -> Bool in
            arg.idPaymentMethodSearchItem == paymentMethodId
        }
        
        if filterPaymentMethodSearchFound.count > 0 {
            return filterPaymentMethodSearchFound[0]
        } else if paymentTypeId != nil {
            filterPaymentMethodSearchFound = paymentMethodSearchList.filter { (arg : PaymentMethodSearchItem) -> Bool in
                arg.idPaymentMethodSearchItem == paymentMethodId + "_" + paymentTypeId!.rawValue
            }
            
            if filterPaymentMethodSearchFound.count > 0 {
                return filterPaymentMethodSearchFound[0]
            }
        } else {
            filterPaymentMethodSearchFound = paymentMethodSearchList.filter { (arg : PaymentMethodSearchItem) -> Bool in
                arg.idPaymentMethodSearchItem.startsWith(paymentMethodId)
            }
            if filterPaymentMethodSearchFound.count > 0 {
                return filterPaymentMethodSearchFound[0]
            }
        }
        
        for item in paymentMethodSearchList {
            if let paymentMethodSearchItemFound = findPaymentMethodSearchItemById(item.children, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
                return paymentMethodSearchItemFound
            }
        }
        
        if paymentMethodSearchList.count == 0 {
            return nil
        }
        return nil
    }
    
    internal static func findPaymentMethod(_ paymentMethods : [PaymentMethod], paymentMethodId : String) -> PaymentMethod {
        var paymentTypeSelected = ""
        
        let paymentMethod = paymentMethods.filter({ (paymentMethod : PaymentMethod) -> Bool in
            let paymentMethodIdRange = paymentMethodId.range(of: paymentMethod._id)
            if paymentMethodIdRange != nil {
                paymentTypeSelected = paymentMethodId.substring(from: paymentMethodIdRange!.upperBound)
                if paymentTypeSelected.characters.count > 0 {
                    paymentTypeSelected.remove(at: paymentTypeSelected.startIndex)
                }
                return true
            }
            return false
        })
        
        
        if paymentTypeSelected.characters.count > 0 {
            paymentMethod[0].paymentTypeId = paymentTypeSelected
        }
        
        return paymentMethod[0]
    }
    
    internal static func getAccreditationTitle(_ paymentMethod : PaymentMethod) -> String{
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
    
    internal static func getExpirationYearFromLabelText(_ mmyy : String) -> Int {
        let stringMMYY = mmyy.replacingOccurrences(of: "/", with: "")
        let validInt = Int(stringMMYY)
        if(validInt == nil){
            return 0
        }
        let floatMMYY = Float( validInt! / 100 )
        let mm : Int = Int(floor(floatMMYY))
        let yy = Int(stringMMYY)! - (mm*100)
        return yy
        
    }
    
    internal static func getExpirationMonthFromLabelText(_ mmyy : String) -> Int {
        let stringMMYY = mmyy.replacingOccurrences(of: "/", with: "")
        let validInt = Int(stringMMYY)
        if(validInt == nil){
            return 0
        }
        let floatMMYY = Float( validInt! / 100 )
        let mm : Int = Int(floor(floatMMYY))
        return mm
    }

}
