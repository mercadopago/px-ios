//
//  PXCurrencies.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class PXCurrencies: NSObject {

    open static let CURRENCY_ARGENTINA = "ARS"
    open static let CURRENCY_BRAZIL = "BRL"
    open static let CURRENCY_CHILE = "CLP"
    open static let CURRENCY_COLOMBIA = "COP"
    open static let CURRENCY_MEXICO = "MXN"
    open static let CURRENCY_VENEZUELA = "VEF"
    open static let CURRENCY_USA = "USD"
    open static let CURRENCY_PERU = "PEN"
    open static let CURRENCY_URUGUAY = "UYU"

    open class var currenciesList: [String: Currency] { return [
        "ARS": Currency(_id: "ARS", description: "Peso argentino", symbol: "$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        "BRL": Currency(_id: "BRL", description: "Real", symbol: "R$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        "CLP": Currency(_id: "CLP", description: "Peso chileno", symbol: "$", decimalPlaces: 0, decimalSeparator: "", thousandSeparator: "."),
        "MXN": Currency(_id: "MXN", description: "Peso mexicano", symbol: "$", decimalPlaces: 2, decimalSeparator: ".", thousandSeparator: ","),
        "PEN": Currency(_id: "PEN", description: "Soles", symbol: "S/.", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        "UYU": Currency(_id: "UYU", description: "Peso Uruguayo", symbol: "$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."),
        "COP": Currency(_id: "COP", description: "Peso colombiano", symbol: "$", decimalPlaces: 0, decimalSeparator: "", thousandSeparator: "."),
        "VEF": Currency(_id: "VEF", description: "Bolivar fuerte", symbol: "BsF", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: ".")
        ]}
}
