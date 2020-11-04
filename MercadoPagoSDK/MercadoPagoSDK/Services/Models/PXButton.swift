//
//  PXButton.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 29/10/2020.
//

import Foundation

@objcMembers
public class PXButton: Codable {
    let action: String?
    let target: String?
    let type: String
    let label: String
}
