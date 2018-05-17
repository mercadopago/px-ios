//
//  CurrenciesUtil.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 3/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l__?, r__?):
    return l__ < r__
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l__?, r__?):
    return l__ > r__
  default:
    return rhs < lhs
  }
}

@objcMembers
open class CurrenciesUtil {

    open class var currenciesList: [String: Currency] { return [
        //Argentina
        "ARS": Currency(currencyId: "ARS", description: "Peso argentino", symbol: "$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        //Brasil
        "BRL": Currency(currencyId: "BRL", description: "Real", symbol: "R$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        //Chile
        "CLP": Currency(currencyId: "CLP", description: "Peso chileno", symbol: "$", decimalPlaces: 0, decimalSeparator: "", thousandSeparator: "."),

        //Mexico
        "MXN": Currency(currencyId: "MXN", description: "Peso mexicano", symbol: "$", decimalPlaces: 2, decimalSeparator: ".", thousandSeparator: ","),
		//Peru
        "PEN": Currency(currencyId: "PEN", description: "Soles", symbol: "S/.", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
		//Uruguay
        "UYU": Currency(currencyId: "UYU", description: "Peso Uruguayo", symbol: "$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
		//Colombia

        "COP": Currency(currencyId: "COP", description: "Peso colombiano", symbol: "$", decimalPlaces: 0, decimalSeparator: "", thousandSeparator: "."),

		//Venezuela
        "VES": Currency(currencyId: "VES", description: "Bolívares Soberanos", symbol: "BsS", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: ".")

        ]}

    open class func getCurrencyFor(_ currencyId: String?) -> Currency? {
        return (currencyId != nil && currencyId?.count > 0) ? self.currenciesList[currencyId!] : nil
    }

}
