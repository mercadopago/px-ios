//
//  VaultViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 7/1/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

public class VaultViewController : MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // ViewController parameters
    var publicKey: String?
    var merchantBaseUrl: String?
    var getCustomerUri: String?
    var merchantAccessToken: String?
    var amount : Double = 0
    var bundle : NSBundle? = MercadoPago.getBundle()
    
    public var callback : ((paymentMethod: PaymentMethod, tokenId: String?, issuer: Issuer?, installments: Int) -> Void)?
    
    // Input controls
    @IBOutlet weak private var tableview : UITableView!
    @IBOutlet weak private var emptyPaymentMethodCell : MPPaymentMethodEmptyTableViewCell!
    @IBOutlet weak private var paymentMethodCell : MPPaymentMethodTableViewCell!
    @IBOutlet weak private var installmentsCell : MPInstallmentsTableViewCell!
    @IBOutlet weak private var securityCodeCell : MPSecurityCodeTableViewCell!
    public var loadingView : UILoadingView!
    
    // Current values
    public var selectedCard : Card? = nil
    public var selectedPayerCost : PayerCost? = nil
    public var selectedCardToken : CardToken? = nil
    public var selectedPaymentMethod : PaymentMethod? = nil
    public var selectedIssuer : Issuer? = nil
    public var cards : [Card]?
    public var payerCosts : [PayerCost]?
    
    public var securityCodeRequired : Bool = true
    public var securityCodeLength : Int = 0
    public var bin : String?
    public var paymentPreference : PaymentPreference?
    
    init(amount: Double, paymentPreference : PaymentPreference?, callback: (paymentMethod: PaymentMethod, tokenId: String?, issuer: Issuer?, installments: Int) -> Void) {
            
        super.init(nibName: "VaultViewController", bundle: bundle)
            
        self.merchantBaseUrl = MercadoPagoContext.baseURL()
        self.getCustomerUri =  MercadoPagoContext.customerURI()
        self.merchantAccessToken = MercadoPagoContext.merchantAccessToken()
        self.publicKey = MercadoPagoContext.publicKey()
            
        self.amount = amount
        self.paymentPreference = paymentPreference
        self.callback = callback
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let tableSelection : NSIndexPath? = self.tableview.indexPathForSelectedRow
        if tableSelection != nil {
            self.tableview.deselectRowAtIndexPath(tableSelection!, animated: false)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pagar".localized
        
        self.loadingView = UILoadingView(frame: MercadoPago.screenBoundsFixedToPortraitOrientation(), text: "Cargando...".localized)
        
        declareAndInitCells()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continuar".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "submitForm")
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        
        if self.merchantBaseUrl != nil && self.getCustomerUri != nil {
            
            self.view.addSubview(self.loadingView)


            
            MerchantServer.getCustomer({ (customer: Customer) -> Void in
                self.cards = customer.cards
                self.loadingView.removeFromSuperview()
                self.tableview.reloadData()
                }, failure: { (error: NSError?) -> Void in
                    MercadoPago.showAlertViewWithError(error, nav: self.navigationController)
            })
            
        } else {
            self.tableview.reloadData()
        }
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willShowKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willHideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    public override func viewWillDisappear(animated: Bool) {
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
    
    public func scrollToRow(indexPath: NSIndexPath) {
        self.tableview.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    public func declareAndInitCells() {
        let paymentMethodNib = UINib(nibName: "MPPaymentMethodTableViewCell", bundle: self.bundle)
        self.tableview.registerNib(paymentMethodNib, forCellReuseIdentifier: "paymentMethodCell")
        self.paymentMethodCell = self.tableview.dequeueReusableCellWithIdentifier("paymentMethodCell") as! MPPaymentMethodTableViewCell
        
        let emptyPaymentMethodNib = UINib(nibName: "MPPaymentMethodEmptyTableViewCell", bundle: self.bundle)
        self.tableview.registerNib(emptyPaymentMethodNib, forCellReuseIdentifier: "emptyPaymentMethodCell")
        self.emptyPaymentMethodCell = self.tableview.dequeueReusableCellWithIdentifier("emptyPaymentMethodCell") as! MPPaymentMethodEmptyTableViewCell
        
        let securityCodeNib = UINib(nibName: "MPSecurityCodeTableViewCell", bundle: self.bundle)
        self.tableview.registerNib(securityCodeNib, forCellReuseIdentifier: "securityCodeCell")
        self.securityCodeCell = self.tableview.dequeueReusableCellWithIdentifier("securityCodeCell")as! MPSecurityCodeTableViewCell
        
        let installmentsNib = UINib(nibName: "MPInstallmentsTableViewCell", bundle: self.bundle)
        self.tableview.registerNib(installmentsNib, forCellReuseIdentifier: "installmentsCell")
        self.installmentsCell = self.tableview.dequeueReusableCellWithIdentifier("installmentsCell") as! MPInstallmentsTableViewCell
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedCard == nil && self.selectedCardToken == nil {
            if (self.selectedPaymentMethod != nil && self.selectedPaymentMethod!.isCard()) {
                self.navigationItem.rightBarButtonItem?.enabled = true
            }
            return 1
        }
        else if self.selectedPayerCost == nil {
            return 2
        } else if !securityCodeRequired {
            self.navigationItem.rightBarButtonItem?.enabled = true
            return 2
        }
        self.navigationItem.rightBarButtonItem?.enabled = true
        return 3
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if self.selectedCard == nil && self.selectedPaymentMethod == nil {
                self.emptyPaymentMethodCell = self.tableview.dequeueReusableCellWithIdentifier("emptyPaymentMethodCell") as! MPPaymentMethodEmptyTableViewCell
                return self.emptyPaymentMethodCell
            } else {
                self.paymentMethodCell = self.tableview.dequeueReusableCellWithIdentifier("paymentMethodCell") as! MPPaymentMethodTableViewCell
                let paymentTypeIdEnum = PaymentTypeId(rawValue : self.selectedPaymentMethod!.paymentTypeId)
                if !paymentTypeIdEnum!.isCard() {
                    self.paymentMethodCell.fillWithPaymentMethod(self.selectedPaymentMethod!)
                }
                else if self.selectedCardToken != nil {
                    self.paymentMethodCell.fillWithCardTokenAndPaymentMethod(self.selectedCardToken, paymentMethod: self.selectedPaymentMethod!)
                } else {
                    self.paymentMethodCell.fillWithCard(self.selectedCard)
                }
                return self.paymentMethodCell
            }
        } else if indexPath.row == 1 {
            self.installmentsCell = self.tableview.dequeueReusableCellWithIdentifier("installmentsCell") as! MPInstallmentsTableViewCell
            self.installmentsCell.fillWithPayerCost(self.selectedPayerCost, amount: self.amount)
            return self.installmentsCell
        } else if indexPath.row == 2 {
            self.securityCodeCell = self.tableview.dequeueReusableCellWithIdentifier("securityCodeCell") as! MPSecurityCodeTableViewCell
            self.securityCodeCell.height = 143
            self.securityCodeCell.fillWithPaymentMethod(self.selectedPaymentMethod!)
            return self.securityCodeCell
        }
        return UITableViewCell()
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 2) {
            return self.securityCodeCell != nil ? self.securityCodeCell.getHeight() : 143
        }
        return 65
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let paymentMethodsViewController = getPaymentMethodsViewController()
            
            if self.cards != nil && self.cards!.count > 0 {
                let customerPaymentMethodsViewController = MPStepBuilder.startCustomerCardsStep(self.cards!, callback: { (selectedCard) -> Void in
                        if selectedCard != nil {
                            self.selectedCard = selectedCard
                            self.selectedPaymentMethod = self.selectedCard?.paymentMethod
                            self.selectedIssuer = self.selectedCard?.issuer
                            self.bin = self.selectedCard?.firstSixDigits
                            self.securityCodeLength = self.selectedCard!.securityCode!.length
                            self.securityCodeRequired = self.securityCodeLength > 0
                            self.loadPayerCosts()
                            self.navigationController!.popViewControllerAnimated(true)
                        } else {
                            self.showViewController(paymentMethodsViewController)
                        }
                    })
                self.showViewController(customerPaymentMethodsViewController)
            } else {
                self.showViewController(paymentMethodsViewController)
            }
        } else if indexPath.row == 1 {
            self.showViewController(MPStepBuilder.startInstallmentsStep(payerCosts!, amount: amount, issuer: nil, paymentMethodId: nil,callback: { (payerCost) -> Void in
                self.selectedPayerCost = payerCost
                self.tableview.reloadData()
                self.navigationController!.popToViewController(self, animated: true)
            }))
        }
    }
    
    public func showViewController(vc: UIViewController) {
        if #available(iOS 8.0, *) {
            self.showViewController(vc, sender: self)
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    public func loadPayerCosts() {
        self.view.addSubview(self.loadingView)
        let mercadoPago : MercadoPago = MercadoPago(publicKey: self.publicKey!)
        MPServicesBuilder.getInstallments(self.bin, amount: self.amount, issuer: self.selectedIssuer!, paymentMethodId: self.selectedPaymentMethod!._id, success: { (installments) in
            if installments != nil {
                self.payerCosts = installments![0].payerCosts
                self.tableview.reloadData()
                self.loadingView.removeFromSuperview()
            }

            }) { (error) in
                MercadoPago.showAlertViewWithError(error, nav: self.navigationController)
                self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
    }
    
    public func submitForm() {
        
        self.securityCodeCell.securityCodeTextField.resignFirstResponder()
        
        let mercadoPago : MercadoPago = MercadoPago(publicKey: self.publicKey!)
        
        var canContinue = true
        if self.securityCodeRequired {
            let securityCode = self.securityCodeCell.getSecurityCode()
            if String.isNullOrEmpty(securityCode) {
                self.securityCodeCell.setError("invalid_field".localized)
                canContinue = false
            } else if securityCode.characters.count != securityCodeLength {
                self.securityCodeCell.setError(("invalid_cvv_length".localized as NSString).stringByReplacingOccurrencesOfString("%1$s", withString: "\(securityCodeLength)"))
                canContinue = false
            }
        }
        
        if !canContinue {
            self.tableview.reloadData()
        } else {
            // Create token
            if selectedCard != nil {
                
                let securityCode = self.securityCodeRequired ? securityCodeCell.securityCodeTextField.text : nil
                
                let savedCardToken : SavedCardToken = SavedCardToken(card: selectedCard!, securityCode: securityCode, securityCodeRequired: self.securityCodeRequired)
                
                if savedCardToken.validate() {
                    // Send card id to get token id
                    self.view.addSubview(self.loadingView)
                    MPServicesBuilder.createToken(savedCardToken, success: {(token: Token?) -> Void in
                        var tokenId : String? = nil
                        if token != nil {
                            tokenId = token!._id
                        }
                        
                        let installments = self.selectedPayerCost == nil ? 0 : self.selectedPayerCost!.installments
                        
                        self.callback!(paymentMethod: self.selectedPaymentMethod!, tokenId: tokenId, issuer: self.selectedIssuer, installments: installments)
                        }, failure: { (error: NSError?) -> Void in
                            MercadoPago.showAlertViewWithError(error, nav: self.navigationController)
                    })
                } else {

                    return
                }
            } else {
                self.selectedCardToken!.securityCode = self.securityCodeCell.securityCodeTextField.text
                self.view.addSubview(self.loadingView)
                mercadoPago.createNewCardToken(self.selectedCardToken!, success: {(token: Token?) -> Void in
                    var tokenId : String? = nil
                    if token != nil {
                        tokenId = token!._id
                    }
                    
                    let installments = self.selectedPayerCost == nil ? 0 : self.selectedPayerCost!.installments
                    
                    self.callback!(paymentMethod: self.selectedPaymentMethod!, tokenId: tokenId, issuer: self.selectedIssuer, installments: installments)
                    }, failure: { (error: NSError?) -> Void in
                        MercadoPago.showAlertViewWithError(error, nav: self.navigationController)
                })
            }
        }
    }
    
    func getPaymentMethodsViewController() -> PaymentMethodsViewController {
       return MPStepBuilder.startPaymentMethodsStep(callback: { (paymentMethod : PaymentMethod) -> Void in
            self.selectedPaymentMethod = paymentMethod
            let paymentTypeIdEnum = PaymentTypeId(rawValue: paymentMethod.paymentTypeId)!
            if paymentTypeIdEnum.isCard() {
                self.selectedCard = nil
                if paymentMethod.settings != nil && paymentMethod.settings.count > 0 {
                    self.securityCodeLength = paymentMethod.settings![0].securityCode!.length
                    self.securityCodeRequired = self.securityCodeLength != 0
                }
        
                let newCardViewController = MPStepBuilder.startNewCardStep(self.selectedPaymentMethod!, requireSecurityCode: self.securityCodeRequired, callback: { (cardToken: CardToken) -> Void in
                    self.selectedCardToken = cardToken
                    self.bin = self.selectedCardToken?.getBin()
                    self.loadPayerCosts()
                    self.navigationController!.popToViewController(self, animated: true)
                })
        
                if self.selectedPaymentMethod!.isIssuerRequired() {
                    let issuerViewController = MPStepBuilder.startIssuersStep(self.selectedPaymentMethod!,
                        callback: { (issuer: Issuer) -> Void in
                            self.selectedIssuer = issuer
                            self.showViewController(newCardViewController)
                    })
                    self.showViewController(issuerViewController)
                } else {
                    self.showViewController(newCardViewController)
                }
            } else {
                self.tableview.reloadData()
                self.navigationController!.popToViewController(self, animated: true)
            }
        })
    }
    
}