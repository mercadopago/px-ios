//
//  PXCardSliderTrackingEvents.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/05/21.
//

enum PXCardSliderTrackingEvents: TrackingEvents {
    case comboSwitch(String)
    
    
    var name: String {
        switch self {
        case .comboSwitch(_): return "/px_checkout/combo_switch"
        }
    }
    
    var properties: [String : Any] {
        switch self {
        case .comboSwitch(let state): return ["option_selected": state]
        }
    }
}
