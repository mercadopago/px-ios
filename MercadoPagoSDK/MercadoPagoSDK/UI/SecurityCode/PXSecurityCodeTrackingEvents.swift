//
//  PXSecurityCodeTrackingEvents.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/05/21.
//

enum PXSecurityCodeTrackingEvents: TrackingEvents {
    case didConfirmCode([String:Any])
    
    var name: String {
        switch self {
        case .didConfirmCode(_): return "/px_checkout/review/confirm"
        }
    }
    
    var properties: [String : Any] {
        switch self {
        case .didConfirmCode(let properties): return properties
        }
    }
}
