//
//  MercadoPagoUIViewController+Tracking.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 03/12/2018.
//

import Foundation
// MARK: Tracking
extension MercadoPagoUIViewController {

    func trackScreen(path: String, properties: [String: Any] = [:], treatBackAsAbort: Bool = false, treatAsViewController: Bool = true) {
        if treatAsViewController {
            self.treatBackAsAbort = treatBackAsAbort
            screenPath = path
        }
        MPXTracker.sharedInstance.trackScreen(screenName: path, properties: properties)
    }

    func trackEvent(path: String, properties: [String: Any] = [:]) {
        MPXTracker.sharedInstance.trackEvent(path: path, properties: properties)
    }

    func trackAbortEvent(properties: [String: Any] = [:]) {
        if let screenPath = screenPath {
            trackEvent(path: TrackingPaths.Events.getAbortPath(screen: screenPath), properties: properties)
        }
    }

    func trackBackEvent() {
        if let screenPath = screenPath {
            trackEvent(path: TrackingPaths.Events.getBackPath(screen: screenPath))
        }
    }
}
