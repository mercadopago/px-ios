//
//  PXOneTapSheetOptionsDto.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 29/10/2020.
//

import Foundation

open class PXOneTapSheetOptionsDto: NSObject, Codable {
    let cardFormInitType: String?
    let title: PXText
    let subtitle: PXText?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case cardFormInitType = "card_form_init_type"
        case title
        case subtitle = "description"
        case imageUrl = "image_url"
    }
}
