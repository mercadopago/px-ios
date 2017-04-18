//
//  UIDevice+Additions.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 29/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

enum UIDeviceFamily : Int {
	case uiDeviceFamilyiPhone = 0, uiDeviceFamilyiPod, uiDeviceFamilyiPad, uiDeviceFamilyAppleTV, uiDeviceFamilyUnknown
}

extension UIDevice {

    /*
	var cameraAvailable: Bool {
		return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
	}
	
	var videoCameraAvailable: Bool {
		let picker : UIImagePickerController = UIImagePickerController()
		let sourceTypes : Array? = UIImagePickerController.availableMediaTypes(for: picker.sourceType)
		if sourceTypes == nil {
			return false
		}
		return true // TODO:! contains(sourceTypes, kUTTypeMovie)
	}
	
	var frontCameraAvailable: Bool {
		#if __IPHONE_4_0
		return UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front)
		#else
		return false
		#endif
	}
	
	var cameraFlashAvailable: Bool {
		#if __IPHONE_4_0
			return UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear)
			#else
			return false
		#endif
	}
	
	var canMakePhoneCalls: Bool {
		return UIApplication.shared.canOpenURL(URL(string: "tel://")!)
	}
	
	var retinaDisplayCapable: Bool {
		var scale : CGFloat = CGFloat(1.0)
		let screen : UIScreen = UIScreen.main
		if screen.responds(to: #selector(NSDecimalNumberBehaviors.scale)) {
			scale = screen.scale
		}
		
		if scale == 2.0 {
			return true
		} else {
			return false
		}
	}
	
	var canSendSMS: Bool {
		#if __IPHONE_4_0
			return MFMessageComposeViewController.canSendText()
		#else
			return UIApplication.shared.canOpenURL(URL(string: "sms://")!)
		#endif
	}
	
	var totalDiskSpace: NSNumber? {
		do {
			let fattributes : NSDictionary = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) as NSDictionary
			return fattributes.object(forKey: FileAttributeKey.systemSize) as? NSNumber
		} catch {
			return nil
		}
	}
	
	var freeDiskSpace: NSNumber? {
		do {
			let fattributes : NSDictionary = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) as NSDictionary
			return fattributes.object(forKey: FileAttributeKey.systemFreeSize) as? NSNumber
		} catch {
			return nil
		}
	}
	
	var platform: String {
		var size : Int = 0
		sysctlbyname("hw.machine", nil, &size, nil, 0)
		var machine = [CChar](repeating: 0, count: Int(size))
		sysctlbyname("hw.machine", &machine, &size, nil, 0)
		return String(cString: machine)
	}
	
	var hwmodel: String {
		var size : Int = 0
		sysctlbyname("hw.model", nil, &size, nil, 0)
		var model = [CChar](repeating: 0, count: Int(size))
		sysctlbyname("hw.model", &model, &size, nil, 0)
		return String(cString: model)
	}
	
	var totalMemory: Int {
		var size : Int = 0
		sysctlbyname("hw.physmem", nil, &size, nil, 0)
		var physmem : Int = 0
		sysctlbyname("hw.physmem", &physmem, &size, nil, 0)
		return physmem
	}
	
	var cpuCount: Int {
		var size : Int = 0
		sysctlbyname("hw.ncpu", nil, &size, nil, 0)
		var ncpu : Int = 0
		sysctlbyname("hw.ncpu", &ncpu, &size, nil, 0)
		return ncpu
	}
	
	var deviceFamily: UIDeviceFamily {
		let platform = self.platform
		if platform.hasPrefix("iPhone") {
			return UIDeviceFamily.uiDeviceFamilyiPhone
		}
		if platform.hasPrefix("iPod") {
			return UIDeviceFamily.uiDeviceFamilyiPod
		}
		if platform.hasPrefix("iPad") {
			return UIDeviceFamily.uiDeviceFamilyiPad
		}
		if platform.hasPrefix("AppleTV") {
			return UIDeviceFamily.uiDeviceFamilyAppleTV
		}
		
		return UIDeviceFamily.uiDeviceFamilyUnknown
	}
	*/ 
}
