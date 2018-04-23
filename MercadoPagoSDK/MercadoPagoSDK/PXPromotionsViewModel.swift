//
//  PXPromotionsViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class PXPromotionsViewModel: NSObject {

    var bankDeals: [BankDeal]

    public init(bankDeals: [BankDeal]) {
        self.bankDeals = bankDeals
        super.init()
    }
}
