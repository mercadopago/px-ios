//
//  MPXTracker.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/1/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

@objc internal class MPXTracker: NSObject {
    @objc internal static let sharedInstance = MPXTracker()
    private var trackListener: PXTrackerListener?
    private var flowDetails: [String: Any]?
    private var flowName: String?
    private var customSessionId: String?
    private var sessionService: SessionService = SessionService()
    private var experiments: [PXExperiment]?
}

// MARK: Getters/setters.
internal extension MPXTracker {

    func setTrack(listener: PXTrackerListener) {
        if isPXAddonTrackListener() {
            return
        }
        trackListener = listener
    }

    func setFlowDetails(flowDetails: [String: Any]?) {
        self.flowDetails = flowDetails
    }

    func setFlowName(name: String?) {
        self.flowName = name
    }

    func setCustomSessionId(_ customSessionId: String?) {
        self.customSessionId = customSessionId
    }

    func startNewSession() {
        sessionService.startNewSession()
    }

    func startNewSession(externalSessionId: String) {
        sessionService.startNewSession(externalSessionId: externalSessionId)
    }

    func getSessionID() -> String {
        return customSessionId ?? sessionService.getSessionId()
    }

    func getRequestId() -> String {
        return sessionService.getRequestId()
    }

    func clean() {
        if !isPXAddonTrackListener() {
            MPXTracker.sharedInstance.trackListener = nil
        }
        MPXTracker.sharedInstance.flowDetails = [:]
        MPXTracker.sharedInstance.experiments = nil
    }

    func getFlowName() -> String? {
        return flowName
    }

    func setExperiments(_ experiments: [PXExperiment]?) {
        MPXTracker.sharedInstance.experiments = experiments
    }

    private func isPXAddonTrackListener() -> Bool {
        if let trackListener = trackListener,
            String(describing: trackListener.self).contains("PXAddon.PXTrack") {
            return true
        }
        return false
    }
}

// MARK: Public interfase.
internal extension MPXTracker {
    func trackScreen(screenName: String, properties: [String: Any] = [:]) {
        if let trackListenerInterfase = trackListener {
            var metadata = properties
            if let flowDetails = flowDetails {
                metadata["flow_detail"] = flowDetails
            }
            if let flowName = flowName {
                metadata["flow"] = flowName
            }
            if let experiments = experiments {
                metadata["experiments"] = PXExperiment.getExperimentsForTracking(experiments)
            }
            metadata[SessionService.SESSION_ID_KEY] = getSessionID()
            metadata["security_enabled"] = PXConfiguratorManager.hasSecurityValidation()
            metadata["session_time"] = PXTrackingStore.sharedInstance.getSecondsAfterInit()
            if let checkoutType = PXTrackingStore.sharedInstance.getChoType() {
                metadata["checkout_type"] = checkoutType
            }
            trackListenerInterfase.trackScreen(screenName: screenName, extraParams: metadata)
        }
    }

    func trackEvent(path: String, properties: [String: Any] = [:]) {
        if let trackListenerInterfase = trackListener {
            var metadata = properties
            let checkoutType: String? = PXTrackingStore.sharedInstance.getChoType()
            if path != TrackingPaths.Events.getErrorPath() {
                if let flowDetails = flowDetails {
                    metadata["flow_detail"] = flowDetails
                }
                if let flowName = flowName {
                    metadata["flow"] = flowName
                }
                metadata[SessionService.SESSION_ID_KEY] = getSessionID()
                metadata["checkout_type"] = checkoutType
            } else {
                if let extraInfo = metadata["extra_info"] as? [String: Any] {
                    var frictionExtraInfo: [String: Any] = extraInfo
                    frictionExtraInfo["flow_detail"] = flowDetails
                    frictionExtraInfo["flow"] = flowName
                    frictionExtraInfo[SessionService.SESSION_ID_KEY] = getSessionID()
                    frictionExtraInfo["checkout_type"] = checkoutType
                    metadata["extra_info"] = frictionExtraInfo
                } else {
                    var frictionExtraInfo: [String: Any] = [:]
                    frictionExtraInfo["flow_detail"] = flowDetails
                    frictionExtraInfo["flow"] = flowName
                    frictionExtraInfo[SessionService.SESSION_ID_KEY] = getSessionID()
                    frictionExtraInfo["checkout_type"] = checkoutType
                    metadata["extra_info"] = frictionExtraInfo
                }
            }
            if let experiments = experiments {
                metadata["experiments"] = PXExperiment.getExperimentsForTracking(experiments)
            }
            metadata["security_enabled"] = PXConfiguratorManager.hasSecurityValidation()
            metadata["session_time"] = PXTrackingStore.sharedInstance.getSecondsAfterInit()
            trackListenerInterfase.trackEvent(screenName: path, action: "", result: "", extraParams: metadata)
        }
    }
}
