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

    func trackEvent(event: TrackingEvents) {
        MPXTracker.sharedInstance.trackEvent(event: event)
    }

    func trackAbortEvent(properties: [String: Any] = [:]) {
        if let screenPath = screenPath {
            trackEvent(event: MercadoPagoUITrackingEvents.didAbort(screenPath, properties))
        }
    }

    func trackBackEvent() {
        if let screenPath = screenPath {
            trackEvent(event: MercadoPagoUITrackingEvents.didGoBack(screenPath))
        }
    }
}
