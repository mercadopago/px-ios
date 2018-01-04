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
    var trackListener: MPTrackListener?
    var public_key: String = ""
    var sdkVersion = ""

    static let kTrackingSettings = "tracking_settings"
    private static let kTrackingEnabled = "tracking_enabled"
    var trackingStrategy: TrackingStrategy = RealTimeStrategy()

    open class func setPublicKey(_ public_key: String) {
        sharedInstance.public_key = public_key.trimSpaces()
    }

    open class func setSdkVersion(_ version: String) {
        sharedInstance.sdkVersion = version
    }

    open func getPublicKey() -> String! {
        return self.public_key
    }

    open func getSdkVersion() -> String {
        return sdkVersion
    }

    open func getPlatformType() -> String {
        return "native/ios"
    }

    open static func trackScreen(screenId: String, screenName: String, metadata: [String : String?] = [:]) {
        if let trackListener = sharedInstance.trackListener {
            trackListener.trackScreen(screenName: screenName)
        }
        if !isEnabled() {
            return
        }
        setTrackingStrategy(screenID: screenId)
        let screenTrack = ScreenTrackInfo(screenName: screenName, screenId: screenId, metadata: metadata)
        sharedInstance.trackingStrategy.trackScreen(screenTrack: screenTrack)
    }

    open static func setTrackingStrategy(screenID: String) {
        let forcedScreens: [String] = [TrackingUtil.SCREEN_ID_PAYMENT_RESULT,
                                       TrackingUtil.SCREEN_ID_PAYMENT_RESULT_APPROVED,
                                       TrackingUtil.SCREEN_ID_PAYMENT_RESULT_PENDING,
                                       TrackingUtil.SCREEN_ID_PAYMENT_RESULT_REJECTED,
                                       TrackingUtil.SCREEN_ID_PAYMENT_RESULT_INSTRUCTIONS,
                                       TrackingUtil.SCREEN_ID_ERROR]
        if forcedScreens.contains(screenID) {
            sharedInstance.trackingStrategy = ForceTrackStrategy()
        } else {
            sharedInstance.trackingStrategy = BatchStrategy()
        }
    }

    static func generateJSONDefault() -> [String:Any] {
        let clientId = UIDevice.current.identifierForVendor!.uuidString
        let deviceJSON = MPTDevice().toJSON()
        let applicationJSON = MPTApplication(publicKey: MPXTracker.sharedInstance.getPublicKey(), checkoutVersion: MPXTracker.sharedInstance.getSdkVersion(), platform: MPXTracker.sharedInstance.getPlatformType()).toJSON()
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
        let timestamp = Date().getCurrentMillis()
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
        let timestamp = Date().getCurrentMillis()
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
