//
//  PXOneTapNewCardDto.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/11/2019.
//

import Foundation

open class PXOneTapNewCardDto: NSObject, Codable {
    let version: String?
    let label: PXText
    let descriptionText: PXText?
    let cardFormInitType: String?
    let sheetOptions: [PXOneTapSheetOptionsDto]?

    enum CodingKeys: String, CodingKey {
        case version
        case label
        case descriptionText = "description"
        case cardFormInitType = "card_form_init_type"
        case sheetOptions = "sheet_options"
    }
}
