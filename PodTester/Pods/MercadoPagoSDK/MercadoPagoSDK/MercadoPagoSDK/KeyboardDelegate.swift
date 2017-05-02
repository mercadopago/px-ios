//
//  KeyboardDelegate.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 22/5/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import Foundation

public protocol KeyboardDelegate : NSObjectProtocol {
	func prev(_ object: AnyObject?)
	func next(_ object: AnyObject?)
	func done(_ object: AnyObject?)
}
