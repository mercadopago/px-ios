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
    var touchPointId: String
    
    init(touchPointId: String) {
        self.touchPointId = touchPointId
    }
    
    public func track(action: String, eventData: [[String : Any]]) {
        let path = "\(basePath)/\(touchPointId)/\(action)"
        var properties: [String: Any] = [:]
        
        for dictionary in eventData {
            for item in dictionary {
                properties[item.key] = item.value
            }
        }
        
        MPXTracker.sharedInstance.trackEvent(path: path, properties: properties)
    }
    
}
