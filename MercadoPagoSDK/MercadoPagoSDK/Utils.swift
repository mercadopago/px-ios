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
    
    class func setContrainsHorizontal(views: [String: UIView], constrain: CGFloat) {
        let widthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(constrain))-[label]-(\(constrain))-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        NSLayoutConstraint.activate(widthConstraints)
    }
    
    class func setContrainsVertical(label: UIView, previus: UIView?, constrain:CGFloat) {
        if let previus = previus {
            let heightConstraints = [NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: previus, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: constrain)]
            NSLayoutConstraint.activate(heightConstraints)
        }
    }
    
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
    
    class func getAttributedAmount(_ amount : Double, currency : Currency, color : UIColor = UIColor.px_white(), fontSize : CGFloat = 20, centsFontSize: CGFloat = 10, baselineOffset : Int = 7) -> NSAttributedString {
        return self.getAttributedAmount(amount, thousandSeparator: currency.thousandsSeparator, decimalSeparator: currency.decimalSeparator, currencySymbol: currency.symbol, color : color, fontSize : fontSize, centsFontSize: centsFontSize, baselineOffset : baselineOffset)
    }
    
    class func getAttributedAmount(_ formattedString : String, thousandSeparator: String, decimalSeparator: String, currencySymbol : String, color : UIColor = UIColor.px_white(), fontSize : CGFloat = 20, baselineOffset : Int = 7) -> NSAttributedString {
        let cents = getCentsFormatted(formattedString, decimalSeparator: decimalSeparator)
        let amount = getAmountFormatted(String(describing: Int(formattedString)), thousandSeparator : thousandSeparator, decimalSeparator: decimalSeparator)
        
        
        let normalAttributes: [String:AnyObject] = [NSFontAttributeName : getFont(size: fontSize),NSForegroundColorAttributeName: color]
        let smallAttributes : [String:AnyObject] = [NSFontAttributeName : getFont(size: 10),NSForegroundColorAttributeName: color, NSBaselineOffsetAttributeName : baselineOffset as AnyObject]
        
    
        
        let attributedSymbol = NSMutableAttributedString(string: currencySymbol, attributes: normalAttributes)
        let attributedAmount = NSMutableAttributedString(string: amount, attributes: normalAttributes)
        let attributedCents = NSAttributedString(string: cents, attributes: smallAttributes)
        let space = NSAttributedString(string: String.NON_BREAKING_LINE_SPACE, attributes: smallAttributes)
        attributedSymbol.append(space)
        attributedSymbol.append(attributedAmount)
        attributedSymbol.append(space)
        attributedSymbol.append(attributedCents)
        return attributedSymbol
    }
    
    
    class func getAttributedAmount(_ amount : Double, thousandSeparator: String, decimalSeparator: String, currencySymbol : String, color : UIColor = UIColor.px_white(), fontSize : CGFloat = 20, centsFontSize: CGFloat = 10, baselineOffset : Int = 7) -> NSAttributedString {
        let cents = getCentsFormatted(String(amount), decimalSeparator: ".")
        let amount = getAmountFormatted(String(describing: Int(amount)), thousandSeparator : thousandSeparator, decimalSeparator: ".")
        
        
        let normalAttributes: [String:AnyObject] = [NSFontAttributeName : getFont(size: fontSize),NSForegroundColorAttributeName: color]
        let smallAttributes : [String:AnyObject] = [NSFontAttributeName : getFont(size: centsFontSize),NSForegroundColorAttributeName: color, NSBaselineOffsetAttributeName : baselineOffset as AnyObject]
        
        
        let attributedSymbol = NSMutableAttributedString(string: currencySymbol, attributes: normalAttributes)
        let attributedAmount = NSMutableAttributedString(string: amount, attributes: normalAttributes)
        let attributedCents = NSAttributedString(string: cents, attributes: smallAttributes)
        let space = NSAttributedString(string: String.NON_BREAKING_LINE_SPACE, attributes: smallAttributes)
        attributedSymbol.append(space)
        attributedSymbol.append(attributedAmount)
        attributedSymbol.append(space)
        attributedSymbol.append(attributedCents)
        return attributedSymbol
    }
    
    class func getTransactionInstallmentsDescription(_ installments : String, installmentAmount : Double, additionalString : NSAttributedString? = nil, color : UIColor? = nil, fontSize : CGFloat = 22, centsFontSize : CGFloat = 10, baselineOffset : Int = 7) -> NSAttributedString {
        let color = color ?? UIColor.lightBlue()
        
        let descriptionAttributes: [String:AnyObject] = [NSFontAttributeName : getFont(size: fontSize),NSForegroundColorAttributeName:color]
        
        let stringToWrite = NSMutableAttributedString()
        
        stringToWrite.append(NSMutableAttributedString(string: installments + "x ", attributes: descriptionAttributes))
        
        stringToWrite.append(Utils.getAttributedAmount(installmentAmount, thousandSeparator: ".", decimalSeparator: ",", currencySymbol: "$" , color:color, fontSize : fontSize, centsFontSize: centsFontSize, baselineOffset : baselineOffset))
        
        if additionalString != nil {
            stringToWrite.append(additionalString!)
        }
        
        return stringToWrite
    }
    class func getFont(size: CGFloat) -> UIFont{
        return UIFont(name: MercadoPagoContext.getDecorationPreference().getFontName(), size: size) ?? UIFont.systemFont(ofSize: size)
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
        } else if cents.characters.count > 2 {
            let index1 = cents.index(cents.startIndex, offsetBy: 2)
            cents = cents.substring(to: index1)
        }
        
        return cents
    }
    
    /**
     Returns amount string formatted according to separators
     Ex: formattedString = "10200", decimalSeparator = ".", thousandSeparator: ","
     returns 10,200
     **/
    class func getAmountFormatted(_ formattedString : String, thousandSeparator: String, decimalSeparator: String) -> String {
        
        let amount = self.getAmountDigits(formattedString, decimalSeparator : decimalSeparator)
        let length = amount.characters.count
        if length <= 3 {
            return amount
        }
        var numberWithoutLastThreeDigits: String = ""
        if let amountString = Double(formattedString){
            numberWithoutLastThreeDigits = String( CUnsignedLongLong(amountString/1000))
        }
        let lastThreeDigits = amount.lastCharacters(number: 3)
        
        return  getAmountFormatted(numberWithoutLastThreeDigits, thousandSeparator: thousandSeparator, decimalSeparator:thousandSeparator).appending(thousandSeparator).appending(lastThreeDigits)
        
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
        if let _ = Double(formattedString) {
            return formattedString
        }
        return ""
    }
    
    static internal func findPaymentMethodSearchItemInGroups(_ paymentMethodSearch : PaymentMethodSearch, paymentMethodId : String, paymentTypeId : PaymentTypeId?) -> PaymentMethodSearchItem? {
        guard let _ = paymentMethodSearch.groups
            else {return nil}
    
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
            if (paymentMethodId.startsWith(paymentMethod._id)){
                let paymentTypeIdRange = paymentMethodId.range(of: paymentMethod._id)
                // Override paymentTypeId if neccesary
                if paymentTypeIdRange != nil {
                    paymentTypeSelected = paymentMethodId.substring(from: paymentTypeIdRange!.upperBound)
                    if !String.isNullOrEmpty(paymentTypeSelected) {
                        paymentTypeSelected.remove(at: paymentTypeSelected.startIndex)
                    }
                }
                return true
                
            }
            return false
        })
        
        if !String.isNullOrEmpty(paymentTypeSelected) {
            paymentMethod[0].paymentTypeId = paymentTypeSelected
        }
        
        return paymentMethod[0]
    }
    
    internal static func getExpirationYearFromLabelText(_ mmyy : String) -> Int {
        let stringMMYY = mmyy.replacingOccurrences(of: "/", with: "")
        let validInt = Int(stringMMYY)
        if(validInt == nil || stringMMYY.characters.count < 4){
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
        if (mm >= 1 && mm <= 12) {
            return mm
        }
        return 0
    }
    
}

