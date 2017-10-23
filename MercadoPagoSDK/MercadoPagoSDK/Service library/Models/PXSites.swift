//
//  PXSites.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class PXSites: NSObject {

    open static let ARGENTINA = PXSite(id: "MLA", currencyId: "ARS")
    open static let BRASIL = PXSite(id: "MLB", currencyId: "BRL")
    open static let CHILE = PXSite(id: "MLC", currencyId: "CLP")
    open static let MEXICO = PXSite(id: "MLM", currencyId: "MXN")
    open static let COLOMBIA = PXSite(id: "MCO", currencyId: "COP")
    open static let VENEZUELA = PXSite(id: "MLV", currencyId: "VEF")
    open static let USA = PXSite(id: "USA", currencyId: "USD")
    open static let PERU = PXSite(id: "MPE", currencyId: "PEN")

}
