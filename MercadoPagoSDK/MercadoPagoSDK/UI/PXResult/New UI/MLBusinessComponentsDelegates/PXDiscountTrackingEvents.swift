//
//  PXDiscountTrackingEvents.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/05/21.
//

enum PXDiscountTrackingEvents: TrackingEvents {
    case discount(String, String, [String : Any])
    
    var name: String {
        switch self {
        case .discount(let touchPoint, let action, _): return "/discount_center/payers/touchpoint/\(touchPoint)/\(action)"
        }
    }
    
    var properties: [String : Any] {
        switch self {
        case .discount(_, _, let properties): return properties
        }
    }
}
