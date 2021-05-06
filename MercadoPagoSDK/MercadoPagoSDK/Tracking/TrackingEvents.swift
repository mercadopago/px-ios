//
//  TrackingEvents.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/05/21.
//

import Foundation

protocol TrackingEvents {
    var name: String { get }
    var properties: [String : Any] { get }
}
