//
//  MercadoPagoServicesModelAdapter.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 10/25/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

internal extension MercadoPagoServicesAdapter {

    func getPXSiteFromId(_ siteId: String) -> PXSite {
        let currency = SiteManager.shared.getCurrency()
        let pxSite = PXSite(id: siteId, currencyId: currency.id)
        return pxSite
    }

    func getStringDateFromDate(_ date: Date) -> String {
        let stringDate = String(describing: date)
        return stringDate
    }
}
