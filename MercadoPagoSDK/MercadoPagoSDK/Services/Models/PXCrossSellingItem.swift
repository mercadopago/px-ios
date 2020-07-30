//
//  PXCrossSellingItem.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 17/09/2019.
//

import Foundation

@objcMembers
public class PXCrossSellingItem: NSObject ,Decodable {

    let title: String
    let icon: String
    let contentId: String
    let action: PXRemoteAction

    public init(title:String, icon:String, contentId: String, actionLabel:String, actionTarget: String){
        self.title = title
        self.icon = icon
        self.contentId = contentId
        self.action = PXRemoteAction(label: actionLabel, target: actionTarget)
    }

    enum CodingKeys: String, CodingKey {
        case title
        case icon
        case contentId = "content_id"
        case action
    }
}
