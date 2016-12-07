//
//  CardViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/1/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import UIKit
import MercadoPagoSDK

class CardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, KeyboardDelegate {
	var publicKey : String?
	
	@IBOutlet weak var tableView : UITableView!
	var cardNumberCell : MPCardNumberTableViewCell!
	var expirationDateCell : MPExpirationDateTableViewCell!
	var cardholderNameCell : MPCardholderNameTableViewCell!
	var userIdCell : MPUserIdTableViewCell!
	var securityCodeCell : SimpleSecurityCodeTableViewCell!
	
	var paymentMethod : PaymentMethod!
	
	var hasError : Bool = false
	var loadingView : UILoadingView!
	
	var identificationType : IdentificationType?
	var identificationTypes : [IdentificationType]?
	
	var callback : ((_ token : Token?) -> Void)?
	
	var isKeyboardVisible : Bool?
	var inputsCells : NSMutableArray!
	
	init(merchantPublicKey: String, paymentMethod: PaymentMethod, callback: @escaping (_ token: Token?) -> Void) {
		super.init(nibName: "CardViewController", bundle: nil)
		self.publicKey = merchantPublicKey
		self.paymentMethod = paymentMethod
		self.callback = callback
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.tableView.reloadData()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.loadingView = UILoadingView(frame: MercadoPago.screenBoundsFixedToPortraitOrientation(), text: "Cargando...".localized)
		self.view.addSubview(self.loadingView)
		self.title = "Datos de tu tarjeta".localized
		
		self.navigationItem.backBarButtonItem?.title = "Atrás"
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continuar".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(CardViewController.submitForm))
		
        let mercadoPago = MercadoPago(publicKey: self.publicKey!)
		mercadoPago.getIdentificationTypes({(identificationTypes: [IdentificationType]?) -> Void in
			self.identificationTypes = identificationTypes
			self.prepareTableView()
			self.tableView.reloadData()
			self.loadingView.removeFromSuperview()
			}, failure: { (error: NSError?) -> Void in
				self.prepareTableView()
				self.tableView.reloadData()
				self.loadingView.removeFromSuperview()
				self.userIdCell.isHidden = true
			}
		)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(CardViewController.willShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(CardViewController.willHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        

	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
	
	func willHideKeyboard(_ notification: Notification) {
		// resize content insets.
		let contentInsets = UIEdgeInsetsMake(64, 0.0, 0.0, 0)
		self.tableView.contentInset = contentInsets
		self.tableView.scrollIndicatorInsets = contentInsets
	}
	
	func willShowKeyboard(_ notification: Notification) {
		let s:NSValue? = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)
		let keyboardBounds :CGRect = s!.cgRectValue
		
		// resize content insets.
		let contentInsets = UIEdgeInsetsMake(64, 0.0, keyboardBounds.size.height, 0)
		self.tableView.contentInset = contentInsets
		self.tableView.scrollIndicatorInsets = contentInsets
	}
	
	@IBAction func submitForm() {
		self.view.addSubview(self.loadingView)
		let cardToken = CardToken(cardNumber: self.cardNumberCell.getCardNumber(), expirationMonth: self.expirationDateCell.getExpirationMonth(), expirationYear: self.expirationDateCell.getExpirationYear(), securityCode: self.securityCodeCell.getSecurityCode(), cardholderName: self.cardholderNameCell.getCardholderName(), docType: self.userIdCell.getUserIdType(), docNumber: self.userIdCell.getUserIdValue())
		if validateForm(cardToken) {
			createToken(cardToken)
		} else {
			self.loadingView.removeFromSuperview()
			self.hasError = true
			self.tableView.reloadData()
		}
	}
	
	func getIndexForObject(_ object: AnyObject) -> Int {
		var i = 0
		for arr in self.inputsCells {
			if let input = object as? UITextField {
				if let arrTextField = (arr as! NSArray)[0] as? UITextField {
					if input == arrTextField {
						return i
					}
				}
			}
			i = i + 1
		}
		return -1
	}
	
	func scrollToRow(_ indexPath: IndexPath) {
		self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
	}
	
	func focusAndScrollForIndex(_ index: Int) {
		var i = 0
		for arr in self.inputsCells {
			if i == index {
				if let textField = (arr as! NSArray)[0] as? UITextField {
					if let cell = (arr as! NSArray)[1] as? ErrorTableViewCell {
						if !textField.isFirstResponder {
							textField.becomeFirstResponder()
						}
						let indexPath = self.tableView.indexPath(for: cell)
						if indexPath != nil {
							scrollToRow(indexPath!)
						}
					}
					
				}
			}
			i = i + 1
		}
	}
	
	func prev(_ object: AnyObject?) {
		if object != nil {
			let index = getIndexForObject(object!)
			if index >= 1 {
				focusAndScrollForIndex(index-1)
			}
		}
	}
	
	func next(_ object: AnyObject?) {
		if object != nil {
			let index = getIndexForObject(object!)
			if index < self.inputsCells.count - 1 {
				focusAndScrollForIndex(index+1)
			}
		}
	}
	
	func done(_ object: AnyObject?) {
		if object != nil {
			let index = getIndexForObject(object!)
			if index < self.inputsCells.count {
				var i = 0
				for arr in self.inputsCells {
					if i == index {
						if let textField = (arr as! NSArray)[0] as? UITextField {
							textField.resignFirstResponder()
							let indexPath = IndexPath(row: 0, section: 0)
							scrollToRow(indexPath)
						}
					}
					i = i + 1
				}
			}
		}
	}
	
	func prepareTableView() {
		
		self.inputsCells = NSMutableArray()
		
		let cardNumberNib = UINib(nibName: "MPCardNumberTableViewCell", bundle: MercadoPago.getBundle())
		self.tableView.register(cardNumberNib, forCellReuseIdentifier: "cardNumberCell")
		self.cardNumberCell = self.tableView.dequeueReusableCell(withIdentifier: "cardNumberCell") as! MPCardNumberTableViewCell
		self.cardNumberCell.height = 55.0
		self.cardNumberCell.setIcon(self.paymentMethod._id)
		self.cardNumberCell._setSetting(self.paymentMethod.settings[0])
		self.cardNumberCell.cardNumberTextField.inputAccessoryView = MPToolbar(prevEnabled: false, nextEnabled: true, delegate: self, textFieldContainer: self.cardNumberCell.cardNumberTextField)
		self.inputsCells.add([self.cardNumberCell.cardNumberTextField, self.cardNumberCell])
		
		let expirationDateNib = UINib(nibName: "MPExpirationDateTableViewCell", bundle: MercadoPago.getBundle())
		self.tableView.register(expirationDateNib, forCellReuseIdentifier: "expirationDateCell")
		self.expirationDateCell = self.tableView.dequeueReusableCell(withIdentifier: "expirationDateCell") as! MPExpirationDateTableViewCell
		self.expirationDateCell.height = 55.0
		self.expirationDateCell.expirationDateTextField.inputAccessoryView = MPToolbar(prevEnabled: true, nextEnabled: true, delegate: self, textFieldContainer: self.expirationDateCell.expirationDateTextField)
		self.inputsCells.add([self.expirationDateCell.expirationDateTextField, self.expirationDateCell])
		
		let cardholderNameNib = UINib(nibName: "MPCardholderNameTableViewCell", bundle: MercadoPago.getBundle())
		self.tableView.register(cardholderNameNib, forCellReuseIdentifier: "cardholderNameCell")
		self.cardholderNameCell = self.tableView.dequeueReusableCell(withIdentifier: "cardholderNameCell") as! MPCardholderNameTableViewCell
		self.cardholderNameCell.height = 55.0
		self.cardholderNameCell.cardholderNameTextField.inputAccessoryView = MPToolbar(prevEnabled: true, nextEnabled: true, delegate: self, textFieldContainer: self.cardholderNameCell.cardholderNameTextField)
		self.inputsCells.add([self.cardholderNameCell.cardholderNameTextField, self.cardholderNameCell])
		
		let userIdNib = UINib(nibName: "MPUserIdTableViewCell", bundle: MercadoPago.getBundle())
		self.tableView.register(userIdNib, forCellReuseIdentifier: "userIdCell")
		self.userIdCell = self.tableView.dequeueReusableCell(withIdentifier: "userIdCell") as! MPUserIdTableViewCell
		self.userIdCell._setIdentificationTypes(self.identificationTypes)
		self.userIdCell.height = 55.0
		self.userIdCell.userIdTypeTextField.inputAccessoryView = MPToolbar(prevEnabled: true, nextEnabled: true, delegate: self, textFieldContainer: self.userIdCell.userIdTypeTextField)
		self.userIdCell.userIdValueTextField.inputAccessoryView = MPToolbar(prevEnabled: true, nextEnabled: true, delegate: self, textFieldContainer: self.userIdCell.userIdValueTextField)
		
		self.inputsCells.add([self.userIdCell.userIdTypeTextField, self.userIdCell])
		self.inputsCells.add([self.userIdCell.userIdValueTextField, self.userIdCell])
		
		let securityCodeNib = UINib(nibName: "SimpleSecurityCodeTableViewCell", bundle: nil)
		self.tableView.register(securityCodeNib, forCellReuseIdentifier: "securityCodeCell")
		self.securityCodeCell = self.tableView.dequeueReusableCell(withIdentifier: "securityCodeCell") as! SimpleSecurityCodeTableViewCell
		self.securityCodeCell.height = 55.0
		self.securityCodeCell.securityCodeTextField.inputAccessoryView = MPToolbar(prevEnabled: true, nextEnabled: false, delegate: self, textFieldContainer: self.securityCodeCell.securityCodeTextField)
		self.inputsCells.add([self.securityCodeCell.securityCodeTextField, self.securityCodeCell])

		self.tableView.delegate = self
		self.tableView.dataSource = self
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 2 ? 1 : 2
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if (indexPath as NSIndexPath).section == 0 {
			if (indexPath as NSIndexPath).row == 0 {
				return self.cardNumberCell
			} else if (indexPath as NSIndexPath).row == 1 {
				return self.expirationDateCell
			}
		} else if (indexPath as NSIndexPath).section == 1 {
			if (indexPath as NSIndexPath).row == 0 {
				return self.cardholderNameCell
			} else if (indexPath as NSIndexPath).row == 1 {
				return self.userIdCell
			}
		} else if (indexPath as NSIndexPath).section == 2 {
			return self.securityCodeCell
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if (indexPath as NSIndexPath).section == 0 {
			if (indexPath as NSIndexPath).row == 0 {
				return self.cardNumberCell.getHeight()
			} else if (indexPath as NSIndexPath).row == 1 {
				return self.expirationDateCell.getHeight()
			}
		} else if (indexPath as NSIndexPath).section == 1 {
			if (indexPath as NSIndexPath).row == 0 {
				return self.cardholderNameCell.getHeight()
			} else if (indexPath as NSIndexPath).row == 1 {
				return self.userIdCell.getHeight()
			}
		} else if (indexPath as NSIndexPath).section == 2 {
			return self.securityCodeCell.getHeight()
		}
		return 55
	}
	
	override func viewDidLayoutSubviews() {
		if self.tableView.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
			self.tableView.separatorInset = UIEdgeInsets.zero
		}
		
		if self.tableView.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
				self.tableView.layoutMargins = UIEdgeInsets.zero
		}
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
			cell.separatorInset = UIEdgeInsets.zero
		}
		
		if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
				cell.layoutMargins = UIEdgeInsets.zero
		}
	}
	
	func validateForm(_ cardToken : CardToken) -> Bool {
        return true
		/*
		var result : Bool = true

		// Validate card number
		let errorCardNumber = cardToken.validateCardNumber(paymentMethod!)
		if  errorCardNumber != nil {
			self.cardNumberCell.setError(errorCardNumber!.userInfo["cardNumber"] as? String)
			result = false
		} else {
			self.cardNumberCell.setError(nil)
		}
		
		// Validate expiry date
		let errorExpiryDate = cardToken.validateExpiryDate()
		if errorExpiryDate != nil {
			self.expirationDateCell.setError(errorExpiryDate!.userInfo["expiryDate"] as? String)
			result = false
		} else {
			self.expirationDateCell.setError(nil)
		}
		
		// Validate card holder name
		let errorCardholder = cardToken.validateCardholderName()
		if errorCardholder != nil {
			self.cardholderNameCell.setError(errorCardholder!.userInfo["cardholder"] as? String)
			result = false
		} else {
			self.cardholderNameCell.setError(nil)
		}
		
		// Validate identification number
		let errorIdentificationType = cardToken.validateIdentificationType()
		var errorIdentificationNumber : NSError? = nil
		if self.identificationType != nil {
			errorIdentificationNumber = cardToken.validateIdentificationNumber(self.identificationType!)
		} else {
			errorIdentificationNumber = cardToken.validateIdentificationNumber()
		}
		
		if errorIdentificationType != nil {
			self.userIdCell.setError(errorIdentificationType!.userInfo["identification"] as? String)
			result = false
		} else if errorIdentificationNumber != nil {
			self.userIdCell.setError(errorIdentificationNumber!.userInfo["identification"] as? String)
			result = false
		} else {
			self.userIdCell.setError(nil)
		}
		
		let errorSecurityCode = cardToken.validateSecurityCode()
		if errorSecurityCode != nil {
			self.securityCodeCell.setError(errorSecurityCode!.userInfo["securityCode"] as? String)
			result = false
		} else {
			self.securityCodeCell.setError(nil)
		}
		
		return result
 */
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		let cell = textField.superview?.superview as! UITableViewCell?
		self.tableView.scrollToRow(at: self.tableView.indexPath(for: cell!)!, at: UITableViewScrollPosition.top, animated: true)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		
		return true
	}
	
	func createToken(_ cardToken: CardToken) {
		let mercadoPago = MercadoPago(publicKey: self.publicKey!)
		mercadoPago.createNewCardToken(cardToken, success: { (token) -> Void in
			self.loadingView.removeFromSuperview()
			self.callback?(token)
			}, failure: nil)
	}
    

}
