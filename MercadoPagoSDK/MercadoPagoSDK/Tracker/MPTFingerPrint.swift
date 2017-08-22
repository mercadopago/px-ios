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
    var os: String
    var systemVersion: String
    var screenSize: String
    var resolution: String
    override init() {
        self.model = UIDevice.current.model
        self.os =  "iOS"
        self.systemVersion = UIDevice.current.systemVersion
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        self.screenSize = String(describing: screenWidth) + "x" + String(describing: screenHeight)
        self.resolution = String(describing: UIScreen.main.scale)
    }
    open func toJSON() -> [String:Any] {
        let obj: [String:Any] = [
            "model": model,
            "os": os,
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
    open func toJSON() -> [String:Any] {
        let obj: [String:Any] = [
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
    var timestamp: String
    var type: String
    var metadata: [String:Any]
    init(screenName: String, screenId: String, metadata: [String:Any]) {
        self.screenName = screenName
        self.screenId = screenId
        self.metadata = metadata
        for key in metadata.keys {
            if metadata[key] == nil {
                self.metadata.removeValue(forKey: key)
            }
        }

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        var timestampStr = formatter.string(from: date)
        self.timestamp = ScreenTrackInfo.formatTimestampString(timestamp:timestampStr)
        self.type = "screenview"
    }
    func toJSON() -> [String:Any] {
        var obj: [String:Any] = [
            "timestamp": ScreenTrackInfo.formatTimestampString(timestamp: self.timestamp),
            "type": self.type,
            "screen_id": self.screenId,
            "screen_name": self.screenName,
            "metadata": self.metadata
        ]
        return obj
    }
    init(from json: [String:Any]) {
        self.screenName = json["screen_name"] as! String
        self.screenId = json["screen_id"] as! String
        self.timestamp = json["timestamp"] as! String
        self.timestamp = self.timestamp .replacingOccurrences(of: "T", with: " ")
        self.type = json["type"] as! String
        self.metadata = json["metadata"] as! [String:Any]
    }
    func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    static func formatTimestampString(timestamp: String) -> String {
        var timestampResult = timestamp.replacingOccurrences(of: " AM", with: "X1")
        timestampResult = timestampResult.replacingOccurrences(of: " PM", with: "X2")
        timestampResult = timestampResult.replacingOccurrences(of: " ", with: "T")
        timestampResult = timestampResult.replacingOccurrences(of: "X1", with: " AM")
        timestampResult = timestampResult.replacingOccurrences(of: "X2", with: " PM")
        return timestampResult
    }

}
