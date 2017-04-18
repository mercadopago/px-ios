//
//  UILoadingView.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 30/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import UIKit

open class UILoadingView : UIView {
	
	public init(frame rect: CGRect, text: String = "Cargando...".localized) {
		super.init(frame: rect)
		self.backgroundColor = UIColor.px_white()
		self.label.text = text as String
		self.label.textColor = self.spinner.color
		self.spinner.startAnimating()
		
		self.addSubview(self.label)
		self.addSubview(self.spinner)
		
		//	self.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
		
		self.setNeedsLayout()
		
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	open var label : MPLabel = {
		var l = MPLabel()
		//l.font = UIFont(name: "HelveticaNeue", size: 15)
		return l
		}()
	open var spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
	
	override open func layoutSubviews() {
		self.label.sizeToFit()
		let labelSize: CGSize = self.label.frame.size
		var labelFrame: CGRect = CGRect()
		labelFrame.size = labelSize
		self.label.frame = labelFrame
		
		// center label and spinner
		self.label.center = self.center
		self.spinner.center = self.center
		
		// horizontally align
		labelFrame = self.label.frame
		var spinnerFrame: CGRect = self.spinner.frame
		let totalWidth: CGFloat = spinnerFrame.size.width + 5 + labelSize.width
		spinnerFrame.origin.x = self.bounds.origin.x + (self.bounds.size.width - totalWidth) / 2
		labelFrame.origin.x = spinnerFrame.origin.x + spinnerFrame.size.width + 5
		self.label.frame = labelFrame
		self.spinner.frame = spinnerFrame
	}
	
}
