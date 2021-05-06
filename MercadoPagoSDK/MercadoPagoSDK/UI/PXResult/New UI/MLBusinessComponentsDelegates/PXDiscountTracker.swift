//
//  PXDiscountTracker.swift
//  MercadoPagoSDK
//
//  Created by Vicente Veltri on 07/02/2020.
//

import Foundation
import MLBusinessComponents

public class PXDiscountTracker: NSObject, MLBusinessDiscountTrackerProtocol {

    let basePath = "/discount_center/payers/touchpoint"
    var touchPointId: String?

    init(touchPointId: String) {
        self.touchPointId = touchPointId
    }

    public override init() { }

    public func setTouchpointId(with touchPointId: String) {
        self.touchPointId = touchPointId
    }

    public func track(action: String, eventData: [String: Any]) {
        guard let touchPointId = touchPointId else { return }
        MPXTracker.sharedInstance.trackEvent(event: PXDiscountTrackingEvents.discount(touchPointId, action, eventData))
    }
}
