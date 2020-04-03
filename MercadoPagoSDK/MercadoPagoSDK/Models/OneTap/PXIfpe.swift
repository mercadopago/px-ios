//
//  PXIfpe.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 27/03/2020.
//

import Foundation

public struct PXIfpe: Codable {

    let isCompliant: Bool
    let hasBackoffice: Bool

    enum CodingKeys: String, CodingKey {
        case isCompliant = "is_compliant"
        case hasBackoffice = "has_backoffice"
    }
}
