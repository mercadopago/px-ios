//
//  PXDiscountsItem.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

@objcMembers
public class PXDiscountsItem: NSObject, Decodable {

    let icon: String
    let title: String
    let subtitle: String
    let target: String?
    let campaingId: String?

    public init(icon: String, title: String, subtitle: String, target: String?, campaingId: String?){
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.target = target
        self.campaingId = campaingId
    }

    enum CodingKeys: String, CodingKey {
        case icon
        case title
        case subtitle
        case target
        case campaingId = "campaing_id"
    }
}
