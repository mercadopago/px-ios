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
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let timestamp = formatter.string(from: date).replacingOccurrences(of: " ", with: "T")
        self.timestamp = timestamp
        self.type = "screenview"
    }
    func toJSON() -> [String:Any] {
        let obj: [String:Any] = [
            "timestamp": self.timestamp.replacingOccurrences(of: " ", with: "T"),
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

}
