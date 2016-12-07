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
    var callback: ((PaymentMethod, Token?) -> Void)?
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
    
    init(merchantPublicKey: String, merchantBaseUrl: String, merchantGetCustomerUri: String, merchantAccessToken: String, paymentPreference: PaymentPreference?, callback: ((_ paymentMethod: PaymentMethod, _ token: Token?) -> Void)?) {
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continuar".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(SimpleVaultViewController.submitForm))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        
        declareAndInitCells()
        
        MerchantServer.getCustomer({ (customer) -> Void in
                self.cards = customer.cards
                self.loadingView.removeFromSuperview()
                self.tableview.reloadData()
            }, failure: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		declareAndInitCells()
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(SimpleVaultViewController.willShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(SimpleVaultViewController.willHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
	
	func willHideKeyboard(_ notification: Notification) {
		// resize content insets.
		let contentInsets = UIEdgeInsetsMake(64, 0.0, 0.0, 0)
		self.tableview.contentInset = contentInsets
		self.tableview.scrollIndicatorInsets = contentInsets
		self.scrollToRow(IndexPath(row: 0, section: 0))
	}
	
	func willShowKeyboard(_ notification: Notification) {
		let s:NSValue? = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)
		let keyboardBounds :CGRect = s!.cgRectValue
		
		// resize content insets.
		let contentInsets = UIEdgeInsetsMake(64, 0.0, keyboardBounds.size.height, 0)
		self.tableview.contentInset = contentInsets
		self.tableview.scrollIndicatorInsets = contentInsets
		let securityIndexPath = self.tableview.indexPath(for: self.securityCodeCell)
		if securityIndexPath != nil {
			self.scrollToRow(securityIndexPath!)
		}
	}
	
	func scrollToRow(_ indexPath: IndexPath) {
		self.tableview.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
	}
    
    func declareAndInitCells() {
        let paymentMethodNib = UINib(nibName: "MPPaymentMethodTableViewCell", bundle: MercadoPago.getBundle())
        self.tableview.register(paymentMethodNib, forCellReuseIdentifier: "paymentMethodCell")
        self.paymentMethodCell = self.tableview.dequeueReusableCell(withIdentifier: "paymentMethodCell") as! MPPaymentMethodTableViewCell
        
        let emptyPaymentMethodNib = UINib(nibName: "MPPaymentMethodEmptyTableViewCell", bundle: MercadoPago.getBundle())
        self.tableview.register(emptyPaymentMethodNib, forCellReuseIdentifier: "emptyPaymentMethodCell")
        self.emptyPaymentMethodCell = self.tableview.dequeueReusableCell(withIdentifier: "emptyPaymentMethodCell") as! MPPaymentMethodEmptyTableViewCell

        let securityCodeNib = UINib(nibName: "MPSecurityCodeTableViewCell", bundle: MercadoPago.getBundle())
        self.tableview.register(securityCodeNib, forCellReuseIdentifier: "securityCodeCell")
        self.securityCodeCell = self.tableview.dequeueReusableCell(withIdentifier: "securityCodeCell") as! MPSecurityCodeTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedCard == nil && self.selectedCardToken == nil {
            return 1
        } else if !self.securityCodeRequired {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
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
        } else if (indexPath as NSIndexPath).row == 1 {
            self.securityCodeCell.fillWithPaymentMethod(self.selectedPaymentMethod!)
            self.securityCodeCell.securityCodeTextField.delegate = self
            return self.securityCodeCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath as NSIndexPath).row == 1) {
            return 143
        }
        return 65
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)-> Bool {
        var txtAfterUpdate : NSString? = self.securityCodeCell.securityCodeTextField.text as NSString?
		if txtAfterUpdate != nil {
			txtAfterUpdate = txtAfterUpdate!.replacingCharacters(in: range, with: string) as NSString?
			
			if txtAfterUpdate!.length < self.securityCodeLength {
				self.navigationItem.rightBarButtonItem?.isEnabled = false
				return true
			} else if txtAfterUpdate!.length == self.securityCodeLength {
				self.navigationItem.rightBarButtonItem?.isEnabled = true
				return true
			}
		}
        return false
    }
	
    func getCustomerPaymentMethodCallback(_ paymentMethodsViewController : PaymentMethodsViewController) -> (_ selectedCard: Card?) -> Void {
        return {(selectedCard: Card?) -> Void in
            if selectedCard != nil {
                self.selectedCard = selectedCard
                self.selectedPaymentMethod = self.selectedCard!.paymentMethod
                self.securityCodeRequired = self.selectedCard!.securityCode!.length != 0
                self.securityCodeLength = self.selectedCard!.securityCode!.length
                self.bin = self.selectedCard!.firstSixDigits
                self.tableview.reloadData()
                self.navigationController!.popViewController(animated: true)
            } else {
                self.showViewController(paymentMethodsViewController)
            }
        }
    }
    
    func getSelectionCallbackPaymentMethod() -> (_ paymentMethod : PaymentMethod) -> Void {
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
    
    func getNewCardCallback() -> (_ cardToken: CardToken) -> Void {
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
    
    func getCreatePaymentCallback() -> (_ token: Token?) -> Void {
        return { (token: Token?) -> Void in
            self.callback!(self.selectedPaymentMethod!, token)
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
            //let error : NSError? = self.selectedCardToken?.validateSecurityCodeWithPaymentMethod(self.selectedPaymentMethod!)
            let error : NSError? = nil
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
	
	func showViewController(_ vc: UIViewController) {
		if #available(iOS 8.0, *) {
			self.show(vc, sender: self)
		} else {
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}

}
