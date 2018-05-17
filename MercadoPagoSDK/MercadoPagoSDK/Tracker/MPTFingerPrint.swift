//
//  MPTDevice.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/1/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class MPTDevice: NSObject {
    var model: String
    var systemOs: String
    var systemVersion: String
    var screenSize: String
    var resolution: String
    override init() {
        self.model = UIDevice.current.model
        self.systemOs =  "iOS"
        self.systemVersion = UIDevice.current.systemVersion
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        self.screenSize = String(describing: screenWidth) + "x" + String(describing: screenHeight)
        self.resolution = String(describing: UIScreen.main.scale)
    }
    open func toJSON() -> [String: Any] {
        let obj: [String: Any] = [
            "model": model,
            "os": systemOs,
            "system_version": systemVersion,
            "screen_size": screenSize,
            "resolution": resolution
        ]
        return obj
    }
    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }
}

class MPTApplication: NSObject {
    var publicKey: String
    var checkoutVersion: String
    var platform: String
    init(publicKey: String, checkoutVersion: String, platform: String) {
        self.publicKey = publicKey
        self.checkoutVersion = checkoutVersion
        self.platform = platform
    }
    open func toJSON() -> [String: Any] {
        let obj: [String: Any] = [
            "public_key": publicKey,
            "checkout_version": checkoutVersion,
            "platform": platform
        ]
        return obj
    }
    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }
}

class ScreenTrackInfo {

    var screenName: String
    var screenId: String
    var timestamp: Int64
    var type: String
    var metadata: [String: Any]
    init(screenName: String, screenId: String, metadata: [String: Any]) {
        self.screenName = screenName
        self.screenId = screenId
        self.metadata = metadata
        for key in metadata.keys where metadata[key] == nil {
            self.metadata.removeValue(forKey: key)
        }

        let date = Date()
        self.timestamp = Date().getCurrentMillis()
        self.type = "screenview"
    }
    func toJSON() -> [String: Any] {
        var obj: [String: Any] = [
            "timestamp": self.timestamp,
            "type": self.type,
            "screen_id": self.screenId,
            "screen_name": self.screenName,
            "metadata": self.metadata
        ]
        return obj
    }
    init(from json: [String: Any]) {
        self.screenName = json["screen_name"] as? String
        self.screenId = json["screen_id"] as? String
        self.timestamp = json["timestamp"] as? Int64
        self.type = json["type"] as? String
        self.metadata = json["metadata"] as? [String: Any]
    }
    func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }
}

extension Date {
    public func getCurrentMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }

    static public func from(millis: Int64) -> Date {
        let timeInterval: TimeInterval = Double(millis) / 1000
        return Date(timeIntervalSince1970: timeInterval)
    }
}
