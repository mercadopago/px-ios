//
//  SimpleVaultViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 3/2/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import UIKit
import MercadoPagoSDK

class SimpleVaultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var publicKey: String?
    var baseUrl: String?
    var getCustomerUri: String?
    var merchantAccessToken: String?
    var callback: ((paymentMethod: PaymentMethod, token: Token?) -> Void)?
    var paymentPreference: PaymentPreference?
    
    @IBOutlet weak var tableview : UITableView!
    
    @IBOutlet weak var paymentMethodCell : MPPaymentMethodTableViewCell!
    @IBOutlet weak var securityCodeCell : MPSecurityCodeTableViewCell!
    @IBOutlet weak var emptyPaymentMethodCell : MPPaymentMethodEmptyTableViewCell!

    var loadingView : UILoadingView!
    
    // User's saved card
    var selectedCard : Card? = nil
    var selectedCardToken : CardToken? = nil
    // New card paymentMethod
    var selectedPaymentMethod : PaymentMethod? = nil
    
    var cards : [Card]?
    
    var securityCodeRequired : Bool = true
    var securityCodeLength : Int = 0
    var bin : String?
    
    init(merchantPublicKey: String, merchantBaseUrl: String, merchantGetCustomerUri: String, merchantAccessToken: String, paymentPreference: PaymentPreference?, callback: ((paymentMethod: PaymentMethod, token: Token?) -> Void)?) {
        super.init(nibName: "SimpleVaultViewController", bundle: nil)
        self.publicKey = merchantPublicKey
        self.baseUrl = merchantBaseUrl
        self.getCustomerUri = merchantGetCustomerUri
        self.merchantAccessToken = merchantAccessToken
        self.paymentPreference = paymentPreference
        self.callback = callback
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pagar".localized
        
        self.loadingView = UILoadingView(frame: MercadoPago.screenBoundsFixedToPortraitOrientation(), text: "Cargando...".localized)
        self.view.addSubview(self.loadingView)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continuar".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "submitForm")
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        
        declareAndInitCells()
        
        MerchantServer.getCustomer({ (customer: Customer) -> Void in
                self.cards = customer.cards
                self.loadingView.removeFromSuperview()
                self.tableview.reloadData()
            }, failure: nil)
    }
	
	override func viewWillAppear(animated: Bool) {
		declareAndInitCells()
		super.viewWillAppear(animated)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "willShowKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "willHideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func willHideKeyboard(notification: NSNotification) {
		// resize content insets.
		let contentInsets = UIEdgeInsetsMake(64, 0.0, 0.0, 0)
		self.tableview.contentInset = contentInsets
		self.tableview.scrollIndicatorInsets = contentInsets
		self.scrollToRow(NSIndexPath(forRow: 0, inSection: 0))
	}
	
	func willShowKeyboard(notification: NSNotification) {
		let s:NSValue? = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)
		let keyboardBounds :CGRect = s!.CGRectValue()
		
		// resize content insets.
		let contentInsets = UIEdgeInsetsMake(64, 0.0, keyboardBounds.size.height, 0)
		self.tableview.contentInset = contentInsets
		self.tableview.scrollIndicatorInsets = contentInsets
		let securityIndexPath = self.tableview.indexPathForCell(self.securityCodeCell)
		if securityIndexPath != nil {
			self.scrollToRow(securityIndexPath!)
		}
	}
	
	func scrollToRow(indexPath: NSIndexPath) {
		self.tableview.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
	}
    
    func declareAndInitCells() {
        let paymentMethodNib = UINib(nibName: "MPPaymentMethodTableViewCell", bundle: MercadoPago.getBundle())
        self.tableview.registerNib(paymentMethodNib, forCellReuseIdentifier: "paymentMethodCell")
        self.paymentMethodCell = self.tableview.dequeueReusableCellWithIdentifier("paymentMethodCell") as! MPPaymentMethodTableViewCell
        
        let emptyPaymentMethodNib = UINib(nibName: "MPPaymentMethodEmptyTableViewCell", bundle: MercadoPago.getBundle())
        self.tableview.registerNib(emptyPaymentMethodNib, forCellReuseIdentifier: "emptyPaymentMethodCell")
        self.emptyPaymentMethodCell = self.tableview.dequeueReusableCellWithIdentifier("emptyPaymentMethodCell") as! MPPaymentMethodEmptyTableViewCell

        let securityCodeNib = UINib(nibName: "MPSecurityCodeTableViewCell", bundle: MercadoPago.getBundle())
        self.tableview.registerNib(securityCodeNib, forCellReuseIdentifier: "securityCodeCell")
        self.securityCodeCell = self.tableview.dequeueReusableCellWithIdentifier("securityCodeCell") as! MPSecurityCodeTableViewCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedCard == nil && self.selectedCardToken == nil {
            return 1
        } else if !self.securityCodeRequired {
            self.navigationItem.rightBarButtonItem?.enabled = true
            return 1
        }
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if self.selectedCardToken == nil && self.selectedCard == nil {
                return self.emptyPaymentMethodCell
            } else {
                if self.selectedCardToken != nil {
                    self.paymentMethodCell.fillWithCardTokenAndPaymentMethod(self.selectedCardToken, paymentMethod: self.selectedPaymentMethod!)
                } else {
                    self.paymentMethodCell.fillWithCard(self.selectedCard)
                }
                return self.paymentMethodCell
            }
        } else if indexPath.row == 1 {
            self.securityCodeCell.fillWithPaymentMethod(self.selectedPaymentMethod!)
            self.securityCodeCell.securityCodeTextField.delegate = self
            return self.securityCodeCell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 1) {
            return 143
        }
        return 65
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let paymentMethodsViewController = MPStepBuilder.startPaymentMethodsStep(withPreference: self.paymentPreference, callback: getSelectionCallbackPaymentMethod())
            
            if self.cards != nil {
                if self.cards!.count > 0 {
                    let customerPaymentMethodsViewController = CustomerCardsViewController(cards: self.cards, callback: getCustomerPaymentMethodCallback(paymentMethodsViewController))
                    showViewController(customerPaymentMethodsViewController)
                } else {
                    showViewController(paymentMethodsViewController)
                }
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String)-> Bool {
        var txtAfterUpdate : NSString? = self.securityCodeCell.securityCodeTextField.text
		if txtAfterUpdate != nil {
			txtAfterUpdate = txtAfterUpdate!.stringByReplacingCharactersInRange(range, withString: string)
			
			if txtAfterUpdate!.length < self.securityCodeLength {
				self.navigationItem.rightBarButtonItem?.enabled = false
				return true
			} else if txtAfterUpdate!.length == self.securityCodeLength {
				self.navigationItem.rightBarButtonItem?.enabled = true
				return true
			}
		}
        return false
    }
	
    func getCustomerPaymentMethodCallback(paymentMethodsViewController : PaymentMethodsViewController) -> (selectedCard: Card?) -> Void {
        return {(selectedCard: Card?) -> Void in
            if selectedCard != nil {
                self.selectedCard = selectedCard
                self.selectedPaymentMethod = self.selectedCard!.paymentMethod
                self.securityCodeRequired = self.selectedCard!.securityCode!.length != 0
                self.securityCodeLength = self.selectedCard!.securityCode!.length
                self.bin = self.selectedCard!.firstSixDigits
                self.tableview.reloadData()
                self.navigationController!.popViewControllerAnimated(true)
            } else {
                self.showViewController(paymentMethodsViewController)
            }
        }
    }
    
    func getSelectionCallbackPaymentMethod() -> (paymentMethod : PaymentMethod) -> Void {
        return { (paymentMethod : PaymentMethod) -> Void in
            self.selectedCard = nil
            self.selectedPaymentMethod = paymentMethod
            if paymentMethod.settings != nil && paymentMethod.settings.count > 0 {
                self.securityCodeLength = paymentMethod.settings![0].securityCode!.length
				self.securityCodeRequired = self.securityCodeLength != 0
            }
            self.showViewController(MPStepBuilder.startNewCardStep(self.selectedPaymentMethod!, requireSecurityCode: self.securityCodeRequired, callback: self.getNewCardCallback()))
        }
    }
    
    func getNewCardCallback() -> (cardToken: CardToken) -> Void {
        return { (cardToken: CardToken) -> Void in
            self.selectedCardToken = cardToken
            self.bin = self.selectedCardToken!.getBin()
            if self.selectedPaymentMethod!.settings != nil && self.selectedPaymentMethod!.settings.count > 0 {
                self.securityCodeRequired = self.selectedPaymentMethod!.settings[0].securityCode!.length != 0
                self.securityCodeLength = self.selectedPaymentMethod!.settings[0].securityCode!.length
            }
            self.tableview.reloadData()
            self.navigationController!.popToViewController(self, animated: true)
        }
    }
    
    func getCreatePaymentCallback() -> (token: Token?) -> Void {
        return { (token: Token?) -> Void in
            self.callback!(paymentMethod: self.selectedPaymentMethod!, token: token)
        }
    }
    
    func submitForm() {

        let mercadoPago : MercadoPago = MercadoPago(publicKey: self.publicKey!)
        
        // Create token
        if selectedCard != nil {
            let securityCode = self.securityCodeRequired ? securityCodeCell.securityCodeTextField.text : nil
            
            let savedCardToken : SavedCardToken = SavedCardToken(card: selectedCard!, securityCode: securityCode, securityCodeRequired: self.securityCodeRequired)
            
            if savedCardToken.validate() {
                // Send card id to get token id
                self.view.addSubview(self.loadingView)
                mercadoPago.createToken(savedCardToken, success: getCreatePaymentCallback(), failure: nil)
            } else {
               
                return
            }
        } else {
            self.selectedCardToken!.securityCode = self.securityCodeCell.securityCodeTextField.text
            let error : NSError? = self.selectedCardToken?.validateSecurityCodeWithPaymentMethod(self.selectedPaymentMethod!)
            if  error != nil {
                let alert = UIAlertView(title: "Error",
                    message: error!.userInfo["securityCode"] as? String,
                    delegate: nil,
                    cancelButtonTitle: "OK")
                alert.show()
            } else {
                // Send card data to get token id
                self.view.addSubview(self.loadingView)
                mercadoPago.createNewCardToken(self.selectedCardToken!, success: getCreatePaymentCallback(), failure: nil)
            }
        }
    }
	
	func showViewController(vc: UIViewController) {
		if #available(iOS 8.0, *) {
			self.showViewController(vc, sender: self)
		} else {
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}

}
