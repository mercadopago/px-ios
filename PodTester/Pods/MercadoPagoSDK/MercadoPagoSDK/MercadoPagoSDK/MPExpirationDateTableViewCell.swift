//
//  MPExpirationDateTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 30/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class MPExpirationDateTableViewCell : ErrorTableViewCell, UITextFieldDelegate {
    @IBOutlet weak fileprivate var expirationDateLabel: MPLabel!
    @IBOutlet weak open var expirationDateTextField: MPTextField!
	
	open override func focus() {
		if !self.expirationDateTextField.isFirstResponder {
			self.expirationDateTextField.becomeFirstResponder()
		}
	}
	
    override public init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
		self.expirationDateLabel.text = "Válida hasta".localized
		self.expirationDateTextField.placeholder = "Mes / Año".localized
        self.expirationDateTextField.delegate = self
        self.expirationDateTextField.keyboardType = UIKeyboardType.numberPad
    }
    
    required public  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func getExpirationMonth() -> Int {
        if String.isNullOrEmpty(self.expirationDateTextField.text) {
            return 0
        }
		
		if self.expirationDateTextField.text != nil {
			var monthStr : String = self.expirationDateTextField.text!.characters.split {$0 == "/"}.map(String.init)[0] as String
			monthStr = monthStr.trimmingCharacters(in: CharacterSet.whitespaces) as String
			return monthStr.numberValue as! Int
		}
		return 0
    }
    
    open func getExpirationYear() -> Int {
        if String.isNullOrEmpty(self.expirationDateTextField.text) {
            return 0
        }
		
		if self.expirationDateTextField.text != nil {
			var yearStr : String = self.expirationDateTextField.text!.characters.split {$0 == "/"}.map(String.init)[1] as String
			yearStr = yearStr.trimmingCharacters(in: CharacterSet.whitespaces) as String
			return yearStr.numberValue as! Int
		}
		
        return 0
    }
    
    open func setTextFieldDelegate(_ delegate : UITextFieldDelegate) {
        self.expirationDateTextField.delegate = delegate
    }
    
    open func textField(_ textField: UITextField,shouldChangeCharactersIn range: NSRange,    replacementString string: String) -> Bool {
        
        if !Regex("^[0-9]$").test(string) && string != "" {
            return false
        }
		if textField.text != nil {
			var txtAfterUpdate : NSString = textField.text! as NSString
			txtAfterUpdate = txtAfterUpdate.replacingCharacters(in: range, with: string) as NSString
			var str : String = ""
			if txtAfterUpdate.length <= 7 {
				var date : NSString = txtAfterUpdate.replacingOccurrences(of: " ", with:"") as NSString
				date = date.replacingOccurrences(of: "/", with:"") as NSString
				if date.length >= 1 && date.length <= 4 {
					for i in 0...(date.length-1) {
						if i == 2 {
							str = str + " / "
						}
						str = str + String(format: "%C", date.character(at: i))
					}
				}
				self.expirationDateTextField.text = str
			}
		}
		
		return false
    }
}
