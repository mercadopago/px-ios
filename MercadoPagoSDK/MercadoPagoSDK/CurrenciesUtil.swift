//
//  CurrenciesUtil.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 3/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

public class CurrenciesUtil {
 
    public class var currenciesList : [String: Currency] { return [
        "ARS" : Currency(_id: "ARS", description: "Peso argentino", symbol: "$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        "BRL" : Currency(_id: "BRL", description: "Real", symbol: "R$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        "CLP" : Currency(_id: "CLP", description: "Peso chileno", symbol: "$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        "COP" : Currency(_id: "COP", description: "Peso colombiano", symbol: "$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        "MXN" : Currency(_id: "MXN", description: "Peso mexicano", symbol: "$", decimalPlaces: 2, decimalSeparator: ".", thousandSeparator: ","),
		"VEF" : Currency(_id: "VEF", description: "Bolivar fuerte", symbol: "BsF", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: ".")
        ]}
    
    public class func getCurrencyFor(currencyId : String?) -> Currency? {
        return (currencyId != nil && currencyId?.characters.count > 0) ? self.currenciesList[currencyId!] : nil
    }
 
    public class func formatNumber(amount: Double, currencyId: String) -> String? {
    
        // Get currency configuration
        let currency : Currency? = currenciesList[currencyId]
    
        if currency != nil {
    
            // Set formatters
            let formatter : NSNumberFormatter = NSNumberFormatter()
            formatter.decimalSeparator = String(currency!.decimalSeparator)
            formatter.groupingSeparator = String(currency!.thousandsSeparator)
            formatter.numberStyle = .NoStyle
            formatter.maximumFractionDigits = currency!.decimalPlaces
            // return formatted string
            let number = amount as NSNumber
            return currency!.symbol + " " + formatter.stringFromNumber(number)!
        } else {
            return nil
        }
    }
}