//
//  PXPromotionsViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServices

final class PXPromotionsViewModel: NSObject {

    var bankDeals: [PXBankDeal]

    public init(bankDeals: [PXBankDeal]) {
        self.bankDeals = bankDeals
        super.init()
    }
}
