//
//  PXPaymentMethodSearchItem.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPaymentMethodSearchItem: NSObject, Codable {
    open var id: String!
    open var type: String!
    open var _description: String!
    open var comment: String?
    open var children: [PXPaymentMethodSearchItem]?
    open var childrenHeader: String?
    open var showIcon: Bool!


    init(id: String, type: String, description: String, comment: String?, children: [PXPaymentMethodSearchItem]?, childrenHeader: String?, showIcon: Bool) {
        self.id = id
        self.type = type
        self._description = description
        self.comment = comment
        self.children = children
        self.childrenHeader = childrenHeader
        self.showIcon = showIcon
    }

    public enum PXPaymentMethodSearchItemKeys: String, CodingKey {
        case id
        case type
        case description = "description"
        case comment
        case children
        case childrenHeader = "children_header"
        case showIcon = "show_icon"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXPaymentMethodSearchItemKeys.self)
        let id: String = try container.decode(String.self, forKey: .id)
        let type: String = try container.decode(String.self, forKey: .type)
        let description: String = try container.decode(String.self, forKey: .description)
        let comment: String? = try container.decodeIfPresent(String.self, forKey: .comment)
        let children: [PXPaymentMethodSearchItem]? = try container.decodeIfPresent([PXPaymentMethodSearchItem].self, forKey: .children)
        let childrenHeader: String? = try container.decodeIfPresent(String.self, forKey: .childrenHeader)
        let showIcon: Bool = try container.decode(Bool.self, forKey: .showIcon)

        self.init(id: id, type: type, description: description, comment: comment, children: children, childrenHeader: childrenHeader, showIcon: showIcon)
    }

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSON(data: Data) throws -> PXPaymentMethodSearchItem {
        return try JSONDecoder().decode(PXPaymentMethodSearchItem.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXPaymentMethodSearchItem] {
        return try JSONDecoder().decode([PXPaymentMethodSearchItem].self, from: data)
    }

}
