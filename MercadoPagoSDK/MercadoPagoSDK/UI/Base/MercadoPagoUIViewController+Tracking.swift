//
//  MercadoPagoUIViewController+Tracking.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 03/12/2018.
//

import Foundation
// MARK: Tracking
extension MercadoPagoUIViewController {

    func trackScreen(event: TrackingEvents, treatBackAsAbort: Bool = false, treatAsViewController: Bool = true) {
        if treatAsViewController {
            self.treatBackAsAbort = treatBackAsAbort
            screenPath = event.name
        }
        MPXTracker.sharedInstance.trackScreen(event: event)
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
