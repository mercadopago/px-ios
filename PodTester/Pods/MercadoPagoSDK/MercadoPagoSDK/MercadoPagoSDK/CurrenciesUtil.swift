//
//  CurrenciesUtil.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 3/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
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


open class CurrenciesUtil {
 
    open class var currenciesList : [String: Currency] { return [
        "ARS" : Currency(_id: "ARS", description: "Peso argentino", symbol: "$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        "BRL" : Currency(_id: "BRL", description: "Real", symbol: "R$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        "CLP" : Currency(_id: "CLP", description: "Peso chileno", symbol: "$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        "COP" : Currency(_id: "COP", description: "Peso colombiano", symbol: "$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        "MXN" : Currency(_id: "MXN", description: "Peso mexicano", symbol: "$", decimalPlaces: 2, decimalSeparator: ".", thousandSeparator: ","),
		"VEF" : Currency(_id: "VEF", description: "Bolivar fuerte", symbol: "BsF", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: ".")
        ]}
    
    open class func getCurrencyFor(_ currencyId : String?) -> Currency? {
        return (currencyId != nil && currencyId?.characters.count > 0) ? self.currenciesList[currencyId!] : nil
    }
 
    open class func formatNumber(_ amount: Double, currencyId: String) -> String? {
    
        // Get currency configuration
        let currency : Currency? = currenciesList[currencyId]
    
        if currency != nil {
    
            // Set formatters
            let formatter : NumberFormatter = NumberFormatter()
            formatter.decimalSeparator = String(currency!.decimalSeparator)
            formatter.groupingSeparator = String(currency!.thousandsSeparator)
            formatter.numberStyle = .none
            formatter.maximumFractionDigits = currency!.decimalPlaces
            // return formatted string
            let number = amount as NSNumber
            return currency!.symbol + " " + formatter.string(from: number)!
        } else {
            return nil
        }
    }
}
