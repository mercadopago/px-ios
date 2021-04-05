//
//  PXStatus.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/11/2019.
//

import Foundation

public struct PXStatus: Codable {
    let mainMessage: PXText?
    let secondaryMessage: PXText?
    let enabled: Bool
    let detail: String?

    enum CodingKeys: String, CodingKey {
        case mainMessage = "main_message"
        case secondaryMessage = "secondary_message"
        case enabled
        case detail
    }

    func isUsable() -> Bool {
        return enabled && !isSuspended()
    }

    func isDisabled() -> Bool {
        return !enabled
    }

    func isSuspended() -> Bool {
        return detail == "suspended"
    }
}
