//
//  OneTapCard.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
open class OneTapCard: NSObject {
    open var cardId: String
    open var selectedPayerCost: PayerCost?

    public init(cardId: String, selectedPayerCost: PayerCost?) {
        self.cardId = cardId
        self.selectedPayerCost = selectedPayerCost
    }
}
