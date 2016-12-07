//
//  NewCardViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 29/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class NewCardViewController : MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate, KeyboardDelegate {
	
	// ViewController parameters
	var key : String?
	var keyType : String?
	var paymentMethod: PaymentMethod?
	var requireSecurityCode : Bool?
	var callback: ((_ cardToken: CardToken) -> Void)?
	var identificationType : IdentificationType?
	var identificationTypes : [IdentificationType]?
	
	var bundle : Bundle? = MercadoPago.getBundle()
	
	// Input controls
	@IBOutlet weak fileprivate var tableView : UITableView!
	var cardNumberCell : MPCardNumberTableViewCell!
	var expirationDateCell : MPExpirationDateTableViewCell!
	var cardholderNameCell : MPCardholderNameTableViewCell!
	var userIdCell : MPUserIdTableViewCell!
	var securityCodeCell : MPSecurityCodeTableViewCell!
	var hasError : Bool = false
	var loadingView : UILoadingView!
	
	var inputsCells : NSMutableArray!
	override open var screenName : String { get { return "CARD_NUMBER" } }
    
	init(paymentMethod: PaymentMethod, requireSecurityCode: Bool, callback: ((_ cardToken: CardToken) -> Void)?) {
		super.init(nibName: "NewCardViewController", bundle: bundle)
		self.paymentMethod = paymentMethod
		self.requireSecurityCode = requireSecurityCode
		self.key = MercadoPagoContext.keyValue()
		self.keyType = MercadoPagoContext.keyType()
		self.callback = callback
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	public init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	override open func viewDidAppear(_ animated: Bool) {
		self.tableView.reloadData()
	}
	
	override open func viewDidLoad() {
		super.viewDidLoad()
		
		self.loadingView = UILoadingView(frame: MercadoPago.screenBoundsFixedToPortraitOrientation(), text: ("Cargando...".localized as NSString) as String)
		
		self.title = "Datos de tu tarjeta".localized
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás".localized, style: UIBarButtonItemStyle.plain, target: self, action: nil)
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continuar".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewCardViewController.submitForm))
		
		self.view.addSubview(self.loadingView)
		var mercadoPago : MercadoPago
		mercadoPago = MercadoPago(keyType: self.keyType, key: self.key)
		mercadoPago.getIdentificationTypes({(identificationTypes: [IdentificationType]?) -> Void in
			self.identificationTypes = identificationTypes
			self.prepareTableView()
			self.tableView.reloadData()
			self.loadingView.removeFromSuperview()
			}, failure: { (error: NSError?) -> Void in
				
				if error?.code == MercadoPago.ERROR_API_CODE {
					self.prepareTableView()
					self.tableView.reloadData()
					self.loadingView.removeFromSuperview()
					self.userIdCell.isHidden = true
				}
			}
		)
		
	}
	
	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(NewCardViewController.willShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(NewCardViewController.willHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	open override func viewWillDisappear(_ animated: Bool) {
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
	
	open func getIndexForObject(_ object: AnyObject) -> Int {
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
	
	open func scrollToRow(_ indexPath: IndexPath) {
		self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
	}
	
	open func focusAndScrollForIndex(_ index: Int) {
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
	
	open func prev(_ object: AnyObject?) {
		if object != nil {
			let index = getIndexForObject(object!)
			if index >= 1 {
				focusAndScrollForIndex(index-1)
			}
		}
	}
	
	open func next(_ object: AnyObject?) {
		if object != nil {
			let index = getIndexForObject(object!)
			if index < self.inputsCells.count - 1 {
				focusAndScrollForIndex(index+1)
			}
		}
	}
	
	open func done(_ object: AnyObject?) {
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
	
	open func prepareTableView() {
		self.inputsCells = NSMutableArray()
		
		let cardNumberNib = UINib(nibName: "MPCardNumberTableViewCell", bundle: MercadoPago.getBundle())
		self.tableView.register(cardNumberNib, forCellReuseIdentifier: "cardNumberCell")
		self.cardNumberCell = self.tableView.dequeueReusableCell(withIdentifier: "cardNumberCell") as! MPCardNumberTableViewCell
		self.cardNumberCell.height = 55.0
		if self.paymentMethod != nil {
			self.cardNumberCell.setIcon(self.paymentMethod!._id)
			self.cardNumberCell._setSetting(self.paymentMethod!.settings[0])
		}
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
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
	}
	
	open func submitForm() {
		
		let cardToken = CardToken(cardNumber: self.cardNumberCell.getCardNumber(), expirationMonth: self.expirationDateCell.getExpirationMonth(), expirationYear: self.expirationDateCell.getExpirationYear(), securityCode: nil, cardholderName: self.cardholderNameCell.getCardholderName(), docType: self.userIdCell.getUserIdType(), docNumber: self.userIdCell.getUserIdValue())
		
		self.view.addSubview(self.loadingView)
		
		if validateForm(cardToken) {
			callback!(cardToken)
		} else {
			self.hasError = true
			self.tableView.reloadData()
			self.loadingView.removeFromSuperview()
		}
	}
	
	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	open func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
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
		}
		return UITableViewCell()
	}
	
	override open func viewDidLayoutSubviews() {
		if self.tableView.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
			self.tableView.separatorInset = UIEdgeInsets.zero
		}
		
		if self.tableView.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
				self.tableView.layoutMargins = UIEdgeInsets.zero
		}
	}
	
	open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
			cell.separatorInset = UIEdgeInsets.zero
		}
		
		if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
				cell.layoutMargins = UIEdgeInsets.zero
		}
	}
	
	open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
		}
		return 55
	}
	
	open func validateForm(_ cardToken : CardToken) -> Bool {
		return true
        /*
		var result : Bool = true
		
		// Validate card number
		let errorCardNumber = cardToken.validateCardNumber(paymentMethod!)
		if  errorCardNumber != nil {
		//	self.cardNumberCell.setError(errorCardNumber!.userInfo["cardNumber"] as? String)
			result = false
		} else {
			self.cardNumberCell.setError(nil)
		}
		
		// Validate expiry date
		let errorExpiryDate = cardToken.validateExpiryDate()
		if errorExpiryDate != nil {
		//	self.expirationDateCell.setError(errorExpiryDate!.userInfo["expiryDate"] as? String)
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
		
		return result
 */
	}
	
}
