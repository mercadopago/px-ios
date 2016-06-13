//
//  Item.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

public class Item : NSObject {
    
    // que el conjunto no sea nulo y que no este vacio, que todos los items tengan la misma currency
    // que cada item no sea nulo, que su cantidad sea 1 o mayor
    // que el precio no sea nulo, ni menor o igual a cero
    // currency no nula
    // sean monedas conocidas (argentina, brasil, chile, colombia, mexico, venezuela y eeuu)

    public var _id : String!
    public var quantity : Int = 0
    public var unitPrice : Double = 0
    public var title : String!
    public var currencyId : String!
    public var categoryId : String!
    public var pictureUrl : String!
    
    
    public func validate() -> Bool{
        
        if(quantity <= 0){
            return false
        }
        if(unitPrice <= 0){
            return false
        }
        //VALIDAR CADA ITEM
        //VALIDAR PREFERENCE PAYMENT METHOD
        return true
    }

    
    
    public init(_id: String? = nil, title : String? = nil, quantity: Int = 0, unitPrice: Double = 0) {
        self._id = _id
        self.title = title
        self.quantity = quantity
        self.unitPrice = unitPrice
        
    }
    
    public func toJSONString() -> String {
        let obj:[String:AnyObject] = [
            "id": (self._id == nil) ? JSON.null : self._id!,
            "quantity" : self.quantity,
            "unit_price" : self.unitPrice,
            "title" : (self.title == nil) ? JSON.null : self.title!,
            "currencyId" : (self.currencyId == nil) ? JSON.null : self.currencyId!,
            "categoryId" : (self.categoryId == nil) ? JSON.null : self.categoryId!,
            "pictureUrl" : (self.pictureUrl == nil) ? JSON.null : self.pictureUrl!,
        ]
        return JSON(obj).toString()
    }
    
    public class func fromJSON(json : NSDictionary) -> Item {
        let item = Item()
        if json["id"] != nil && !(json["id"]! is NSNull) {
            item._id = JSON(json["id"]!).asString
        }
        
        if json["quantity"] != nil && !(json["quantity"]! is NSNull) {
            item.quantity =  JSON(json["quantity"]!).asInt!
        }
        
        if json["unit_price"] != nil && !(json["unit_price"]! is NSNull) {
            item.unitPrice =  JSON(json["unit_price"]!).asDouble!
        }
        
        if json["title"] != nil && !(json["title"]! is NSNull) {
            item.title =  JSON(json["title"]!).asString
        }
        
        if json["currency_id"] != nil && !(json["currency_id"]! is NSNull) {
            item.currencyId =  JSON(json["currency_id"]!).asString
        }
        
        if json["category_id"] != nil && !(json["category_id"]! is NSNull) {
            item.categoryId =  JSON(json["category_id"]!).asString
        }
        
        if json["picture_url"] != nil && !(json["picture_url"]! is NSNull) {
            item.pictureUrl =  JSON(json["picture_url"]!).asString
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