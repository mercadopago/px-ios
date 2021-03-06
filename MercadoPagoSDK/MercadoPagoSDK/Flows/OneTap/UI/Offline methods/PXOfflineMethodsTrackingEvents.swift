//
//  PXOfflineMethodsTrackingEvents.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/05/21.
//

enum PXOfflineMethodsTrackingEvents: TrackingEvents {
    case didConfirm([String:Any])
    
    
    var name: String {
        switch self {
        case .didConfirm(_): return "/px_checkout/review/confirm"
        }
    }
    
    var properties: [String : Any] {
        switch self {
        case .didConfirm(let properties): return properties
        }
    }
}
