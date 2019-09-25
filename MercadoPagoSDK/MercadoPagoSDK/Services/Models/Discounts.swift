//
//  Discounts.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

struct Discounts: Decodable {

    let title: String?
    let subtitle: String?
    let discountsAction: PointsAndDiscountsAction
    let downloadAction: DownloadAction
    let items: [DiscountsItem]

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case discountsAction = "action"
        case downloadAction = "action_download"
        case items
    }
}