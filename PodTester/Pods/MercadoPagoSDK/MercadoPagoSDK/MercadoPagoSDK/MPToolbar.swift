//
//  MPToolbar.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 27/5/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

open class MPToolbar : UIToolbar {

	var textFieldContainer : UITextField?
	var keyboardDelegate: KeyboardDelegate?
	
	public init(prevEnabled: Bool, nextEnabled: Bool, delegate: KeyboardDelegate, textFieldContainer: UITextField) {

		super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
		
		self.keyboardDelegate = delegate
		self.textFieldContainer = textFieldContainer
		
		self.barStyle = UIBarStyle.default
		self.isTranslucent = true
		self.sizeToFit()
		var items : [UIBarButtonItem] = []
		
		//  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
		let doneButton = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MPToolbar.done))
		
		let prev = UIBarButtonItem(image: MercadoPago.getImage("IQButtonBarArrowLeft"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MPToolbar.prev))
		
		let fixed = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
		fixed.width = 23
		
		let next = UIBarButtonItem(image: MercadoPago.getImage("IQButtonBarArrowRight"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(getter: MPToolbar.next))
		
		prev.isEnabled = prevEnabled
		next.isEnabled = nextEnabled
		
		items.append(prev)
		items.append(fixed)
		items.append(next)
		
		//  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
		let nilButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
		
		items.append(nilButton)
		items.append(doneButton)
		
		//  Adding button to toolBar.
		self.items = items
		
		switch textFieldContainer.keyboardAppearance {
		case UIKeyboardAppearance.dark:
			self.barStyle = UIBarStyle.black
		default:
			self.barStyle = UIBarStyle.default
		}
		
		textFieldContainer.inputAccessoryView = self
		
		
	}
	
	func prev() {
		keyboardDelegate?.prev(textFieldContainer)
	}
	
	func next() {
		keyboardDelegate?.next(textFieldContainer)
	}
	
	func done() {
		keyboardDelegate?.done(textFieldContainer)
	}

	required public init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
