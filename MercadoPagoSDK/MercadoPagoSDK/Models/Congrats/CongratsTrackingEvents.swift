//
//  CongratsTrackingEvents.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/05/21.
//

enum CongratsTrackingEvents: TrackingEvents {
    case didTapDiscount([String:Any])
    
    var name: String {
        switch self {
        case .didTapDiscount(_): return "/px_checkout/result/success"
        }
    }
    
    var properties: [String : Any] {
        switch self {
        case .didTapDiscount(let properties): return properties
        }
    }
    
    
}
