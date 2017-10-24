//
//  PXPaymentMethods.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPaymentMethods: NSObject {
    open static let ACCOUNT_MONEY = "account_money"

    open class ARGENTINA: NSObject {
        open static let VISA = "visa"
        open static let MASTER = "master"
        open static let AMEX = "amex"
        open static let NARANJA = "naranja"
        open static let NATIVA = "nativa"
        open static let TARSHOP = "tarshop"
        open static let CENCOSUD = "cencosud"
        open static let DINERS = "diners"
        open static let CABAL = "cabal"
        open static let ARGENCARD = "argencard"
        open static let PAGOFAIL = "pagofacil"
        open static let RAPIPAGO = "rapipago"
        open static let CARGA_VIRTUAL = "cargavirtual"
        open static let CORDOBESA = "cordobesa"
        open static let CMR = "cmr"
        open static let MERCADOPAGO_CC = "mercadopago_cc"
        open static let REDLINK = "redlink"
        open static let BAPROPAGOS = "bapropagos"
        open static let CORDIAL = "cordial"
        open static let MAESTRO = "maestro"
        open static let DEBMASTER = "debmaster"
        open static let DEBCABAL = "debcabal"
        open static let DEBVISA = "debvisa"
    }

    open class BRAZIL: NSObject {
        open static let VISA = "visa"
        open static let MASTER = "master"
        open static let AMEX = "amex"
        open static let HIPERCARD = "hipercard"
        open static let DINERS = "diners"
        open static let ELO = "elo"
        open static let MELICARD = "melicard"
        open static let BOLBRADESCO = "bolbradesco"
    }

    open class MEXICO: NSObject {
        open static let VISA = "visa"
        open static let MASTER = "master"
        open static let AMEX = "amex"
        open static let DEBVISA = "debvisa"
        open static let DEBMASTER = "debmaster"
        open static let MERCADOPAGOCARD = "mercadopagocard"
        open static let BANCOMER = "bancomer"
        open static let SERFIN = "serfin"
        open static let BANAMEX = "banamex"
        open static let OXXO = "oxxo"
    }

    open class VENEZUELA: NSObject {
        open static let VISA = "visa"
        open static let MASTER = "master"
        open static let MERCANTIL = "mercantil"
        open static let PROVINCIAL = "provincial"
        open static let BANESCO = "banesco"
    }

    open class COLOMBIA: NSObject {
        open static let VISA = "visa"
        open static let AMEX = "amex"
        open static let MASTER = "master"
        open static let DINERS = "diners"
        open static let CODENSA = "codensa"
        open static let EFECTY = "efecty"
        open static let DAVIVIENDA = "davivienda"
        open static let PSE = "pse"
    }

    open class PERU: NSObject {
        open static let VISA = "visa"
        open static let DEBVISA = "debvisa"
        open static let PAGOEFECTIVO_ATM = "pagoefectivo_atm"
    }

    open class CHILE: NSObject {
        open static let VISA = "visa"
        open static let AMEX = "amex"
        open static let MASTER = "master"
        open static let MAGNA = "magna"
        open static let PRESTO = "presto"
        open static let CMR = "cmr"
        open static let DINERS = "diners"
        open static let WEBPAY = "webpay"
        open static let SERVIPAG = "servipag"
        open static let KHIPU = "khipu"
    }
}
