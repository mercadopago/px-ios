//
//  PXItem.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXItem: NSObject, Codable {

    open var categoryId: String!
    open var currencyId: String!
    open var _description: String!
    open var id: String!
    open var pictureUrl: String!
    open var quantity: Int!
    open var title: String!
    open var unitPrice: Double!

    init(categoryId: String, currencyId: String, description: String, id: String, pictureUrl: String, quantity: Int, title: String, unitPrice: Double) {
        self.categoryId = categoryId
        self.currencyId = currencyId
        self._description = description
        self.id = id
        self.pictureUrl = pictureUrl
        self.quantity = quantity
        self.title = title
        self.unitPrice = unitPrice
    }

    public enum PXItemKeys: String, CodingKey {
        case categoryId = "category_id"
        case currencyId = "currency_id"
        case description = "description"
        case id
        case pictureUrl = "picture_url"
        case quantity
        case title
        case unitPrice = "unit_price"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXItemKeys.self)
        let categoryId: String = try container.decode(String.self, forKey: .categoryId)
        let currencyId: String = try container.decode(String.self, forKey: .currencyId)
        let description: String = try container.decode(String.self, forKey: .description)
        let id: String = try container.decode(String.self, forKey: .id)
        let pictureUrl: String = try container.decode(String.self, forKey: .pictureUrl)
        let title: String = try container.decode(String.self, forKey: .title)
        let unitPrice: Double = try container.decode(Double.self, forKey: .unitPrice)
        let quantity: Int = try container.decode(Int.self, forKey: .quantity)

        self.init(categoryId: categoryId, currencyId: currencyId, description: description, id: id, pictureUrl: pictureUrl, quantity: quantity, title: title, unitPrice: unitPrice)
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

    open class func fromJSON(data: Data) throws -> PXItem {
        return try JSONDecoder().decode(PXItem.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXItem] {
        return try JSONDecoder().decode([PXItem].self, from: data)
    }

}
