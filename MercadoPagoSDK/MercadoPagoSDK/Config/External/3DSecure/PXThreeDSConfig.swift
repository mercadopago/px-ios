//
//  PXThreeDSConfig.swift
//  MercadoPagoSDKV4
//
//  Created by Eric Ertl on 04/03/2021.
//

import Foundation

/**
 Whe use this object to store properties related to ESC module.
Check PXESCProtocol methods.
 */
@objcMembers
open class PXThreeDSConfig: NSObject {
    public let flowIdentifier: String
    public let sessionId: String
    public let privateKey: String?

    init(flowIdentifier: String, sessionId: String, privateKey: String?) {
        self.flowIdentifier = flowIdentifier
        self.sessionId = sessionId
        self.privateKey = privateKey
    }
}

// MARK: Internals (Only PX)
internal extension PXThreeDSConfig {
    static func createConfig(privateKey: String? = nil) -> PXThreeDSConfig {
        let flowIdentifier = MPXTracker.sharedInstance.getFlowName() ?? "PX"
        let sessionId = MPXTracker.sharedInstance.getSessionID()
        let defaultConfig = PXThreeDSConfig(flowIdentifier: flowIdentifier, sessionId: sessionId, privateKey: privateKey)
        return defaultConfig
    }
}
