//
//  MPUserIdTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 30/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


open class MPUserIdTableViewCell : ErrorTableViewCell, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak fileprivate var userIdTypeLabel: MPLabel!
    @IBOutlet weak fileprivate var userIdValueLabel: MPLabel!
    @IBOutlet weak open var userIdTypeTextField: UITextField!
    @IBOutlet weak open var userIdValueTextField: UITextField!
    
    @IBOutlet open var pickerIdentificationType: UIPickerView! = UIPickerView()
    
    open var identificationTypes : [IdentificationType] = [IdentificationType]()
    open var identificationType : IdentificationType?
	
	open override func focus() {
		if !self.userIdTypeTextField.isFirstResponder {
			self.userIdTypeTextField.becomeFirstResponder()
		}
	}
	
	override public init(style: UITableViewCellStyle, reuseIdentifier: String!) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		pickerIdentificationType.isHidden = true
	}
	
    // returns the number of 'columns' to display.
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return identificationTypes.count
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return identificationTypes[row].name
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        setFormWithIndex(row)
        pickerIdentificationType.isHidden = true
        userIdTypeTextField.resignFirstResponder()
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.userIdTypeTextField {
            pickerIdentificationType.isHidden = false
        }
        return true
    }
    
    open func textField(_ textField: UITextField,shouldChangeCharactersIn range: NSRange,    replacementString string: String) -> Bool {
        if textField == self.userIdValueTextField {
            
            if identificationType != nil && (((identificationType!.type! == "number" && !Regex("^[0-9]$").test(string)) ||
            (identificationType!.type! != "number" && Regex("^[0-9]$").test(string))) && string != "") {
                return false
            }
			if textField.text != nil {
				var txtAfterUpdate: NSString = textField.text! as NSString
				txtAfterUpdate = txtAfterUpdate.replacingCharacters(in: range, with: string) as NSString
				if txtAfterUpdate.length <= self.identificationType?.maxLength {
					return true
				}
			}
            return false
        }
        return false
    }
    
    open func setFormWithIndex(_ row: Int) {
        identificationType = identificationTypes[row]
        if identificationType != nil && identificationType!.type! == "number" {
            userIdValueTextField.keyboardType = UIKeyboardType.numberPad
        } else {
            userIdValueTextField.keyboardType = UIKeyboardType.default
        }
        userIdTypeTextField.text = identificationTypes[row].name
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
		self.userIdTypeLabel.text = "Tipo".localized
		self.userIdValueLabel.text = "Documento".localized
        pickerIdentificationType = UIPickerView()
        pickerIdentificationType.delegate = self
        pickerIdentificationType.dataSource = self
        self.userIdTypeTextField.inputView = pickerIdentificationType
        self.userIdTypeTextField.delegate = self
        self.userIdValueTextField.delegate = self
		
		//self.userIdValueTextField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: Selector("prev"), nextAction: Selector("next"), doneAction: Selector("done"), titleText: "Tipo".localized + " - " + "Documento".localized)
		
    }
    
    open func _setIdentificationTypes(_ identificationTypes: [IdentificationType]?) {
        if identificationTypes != nil {
            self.identificationTypes = identificationTypes!
            setFormWithIndex(0)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        pickerIdentificationType.isHidden = true
    }
    
    open func getUserIdType() -> String! {
        return self.userIdTypeTextField.text
    }

    open func getUserIdValue() -> String! {
        return self.userIdValueTextField.text
    }
    
    open func setTextFieldDelegate(_ delegate : UITextFieldDelegate) {
        self.userIdValueTextField.delegate = delegate
    }
    
}
