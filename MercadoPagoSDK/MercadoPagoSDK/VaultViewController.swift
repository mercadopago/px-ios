////
////  VaultViewController.swift
////  MercadoPagoSDK
////
////  Created by Matias Gualino on 7/1/15.
////  Copyright (c) 2015 com.mercadopago. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//open class VaultViewController : MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {
//    
//    // ViewController parameters
//    var publicKey: String?
//    var merchantBaseUrl: String?
//    var getCustomerUri: String?
//    var merchantAccessToken: String?
//    var amount : Double = 0
//    var bundle : Bundle? = MercadoPago.getBundle()
//    
//    open var callback : ((PaymentMethod, String?, Issuer?, Int) -> Void)?
//    
//    // Input controls
//    @IBOutlet weak fileprivate var tableview : UITableView!
//    @IBOutlet weak fileprivate var emptyPaymentMethodCell : MPPaymentMethodEmptyTableViewCell!
//    @IBOutlet weak fileprivate var paymentMethodCell : MPPaymentMethodTableViewCell!
//    @IBOutlet weak fileprivate var installmentsCell : MPInstallmentsTableViewCell!
//    @IBOutlet weak fileprivate var securityCodeCell : MPSecurityCodeTableViewCell!
//    open var loadingView : UILoadingView!
//    
//    // Current values
//    open var selectedCard : Card? = nil
//    open var selectedPayerCost : PayerCost? = nil
//    open var selectedCardToken : CardToken? = nil
//    open var selectedPaymentMethod : PaymentMethod? = nil
//    open var selectedIssuer : Issuer? = nil
//    open var cards : [Card]?
//    open var payerCosts : [PayerCost]?
//    
//    open var securityCodeRequired : Bool = true
//    open var securityCodeLength : Int = 0
//    open var bin : String?
//    open var paymentPreference : PaymentPreference?
//    
//    init(amount: Double, paymentPreference : PaymentPreference?, callback: @escaping (_ paymentMethod: PaymentMethod, _ tokenId: String?, _ issuer: Issuer?, _ installments: Int) -> Void) {
//            
//        super.init(nibName: "VaultViewController", bundle: bundle)
//            
//        self.merchantBaseUrl = MercadoPagoContext.baseURL()
//        self.getCustomerUri =  MercadoPagoContext.customerURI()
//        self.merchantAccessToken = MercadoPagoContext.merchantAccessToken()
//        self.publicKey = MercadoPagoContext.publicKey()
//            
//        self.amount = amount
//        self.paymentPreference = paymentPreference
//        self.callback = callback
//    }
//    
//    required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    open override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let tableSelection : IndexPath? = self.tableview.indexPathForSelectedRow
//        if tableSelection != nil {
//            self.tableview.deselectRow(at: tableSelection!, animated: false)
//        }
//    }
//    
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.title = "Pagar".localized
//        
//        self.loadingView = UILoadingView(frame: MercadoPago.screenBoundsFixedToPortraitOrientation(), text: ("Cargando...".localized as NSString) as String)
//        
//        declareAndInitCells()
//        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continuar".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(VaultViewController.submitForm))
//        self.navigationItem.rightBarButtonItem?.isEnabled = false
//        
//        self.tableview.delegate = self
//        self.tableview.dataSource = self
//        
//        if self.merchantBaseUrl != nil && self.getCustomerUri != nil {
//            
//            self.view.addSubview(self.loadingView)
//
//
//            
//            MerchantServer.getCustomer({ (customer: Customer) -> Void in
//                self.cards = customer.cards
//                self.loadingView.removeFromSuperview()
//                self.tableview.reloadData()
//                }, failure: { (error: NSError?) -> Void in
//                    MercadoPago.showAlertViewWithError(error, nav: self.navigationController)
//            })
//            
//        } else {
//            self.tableview.reloadData()
//        }
//        
//    }
//    
//    open override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(VaultViewController.willShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(VaultViewController.willHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//    }
//    
//    open override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    func willHideKeyboard(_ notification: Notification) {
//        // resize content insets.
//        let contentInsets = UIEdgeInsetsMake(64, 0.0, 0.0, 0)
//        self.tableview.contentInset = contentInsets
//        self.tableview.scrollIndicatorInsets = contentInsets
//        self.scrollToRow(IndexPath(row: 0, section: 0))
//    }
//    
//    func willShowKeyboard(_ notification: Notification) {
//        let s:NSValue? = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)
//        let keyboardBounds :CGRect = s!.cgRectValue
//        
//        // resize content insets.
//        let contentInsets = UIEdgeInsetsMake(64, 0.0, keyboardBounds.size.height, 0)
//        self.tableview.contentInset = contentInsets
//        self.tableview.scrollIndicatorInsets = contentInsets
//        
//        let securityIndexPath = self.tableview.indexPath(for: self.securityCodeCell)
//        if securityIndexPath != nil {
//            self.scrollToRow(securityIndexPath!)
//        }
//    }
//    
//    open func scrollToRow(_ indexPath: IndexPath) {
//        self.tableview.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
//    }
//    
//    open func declareAndInitCells() {
//        let paymentMethodNib = UINib(nibName: "MPPaymentMethodTableViewCell", bundle: self.bundle)
//        self.tableview.register(paymentMethodNib, forCellReuseIdentifier: "paymentMethodCell")
//        self.paymentMethodCell = self.tableview.dequeueReusableCell(withIdentifier: "paymentMethodCell") as! MPPaymentMethodTableViewCell
//        
//        let emptyPaymentMethodNib = UINib(nibName: "MPPaymentMethodEmptyTableViewCell", bundle: self.bundle)
//        self.tableview.register(emptyPaymentMethodNib, forCellReuseIdentifier: "emptyPaymentMethodCell")
//        self.emptyPaymentMethodCell = self.tableview.dequeueReusableCell(withIdentifier: "emptyPaymentMethodCell") as! MPPaymentMethodEmptyTableViewCell
//        
//        let securityCodeNib = UINib(nibName: "MPSecurityCodeTableViewCell", bundle: self.bundle)
//        self.tableview.register(securityCodeNib, forCellReuseIdentifier: "securityCodeCell")
//        self.securityCodeCell = self.tableview.dequeueReusableCell(withIdentifier: "securityCodeCell")as! MPSecurityCodeTableViewCell
//        
//        let installmentsNib = UINib(nibName: "MPInstallmentsTableViewCell", bundle: self.bundle)
//        self.tableview.register(installmentsNib, forCellReuseIdentifier: "installmentsCell")
//        self.installmentsCell = self.tableview.dequeueReusableCell(withIdentifier: "installmentsCell") as! MPInstallmentsTableViewCell
//    }
//    
//    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if self.selectedCard == nil && self.selectedCardToken == nil {
//            if (self.selectedPaymentMethod != nil && self.selectedPaymentMethod!.isCard()) {
//                self.navigationItem.rightBarButtonItem?.isEnabled = true
//            }
//            return 1
//        }
//        else if self.selectedPayerCost == nil {
//            return 2
//        } else if !securityCodeRequired {
//            self.navigationItem.rightBarButtonItem?.isEnabled = true
//            return 2
//        }
//        self.navigationItem.rightBarButtonItem?.isEnabled = true
//        return 3
//    }
//    
//    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if (indexPath as NSIndexPath).row == 0 {
//            if self.selectedCard == nil && self.selectedPaymentMethod == nil {
//                self.emptyPaymentMethodCell = self.tableview.dequeueReusableCell(withIdentifier: "emptyPaymentMethodCell") as! MPPaymentMethodEmptyTableViewCell
//                return self.emptyPaymentMethodCell
//            } else {
//                self.paymentMethodCell = self.tableview.dequeueReusableCell(withIdentifier: "paymentMethodCell") as! MPPaymentMethodTableViewCell
//                let paymentTypeIdEnum = PaymentTypeId(rawValue : self.selectedPaymentMethod!.paymentTypeId)
//                if !paymentTypeIdEnum!.isCard() {
//                    self.paymentMethodCell.fillWithPaymentMethod(self.selectedPaymentMethod!)
//                }
//                else if self.selectedCardToken != nil {
//                    self.paymentMethodCell.fillWithCardTokenAndPaymentMethod(self.selectedCardToken, paymentMethod: self.selectedPaymentMethod!)
//                } else {
//                    self.paymentMethodCell.fillWithCard(self.selectedCard)
//                }
//                return self.paymentMethodCell
//            }
//        } else if (indexPath as NSIndexPath).row == 1 {
//            self.installmentsCell = self.tableview.dequeueReusableCell(withIdentifier: "installmentsCell") as! MPInstallmentsTableViewCell
//            self.installmentsCell.fillWithPayerCost(self.selectedPayerCost, amount: self.amount)
//            return self.installmentsCell
//        } else if (indexPath as NSIndexPath).row == 2 {
//            self.securityCodeCell = self.tableview.dequeueReusableCell(withIdentifier: "securityCodeCell") as! MPSecurityCodeTableViewCell
//            self.securityCodeCell.height = 143
//            self.securityCodeCell.fillWithPaymentMethod(self.selectedPaymentMethod!)
//            return self.securityCodeCell
//        }
//        return UITableViewCell()
//    }
//    
//    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if ((indexPath as NSIndexPath).row == 2) {
//            return self.securityCodeCell != nil ? self.securityCodeCell.getHeight() : 143
//        }
//        return 65
//    }
//    
//    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if (indexPath as NSIndexPath).row == 0 {
//            let paymentMethodsViewController = getPaymentMethodsViewController()
//            
//            if self.cards != nil && self.cards!.count > 0 {
//                let customerPaymentMethodsViewController = MPStepBuilder.startCustomerCardsStep(self.cards!, callback: { (selectedCard) -> Void in
//                        if selectedCard != nil {
//                            self.selectedCard = selectedCard
//                            self.selectedPaymentMethod = self.selectedCard?.paymentMethod
//                            self.selectedIssuer = self.selectedCard?.issuer
//                            self.bin = self.selectedCard?.firstSixDigits
//                            self.securityCodeLength = self.selectedCard!.securityCode!.length
//                            self.securityCodeRequired = self.securityCodeLength > 0
//                            self.loadPayerCosts()
//                            self.navigationController!.popViewController(animated: true)
//                        } else {
//                            self.showViewController(paymentMethodsViewController)
//                        }
//                    })
//                self.showViewController(customerPaymentMethodsViewController)
//            } else {
//                self.showViewController(paymentMethodsViewController)
//            }
//        } else if (indexPath as NSIndexPath).row == 1 {
//            self.showViewController(MPStepBuilder.startInstallmentsStep(payerCosts!, amount: amount, issuer: nil, paymentMethodId: nil,callback: { (payerCost) -> Void in
//                self.selectedPayerCost = payerCost
//                self.tableview.reloadData()
//                self.navigationController!.popToViewController(self, animated: true)
//            }))
//        }
//    }
//    
//    open func showViewController(_ vc: UIViewController) {
//            self.show(vc, sender: self)
//    }
//    
//    open func loadPayerCosts() {
//        self.view.addSubview(self.loadingView)
//        MPServicesBuilder.getInstallments(self.bin, amount: self.amount, issuer: self.selectedIssuer!, paymentMethodId: self.selectedPaymentMethod!._id, success: { (installments) in
//            if installments != nil {
//                self.payerCosts = installments![0].payerCosts
//                self.tableview.reloadData()
//                self.loadingView.removeFromSuperview()
//            }
//
//            }) { (error) in
//                MercadoPago.showAlertViewWithError(error, nav: self.navigationController)
//                self.navigationController?.popToRootViewController(animated: true)
//        }
//        
//    }
//    
//    open func submitForm() {
//        
//        self.securityCodeCell.securityCodeTextField.resignFirstResponder()
//        
//        let mercadoPago : MercadoPago = MercadoPago(publicKey: self.publicKey!)
//        
//        var canContinue = true
//        if self.securityCodeRequired {
//            let securityCode = self.securityCodeCell.getSecurityCode()
//            if String.isNullOrEmpty(securityCode) {
//                self.securityCodeCell.setError("invalid_field".localized)
//                canContinue = false
//            } else if securityCode?.characters.count != securityCodeLength {
//                self.securityCodeCell.setError(("invalid_cvv_length".localized as NSString).replacingOccurrences(of: "%1$s", with: "\(securityCodeLength)"))
//                canContinue = false
//            }
//        }
//        
//        if !canContinue {
//            self.tableview.reloadData()
//        } else {
//            // Create token
//            if selectedCard != nil {
//                
//                let securityCode = self.securityCodeRequired ? securityCodeCell.securityCodeTextField.text : nil
//                
//                let savedCardToken : SavedCardToken = SavedCardToken(card: selectedCard!, securityCode: securityCode, securityCodeRequired: self.securityCodeRequired)
//                
//                if savedCardToken.validate() {
//                    // Send card id to get token id
//                    self.view.addSubview(self.loadingView)
//                    MPServicesBuilder.createToken(savedCardToken, success: {(token: Token?) -> Void in
//                        var tokenId : String? = nil
//                        if token != nil {
//                            tokenId = token!._id
//                        }
//                        
//                        let installments = self.selectedPayerCost == nil ? 0 : self.selectedPayerCost!.installments
//                        
//                        self.callback!(self.selectedPaymentMethod!, tokenId, self.selectedIssuer, installments)
//                        }, failure: { (error: NSError?) -> Void in
//                            MercadoPago.showAlertViewWithError(error, nav: self.navigationController)
//                    })
//                } else {
//
//                    return
//                }
//            } else {
//                self.selectedCardToken!.securityCode = self.securityCodeCell.securityCodeTextField.text
//                self.view.addSubview(self.loadingView)
//                mercadoPago.createNewCardToken(self.selectedCardToken!, success: {(token: Token?) -> Void in
//                    var tokenId : String? = nil
//                    if token != nil {
//                        tokenId = token!._id
//                    }
//                    
//                    let installments = self.selectedPayerCost == nil ? 0 : self.selectedPayerCost!.installments
//                    
//                    self.callback!(self.selectedPaymentMethod!, tokenId, self.selectedIssuer, installments)
//                    }, failure : { (error: NSError?) -> Void in
//                        MercadoPago.showAlertViewWithError(error, nav: self.navigationController)
//                    })
//            }
//        }
//    }
//    
//    func getPaymentMethodsViewController() -> PaymentMethodsViewController {
//       return MPStepBuilder.startPaymentMethodsStep(callback: { (paymentMethod : PaymentMethod) -> Void in
//            self.selectedPaymentMethod = paymentMethod
//            let paymentTypeIdEnum = PaymentTypeId(rawValue: paymentMethod.paymentTypeId)!
//            if paymentTypeIdEnum.isCard() {
//                self.selectedCard = nil
//                if paymentMethod.settings != nil && paymentMethod.settings.count > 0 {
//                    self.securityCodeLength = paymentMethod.settings![0].securityCode!.length
//                    self.securityCodeRequired = self.securityCodeLength != 0
//                }
//        
//                let newCardViewController = MPStepBuilder.startNewCardStep(self.selectedPaymentMethod!, requireSecurityCode: self.securityCodeRequired, callback: { (cardToken: CardToken) -> Void in
//                    self.selectedCardToken = cardToken
//                    self.bin = self.selectedCardToken?.getBin()
//                    self.loadPayerCosts()
//                    self.navigationController!.popToViewController(self, animated: true)
//                })
//        
//                if self.selectedPaymentMethod!.isIssuerRequired() {
//                    let issuerViewController = MPStepBuilder.startIssuersStep(self.selectedPaymentMethod!,
//                        callback: { (issuer: Issuer) -> Void in
//                            self.selectedIssuer = issuer
//                            self.showViewController(newCardViewController)
//                    })
//                    self.showViewController(issuerViewController)
//                } else {
//                    self.showViewController(newCardViewController)
//                }
//            } else {
//                self.tableview.reloadData()
//                self.navigationController!.popToViewController(self, animated: true)
//            }
//        })
//    }
//    
//}

