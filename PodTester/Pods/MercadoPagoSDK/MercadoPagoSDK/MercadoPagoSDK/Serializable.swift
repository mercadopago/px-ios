//
//  Serializable.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 21/4/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import Foundation

open class Serializable: NSObject {
	
	/**
	Converts the class to a dictionary.
	- returns: The class as an NSDictionary.
	*/
	open func toDictionary() -> NSDictionary {
		let propertiesDictionary = NSMutableDictionary()
		let mirror = Mirror(reflecting: self)
		
		for (propName, propValue) in mirror.children {
			if let propValue: AnyObject = self.unwrap(propValue) as? AnyObject, let propName = propName {
				if let serializablePropValue = propValue as? Serializable {
					propertiesDictionary.setValue(serializablePropValue.toDictionary(), forKey: propName)
				} else if let arrayPropValue = propValue as? [Serializable] {
					var subArray = [NSDictionary]()
					for item in arrayPropValue {
						subArray.append(item.toDictionary())
					}
					
					propertiesDictionary.setValue(subArray, forKey: propName)
				} else if propValue is Int || propValue is Double || propValue is Float {
					propertiesDictionary.setValue(propValue, forKey: propName)
				} else if let dataPropValue = propValue as? Data {
					propertiesDictionary.setValue(dataPropValue.base64EncodedString(options: .lineLength64Characters), forKey: propName)
				} else if let boolPropValue = propValue as? Bool {
					propertiesDictionary.setValue(boolPropValue, forKey: propName)
				} else {
					propertiesDictionary.setValue(propValue, forKey: propName)
				}
			}
			else if let propValue:Int8 = propValue as? Int8 {
				propertiesDictionary.setValue(NSNumber(value: propValue as Int8), forKey: propName!)
			}
			else if let propValue:Int16 = propValue as? Int16 {
				propertiesDictionary.setValue(NSNumber(value: propValue as Int16), forKey: propName!)
			}
			else if let propValue:Int32 = propValue as? Int32 {
				propertiesDictionary.setValue(NSNumber(value: propValue as Int32), forKey: propName!)
			}
			else if let propValue:Int64 = propValue as? Int64 {
				propertiesDictionary.setValue(NSNumber(value: propValue as Int64), forKey: propName!)
			}
			else if let propValue:UInt8 = propValue as? UInt8 {
				propertiesDictionary.setValue(NSNumber(value: propValue as UInt8), forKey: propName!)
			}
			else if let propValue:UInt16 = propValue as? UInt16 {
				propertiesDictionary.setValue(NSNumber(value: propValue as UInt16), forKey: propName!)
			}
			else if let propValue:UInt32 = propValue as? UInt32 {
				propertiesDictionary.setValue(NSNumber(value: propValue as UInt32), forKey: propName!)
			}
			else if let propValue:UInt64 = propValue as? UInt64 {
				propertiesDictionary.setValue(NSNumber(value: propValue as UInt64), forKey: propName!)
			}
		}
		
		return propertiesDictionary
	}
	
	/**
	Converts the class to JSON.
	- returns: The class as JSON, wrapped in NSData.
	*/
	open func toJson(_ prettyPrinted : Bool = false) -> Data? {
		let dictionary = self.toDictionary()
		
		if JSONSerialization.isValidJSONObject(dictionary) {
			do {
				let json = try JSONSerialization.data(withJSONObject: dictionary, options: (prettyPrinted ? .prettyPrinted : JSONSerialization.WritingOptions()))
				return json
			} catch let error as NSError {
				print("ERROR: Unable to serialize json, error: \(error)", terminator: "\n")
				NotificationCenter.default.post(name: Notification.Name(rawValue: "CrashlyticsLogNotification"), object: self, userInfo: ["string": "unable to serialize json, error: \(error)"])
			}
		}
		
		return nil
	}
	
	/**
	Converts the class to a JSON string.
	- returns: The class as a JSON string.
	*/
	open func toJsonString(_ prettyPrinted : Bool = false) -> String? {
		if let jsonData = self.toJson(prettyPrinted) {
			return NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
		}
		
		return nil
	}
	
}

extension Serializable {
	
	/**
	Unwraps 'any' object. See http://stackoverflow.com/questions/27989094/how-to-unwrap-an-optional-value-from-any-type
	- returns: The unwrapped object.
	*/
	fileprivate func unwrap(_ any: Any) -> Any? {
		let mi = Mirror(reflecting: any)
		
		if mi.displayStyle != .optional {
			return any
		}
		
		if mi.children.count == 0 {
			return nil
		}
		
		let (_, some) = mi.children.first!
		
		return some
	}
}
