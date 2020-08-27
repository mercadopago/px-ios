//
//  PXDiscounts.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

@objcMembers
public class PXDiscounts: NSObject , Decodable {

    let title: String?
    let subtitle: String?
    let discountsAction: PXRemoteAction
    let downloadAction: PXDownloadAction
    let items: [PXDiscountsItem]
    let touchpoint: PXDiscountsTouchpoint?

    public init(title: String?, subtitle: String?, discountsAction: PXRemoteAction, downloadAction: PXDownloadAction, items: [PXDiscountsItem], touchpoint: PXDiscountsTouchpoint?) {
        self.title = title
        self.subtitle = subtitle
        self.discountsAction = discountsAction
        self.downloadAction = downloadAction
        self.items = items
        self.touchpoint = touchpoint
    }

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case discountsAction = "action"
        case downloadAction = "action_download"
        case items
        case touchpoint
    }
}
