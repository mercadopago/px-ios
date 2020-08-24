//
//  PXESCConfig.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 20/08/2020.
//

import Foundation

/**
 Whe use this object to store properties related to ESC module.
Check PXESCProtocol methods.
 */
@objcMembers
open class PXESCConfig: NSObject {
    public let flowIdentifier: String
    public let sessionId: String

    init(_ flowIdentifier: String, _ sessionId: String) {
        self.flowIdentifier = flowIdentifier
        self.sessionId = sessionId
    }
}

// MARK: Internals (Only PX)
internal extension PXESCConfig {
    static func createConfig(withFlowIdentifier: String? = nil) -> PXESCConfig {
        var flowIdentifier = MPXTracker.sharedInstance.getFlowName() ?? "PX"
        if let withFlowIdentifier = withFlowIdentifier {
            flowIdentifier = withFlowIdentifier
        }
        var defaultConfig = PXESCConfig(flowIdentifier, MPXTracker.sharedInstance.getSessionID())
        return defaultConfig
    }
}
