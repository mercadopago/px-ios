//
//  MPXTracker.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/1/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

@objc
public protocol MPTrackListener {
    func trackScreen(screenName: String)
    func trackEvent(screenName: String?, action: String!, result: String?, extraParams: [String:String]?)
}

public class MPXTracker: NSObject {

    static let sharedInstance = MPXTracker()

    static let TRACKING_URL = "https://api.mercadopago.com/beta/checkout/tracking/events"
    static let kTrackingSettings = "tracking_settings"
    private static let kTrackingEnabled = "tracking_enabled"

    var trackListener: MPTrackListener?

    var trackingStrategy: TrackingStrategy = RealTimeStrategy()

    static func trackScreen(screenId: String, screenName: String, metadata: [String : String?] = [:]) {
        if let trackListener = sharedInstance.trackListener {
            trackListener.trackScreen(screenName: screenName)
        }
        if !isEnabled() {
            return
        }
        let screenTrack = ScreenTrackInfo(screenName: screenName, screenId: screenId, metadata: metadata)
        sharedInstance.trackingStrategy.trackScreen(screenTrack: screenTrack)
    }

    static func generateJSONDefault() -> [String:Any] {
        let clientId = UIDevice.current.identifierForVendor!.uuidString
        let deviceJSON = MPTDevice().toJSON()
        let applicationJSON = MPTApplication(publicKey: MercadoPagoContext.sharedInstance.publicKey(), checkoutVersion: MercadoPagoContext.sharedInstance.sdkVersion(), platform: MercadoPagoContext.platformType).toJSON()
        let obj: [String:Any] = [
            "client_id": clientId,
            "application": applicationJSON,
            "device": deviceJSON,
            ]
        return obj
    }
    static func generateJSONScreen(screenId: String, screenName: String, metadata: [String:Any]) -> [String:Any] {
        var obj = generateJSONDefault()
        let screenJSON = MPXTracker.screenJSON(screenId: screenId, screenName: screenName, metadata:metadata)
        obj["events"] = [screenJSON]
        return obj
    }
    static func generateJSONEvent(screenId: String, screenName: String, action: String, category: String, label: String, value: String) -> [String:Any] {
        var obj = generateJSONDefault()
        let eventJSON = MPXTracker.eventJSON(screenId: screenId, screenName: screenName, action: action, category: category, label: label, value: value)
        obj["events"] = [eventJSON]
        return obj
    }
    static func eventJSON(screenId: String, screenName: String, action: String, category: String, label: String, value: String) -> [String:Any] {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let timestamp = formatter.string(from: date).replacingOccurrences(of: " ", with: "T")
        let obj: [String:Any] = [
            "timestamp": timestamp,
            "type": "action",
            "screen_id": screenId,
            "screen_name": screenName,
            "action": action,
            "category": category,
            "label": label,
            "value": value
        ]
        return obj
    }
    static func screenJSON(screenId: String, screenName: String, metadata: [String:Any]) -> [String:Any] {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let timestamp = formatter.string(from: date).replacingOccurrences(of: " ", with: "T")
        let obj: [String:Any] = [
            "timestamp": timestamp,
            "type": "screenview",
            "screen_id": screenId,
            "screen_name": screenName,
            "metadata": metadata
        ]
        return obj
    }

    static func isEnabled() -> Bool {
        guard let trackiSettings: [String:Any] = Utils.getSetting(identifier: MPXTracker.kTrackingSettings) else {
            return false
        }
        guard let trackingEnabled = trackiSettings[MPXTracker.kTrackingEnabled] as? Bool else {
            return false
        }
        return trackingEnabled
    }

    open class func setTrack(listener: MPTrackListener) {
        MPXTracker.sharedInstance.trackListener = listener
    }
    open static func getTrackListener() -> MPTrackListener? {
        return sharedInstance.trackListener
    }
}
