//
//  MPCardNumberTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 29/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class MPCardNumberTableViewCell : ErrorTableViewCell, UITextFieldDelegate {
    @IBOutlet weak fileprivate var cardNumberLabel: MPLabel!
    @IBOutlet weak fileprivate var cardNumberImageView: UIImageView!
    @IBOutlet weak open var cardNumberTextField: MPTextField!
    open var setting : Setting!
	
	open var keyboardDelegate : KeyboardDelegate!
	
	func next() {
		keyboardDelegate?.next(self)
	}
	
	func prev() {
		keyboardDelegate?.prev(self)
	}
	
	func done() {
		keyboardDelegate?.done(self)
	}
	
	open override func focus() {
		if !self.cardNumberTextField.isFirstResponder {
			self.cardNumberTextField.becomeFirstResponder()
		}
	}
	
    override public init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
		self.cardNumberLabel.text = "Número de tarjeta".localized
		
		//self.cardNumberTextField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: Selector("prev"), nextAction: Selector("next"), doneAction: Selector("done"), titleText: "Número de tarjeta".localized)
		
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func getCardNumber() -> String! {
        return self.cardNumberTextField.text!.replacingOccurrences(of: " ", with:"")
    }
    
    open func setIcon(_ pmId : String?) {
        if String.isNullOrEmpty(pmId) {
            self.cardNumberImageView.isHidden = true
        } else {
            self.cardNumberImageView.image = MercadoPago.getImage("icoTc_" + pmId!)
            self.cardNumberImageView.isHidden = false
        }
    }
    
    open func _setSetting(_ setting: Setting!) {
        self.setting = setting
        self.cardNumberTextField.delegate = self
    }
    
    open func setTextFieldDelegate(_ delegate : UITextFieldDelegate) {
        self.cardNumberTextField.delegate = delegate
    }
    
    open func textField(_ textField: UITextField,shouldChangeCharactersIn range: NSRange,    replacementString string: String) -> Bool {
        
        if !Regex("^[0-9]$").test(string) && string != "" {
            return false
        }
        
        var maxLength = 16
        var spaces = 3
        maxLength = self.setting.cardNumber!.length
        if maxLength == 15 {
            spaces = 2
        }
        
		
		if textField.text != nil {
			var txtAfterUpdate : NSString = textField.text! as NSString
			txtAfterUpdate = txtAfterUpdate.replacingCharacters(in: range, with: string) as NSString
			if txtAfterUpdate.length <= maxLength+spaces {
				if txtAfterUpdate.length > 4 {
					let cardNumber : NSString = txtAfterUpdate.replacingOccurrences(of: " ", with:"") as NSString
					if maxLength == 16 {
						// 4 4 4 4
						let mutableString : NSMutableString = NSMutableString(capacity: maxLength + spaces)
						for i in 0...(cardNumber.length-1) {
							if i > 0 && i%4 == 0 {
								mutableString.appendFormat(" %C", cardNumber.character(at: i))
							} else {
								mutableString.appendFormat("%C", cardNumber.character(at: i))
							}
						}
						self.cardNumberTextField.text = mutableString as String
						return false
					} else if maxLength == 15 {
						// 4 6 5
						let mutableString : NSMutableString = NSMutableString(capacity: maxLength + spaces)
						for i in 0...(cardNumber.length-1) {
							if i == 4 || i == 10 {
								mutableString.appendFormat(" %C", cardNumber.character(at: i))
							} else {
								mutableString.appendFormat("%C", cardNumber.character(at: i))
							}
						}
						self.cardNumberTextField.text = mutableString as String
						return false
					}
				}
				return true
			}
		}
        return false
    }
	
}
