//
//  MercadoPagoUITrackingEvents.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/05/21.
//

enum MercadoPagoUITrackingEvents: TrackingEvents {    
    case didAbort(String, [String:Any])
    case didGoBack(String)
    
    var name: String {
        switch self {
        case .didAbort(let screen, _): return "\(screen)/abort"
        case .didGoBack(let screen): return "\(screen)/back"
        }
    }
    
    var properties: [String : Any] {
        switch self {
        case .didAbort(_, let properties): return properties
        case .didGoBack(_): return [:]
        }
    }
}
