//
//  MercadoPagoCheckoutTrackingEvents.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/05/21.
//

enum MercadoPagoCheckoutTrackingEvents: TrackingEvents {
    case didInitFlow([String:Any])
    
    var name: String {
        switch self {
        case .didInitFlow(_): return "/px_checkout/init"
        }
    }
    
    var properties: [String : Any] {
        switch self {
        case .didInitFlow(let properties): return properties
        }
    }
}
