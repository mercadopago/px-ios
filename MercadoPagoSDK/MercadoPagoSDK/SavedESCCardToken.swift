//
//  SavedESCCardToken.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

/** :nodoc: */
@objcMembers open class SavedESCCardToken: SavedCardToken {
    open var requireESC: Bool = false
    open var esc: String?

    init (cardId: String, securityCode: String?, requireESC: Bool) {
        super.init(cardId: cardId)
        self.securityCode = securityCode
        self.cardId = cardId
        self.requireESC = requireESC
        self.device = Device()
    }

    init (cardId: String, esc: String?, requireESC: Bool) {
        super.init(cardId: cardId)
        self.securityCode = ""
        self.cardId = cardId
        self.requireESC = requireESC
        self.esc = esc
        self.device = Device()
    }

    open override func toJSON() -> [String: Any] {
        var obj = super.toJSON()
        obj["require_esc"] = requireESC
        obj["esc"] = String.isNullOrEmpty(self.esc) ? JSONHandler.null : self.esc!
        return obj
    }
}
