//
//  TokenizationTrackingEvents.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/05/21.
//

enum GeneralErrorTrackingEvents: TrackingEvents {
    case error([String:Any])
    
    var name: String {
        switch self {
        case .error(_): return "/friction"
        }
    }
    
    var properties: [String : Any] {
        switch self {
        case .error(let properties): return properties
        }
    }
}
