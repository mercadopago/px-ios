//
//  Fingerprint.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class Fingerprint: NSObject {

    open var fingerprint: [String : Any]

    public override init () {
        self.fingerprint = [:]
        super.init()
        fingerprint = deviceFingerprint()

    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String : Any] {

        let obj: [String:Any] = [
            "os": fingerprint["os"] as Any,
            "vendor_ids": fingerprint["vendor_ids"] as Any,
            "model": fingerprint["model"] as Any,
            "system_version": fingerprint["system_version"] as Any,
            "resolution": fingerprint["resolution"] as Any,
            "vendor_specific_attributes": fingerprint["vendor_specific_attributes"] as Any
        ]
        return obj
    }

    open func deviceFingerprint() -> [String : AnyObject] {
        let device: UIDevice = UIDevice.current
        var dictionary: [String : AnyObject] = [String: AnyObject]()
		dictionary["os"] = "iOS" as AnyObject?
		let devicesId: [AnyObject]? = devicesID()
        if devicesId != nil {
            dictionary["vendor_ids"] = devicesId! as AnyObject?
        }

        if !String.isNullOrEmpty(device.model) {
            dictionary["model"] = device.model as AnyObject?
        }

        dictionary["os"] = "iOS" as AnyObject?

        if !String.isNullOrEmpty(device.systemVersion) {
            dictionary["system_version"] = device.systemVersion as AnyObject?
        }

        let screenSize: CGRect = UIScreen.main.bounds
        let width = NSString(format: "%.0f", screenSize.width)
        let height = NSString(format: "%.0f", screenSize.height)

        dictionary["resolution"] =  "\(width)x\(height)" as AnyObject?

		var moreData = [String: AnyObject]()

        if device.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            moreData["device_idiom"] = "Pad" as AnyObject?
        } else {
            moreData["device_idiom"] = "Phone" as AnyObject?
        }

            moreData["can_send_sms"] = 1 as AnyObject?

            moreData["can_make_phone_calls"] = 1 as AnyObject?

        if Locale.preferredLanguages.count > 0 {
            moreData["device_language"] = Locale.preferredLanguages[0] as AnyObject?
        }

        if !String.isNullOrEmpty(device.model) {
            moreData["device_model"] = device.model as AnyObject?
        }

        if !String.isNullOrEmpty(device.name) {
            moreData["device_name"] = device.name as AnyObject?
        }

		moreData["simulator"] = 0 as AnyObject?

        dictionary["vendor_specific_attributes"] = moreData as AnyObject?

		return dictionary

    }

    open func devicesID() -> [AnyObject]? {
        let systemVersionString: String = UIDevice.current.systemVersion
        let systemVersion: Float = (systemVersionString.components(separatedBy: ".")[0] as NSString).floatValue
        if systemVersion < 6 {
            let uuid: String = UUID().uuidString
            if !String.isNullOrEmpty(uuid) {

                var dic: [String : AnyObject] = ["name": "uuid" as AnyObject]
                dic["value"] = uuid as AnyObject?
                return [dic as AnyObject]
            }
        } else {
            let vendorId: String = UIDevice.current.identifierForVendor!.uuidString
            let uuid: String = UUID().uuidString

            var dicVendor: [String : AnyObject] = ["name": "vendor_id" as AnyObject]
            dicVendor["value"] = vendorId as AnyObject?
            var dic: [String : AnyObject] = ["name": "uuid" as AnyObject]
            dic["value"] = uuid as AnyObject?
            return [dicVendor as AnyObject, dic as AnyObject]
        }
        return nil
    }

}
