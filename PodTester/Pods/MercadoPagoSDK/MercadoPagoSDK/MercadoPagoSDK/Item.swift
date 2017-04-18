//
//  Item.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class Item : NSObject {
    
    // que el conjunto no sea nulo y que no este vacio, que todos los items tengan la misma currency
    // que cada item no sea nulo, que su cantidad sea 1 o mayor
    // que el precio no sea nulo, ni menor o igual a cero
    // currency no nula
    // sean monedas conocidas (argentina, brasil, chile, colombia, mexico, venezuela y eeuu)

    open var _id : String!
    open var quantity : Int!
    open var unitPrice : Double!
    open var title : String!
    open var _description : String?
    open var currencyId : String!
    open var categoryId : String!
    open var pictureUrl : String!
    
    
    open func validate() -> String?{
        
        if title.isEmpty {
            return "El título del item esta vacio".localized
        }
        
        if currencyId.isEmpty{
            return "La currency del item esta vacia".localized
        }
        
        return nil
    }

    
    
    
    public init(_id: String? = nil, title : String? = nil, quantity: Int = 0, unitPrice: Double = 0, description : String? = "", currencyId: String = "ARS") {
        super.init()
        self._id = _id
        self.title = title
        self.quantity = quantity
        self.unitPrice = unitPrice
        self._description = description ?? ""
        self.currencyId = currencyId
    }
    
    open func toJSONString() -> String {
        
        let _id : Any = (self._id == nil) ? JSONHandler.null : self._id!
        let title  : Any =  (self.title == nil) ? JSONHandler.null : self.title!
        let currencyId : Any =  (self.currencyId == nil) ? JSONHandler.null : self.currencyId!
        let categoryId : Any =  (self.categoryId == nil) ? JSONHandler.null : self.categoryId!
        let pictureUrl : Any =  (self.pictureUrl == nil) ? JSONHandler.null : self.pictureUrl!
        
        let obj:[String:Any] = [
            "id": _id,
            "quantity" : self.quantity,
            "unit_price" : self.unitPrice,
            "title" : title,
            "description" : self._description,
            "currencyId" : currencyId,
            "categoryId" : categoryId,
            "pictureUrl" :pictureUrl,
        ]
        return JSONHandler.jsonCoding(obj)
    }
    
    open class func fromJSON(_ json : NSDictionary) -> Item {
        let item = Item()
        if let _id = JSONHandler.attemptParseToString(json["json"]){
            item._id = _id
        }
        if let quantity = JSONHandler.attemptParseToInt(json["quantity"]){
            item.quantity = quantity
        }
        if let unitPrice = JSONHandler.attemptParseToDouble(json["unit_price"]){
            item.unitPrice = unitPrice
        }
        if let title = JSONHandler.attemptParseToString(json["title"]){
            item.title = title
        }
        if let description = JSONHandler.attemptParseToString(json["description"]){
            item._description = description
        }
        if let currencyId = JSONHandler.attemptParseToString(json["currency_id"]){
            item.currencyId = currencyId
        }
        if let categoryId = JSONHandler.attemptParseToString(json["category_id"]){
            item.categoryId = categoryId
        }
        if let pictureUrl = JSONHandler.attemptParseToString(json["picture_url"]){
            item.pictureUrl = pictureUrl
        }

        return item
    }
}


public func ==(obj1: Item, obj2: Item) -> Bool {
    
    let areEqual =
        obj1._id == obj2._id &&
        obj1.quantity == obj2.quantity &&
        obj1.unitPrice == obj2.unitPrice &&
        obj1.title == obj2.title &&
        obj1.currencyId == obj2.currencyId &&
        obj1.categoryId == obj2.categoryId &&
        obj1.pictureUrl == obj2.pictureUrl
    
    return areEqual
}
