//
//  Item.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

@objcMembers open class Item: NSObject {

    // que el conjunto no sea nulo y que no este vacio, que todos los items tengan la misma currency
    // que cada item no sea nulo, que su cantidad sea 1 o mayor
    // que el precio no sea nulo, ni menor o igual a cero
    // currency no nula
    // sean monedas conocidas (argentina, brasil, chile, colombia, mexico, venezuela y eeuu)

    open var itemId: String!
    open var quantity: Int!
    open var unitPrice: Double!
    open var title: String?
    open var itemDescription: String?
    open var currencyId: String!
    open var categoryId: String?
    open var pictureUrl: String?

    open func validate() -> String? {
        if currencyId.isEmpty {
            return "La currency del item esta vacia".localized
        }
        if quantity <= 0 {
            return "La cantidad de items no es valida".localized
        }

        return nil
    }

    public init(itemId: String? = nil, title: String? = nil, quantity: Int = 0, unitPrice: Double = 0, description: String? = "", currencyId: String = "ARS") {
        super.init()
        self.itemId = itemId
        self.title = title
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.itemDescription = description ?? ""
        self.currencyId = currencyId
    }

    open class func fromJSON(_ json: NSDictionary) -> Item {
                let item = Item()

                item.itemId = JSONHandler.getValue(of: String.self, key: "id", from: json)

                if let quantity = JSONHandler.attemptParseToInt(json["quantity"]) {
                        item.quantity = quantity
                    }
                if let unitPrice = JSONHandler.attemptParseToDouble(json["unit_price"]) {
                        item.unitPrice = unitPrice
                    }
                if let title = JSONHandler.attemptParseToString(json["title"]) {
                        item.title = title
                    }
                if let description = JSONHandler.attemptParseToString(json["description"]) {
                        item.itemDescription = description
                    }

                item.currencyId = JSONHandler.getValue(of: String.self, key: "currency_id", from: json)

                if let categoryId = JSONHandler.attemptParseToString(json["category_id"]) {
                        item.categoryId = categoryId
                    }
                if let pictureUrl = JSONHandler.attemptParseToString(json["picture_url"]) {
                        item.pictureUrl = pictureUrl
                    }

                return item
            }

    open func toJSONString() -> String {

        let itemId: Any = (self.itemId == nil) ? JSONHandler.null : self.itemId!
        let title: Any =  (self.title == nil) ? JSONHandler.null : self.title!
        let currencyId: Any =  (self.currencyId == nil) ? JSONHandler.null : self.currencyId!
        let categoryId: Any =  (self.categoryId == nil) ? JSONHandler.null : self.categoryId!
        let pictureUrl: Any =  (self.pictureUrl == nil) ? JSONHandler.null : self.pictureUrl!

        let obj: [String: Any] = [
            "id": itemId,
            "quantity": self.quantity,
            "unit_price": self.unitPrice,
            "title": title,
            "description": self.itemDescription ?? "",
            "currency_id": currencyId,
            "category_id": categoryId,
            "picture_url": pictureUrl
        ]
        return JSONHandler.jsonCoding(obj)
    }
}
