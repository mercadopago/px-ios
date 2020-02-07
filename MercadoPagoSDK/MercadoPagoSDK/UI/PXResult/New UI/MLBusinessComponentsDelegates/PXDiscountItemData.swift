//
//  PXDiscountItemData.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 13/09/2019.
//

import UIKit
import MLBusinessComponents

class PXDiscountItemData: NSObject, MLBusinessSingleItemProtocol {
    let item: PXDiscountsItem

    init(item: PXDiscountsItem) {
        self.item = item
    }

    func titleForItem() -> String {
        return item.title
    }

    func subtitleForItem() -> String {
        return item.subtitle
    }

    func iconImageUrlForItem() -> String {
        return item.icon
    }

    func deepLinkForItem() -> String? {
        return item.target
    }

    func trackIdForItem() -> String? {
        return item.campaingId
    }
    
    func eventDataForItem() -> [String : Any]? {
        var eventData: [String : Any] = [ : ]
        
        eventData["title"] = item.title
        eventData["subtitle"] = item.subtitle
        eventData["icon"] = item.icon
        if let target = item.target { eventData["target"] = target }
        if let campaignId = item.campaingId { eventData["campaignId"] = campaignId }

        return eventData
    }
}
