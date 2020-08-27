//
//  PXDiscountsTouchpoint.swift
//  MercadoPagoSDK
//
//  Created by Vicente Veltri on 09/05/2020.
//

import Foundation

@objcMembers
public class PXDiscountsTouchpoint: NSObject, Decodable {

    let id: String
    let type: String
    let content: PXCodableDictionary
    let tracking: PXCodableDictionary?
    let additionalEdgeInsets: PXCodableDictionary?

    public init(id: String, type: String, content: [String:Any], tracking: [String:Any]?, additionalEdgeInsets: [String:Any]?){
        self.id = id
        self.type = type
        self.content = PXCodableDictionary(value: content)

        if let trackingDictionary = tracking {
            self.tracking = PXCodableDictionary(value: trackingDictionary)
        } else {
            self.tracking = nil
        }

        if let additionalEdgeInsetsDictionary = additionalEdgeInsets {
            self.additionalEdgeInsets = PXCodableDictionary(value: additionalEdgeInsetsDictionary)
        } else {
            self.additionalEdgeInsets = nil
        }
    }
    
    init(id: String, type: String, content: PXCodableDictionary, tracking: PXCodableDictionary?, additionalEdgeInsets: PXCodableDictionary?) {
        self.id = id
        self.type = type
        self.content = content
        self.tracking = tracking
        self.additionalEdgeInsets = additionalEdgeInsets
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case content
        case tracking
        case additionalEdgeInsets = "additional_edge_insets"
    }
}

