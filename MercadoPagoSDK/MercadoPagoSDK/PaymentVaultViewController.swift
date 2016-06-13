//
//  PaymentVaultViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class PaymentVaultViewController: MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var merchantBaseUrl : String!
    var merchantAccessToken : String!
    var publicKey : String!
    var amount : Double!
    var currencyId : String!
    var paymentSettings : PaymentPreference!
    var callback : ((paymentMethod: PaymentMethod, token:Token?, issuer: Issuer?, payerCost: PayerCost?) -> Void)!

    var defaultInstallments : Int?
    var installments : Int?

    // Info loaded from groups service :
    var paymentMethods : [PaymentMethod]!
    var currentPaymentMethodSearch : [PaymentMethodSearchItem]!
    
    var bundle = MercadoPago.getBundle()
    
    private var tintColor = true
    internal var isRoot = true
    
    
    @IBOutlet weak var paymentsTable: UITableView!
    

    internal init(amount: Double, currencyId : String, paymentSettings : PaymentPreference!, paymentMethodSearchItem : [PaymentMethodSearchItem], paymentMethods: [PaymentMethod], title: String? = "", tintColor : Bool = false, callback: (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost: PayerCost?) -> Void, callbackCancel : (Void -> Void)? = nil) {

        super.init(nibName: "PaymentVaultViewController", bundle: bundle)
        
        self.merchantBaseUrl = MercadoPagoContext.baseURL() //distinta de null y vacia
        self.merchantAccessToken = MercadoPagoContext.merchantAccessToken()//Distinta de null y vacio
        //Installment > 0
        
        //Vaidar que no excluyo todos los payment method
        
        self.publicKey = MercadoPagoContext.publicKey()
        self.title = title
        self.tintColor = tintColor
        self.amount = amount // mayor o igual a 0
        self.currencyId = currencyId
        self.paymentSettings = paymentSettings

        self.currentPaymentMethodSearch = paymentMethodSearchItem
        self.paymentMethods = paymentMethods
        self.callback = callback
        
        if callbackCancel == nil {
            self.callbackCancel = {(Void) -> Void in
                if self.navigationController?.viewControllers[0] == self {
                    self.dismissViewControllerAnimated(true, completion: {
                        
                    })
                } else {
                    self.navigationController!.popViewControllerAnimated(true)
                }
            }
        } else {
            self.callbackCancel = callbackCancel
        }
    }
    
    init(amount: Double, currencyId : String, paymentPreference : PaymentPreference!, callback: (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost: PayerCost?) -> Void, callbackCancel : (Void -> Void)? = nil) {
        super.init(nibName: "PaymentVaultViewController", bundle: bundle)
        
        self.merchantBaseUrl = MercadoPagoContext.baseURL()
        self.merchantAccessToken = MercadoPagoContext.merchantAccessToken()
        self.publicKey = MercadoPagoContext.publicKey()
        self.amount = amount
        self.currencyId = currencyId
        self.paymentSettings = paymentPreference
        self.callback = callback
        
        if callbackCancel == nil {
            self.callbackCancel = {(Void) -> Void in
                if self.navigationController?.viewControllers[0] == self {
                    self.dismissViewControllerAnimated(true, completion: {
                    
                    })
                } else {
                    self.navigationController!.popViewControllerAnimated(true)
                }
            }
        } else {
            self.callbackCancel = callbackCancel
        }
    }
    
    required  public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.title == nil || self.title!.isEmpty {
            self.title = "¿Cómo quieres pagar?".localized
        }
        
        self.paymentsTable.tableHeaderView = UIView(frame: CGRectMake(0.0, 0.0, self.paymentsTable.bounds.size.width, 0.01))
        self.registerAllCells()
    
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem!.action = Selector("invokeCallbackCancel")
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showLoading()
        self.loadPaymentMethodSearch()
        
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return self.displayPreferenceDescription ? 1 : 0
            case 1:
                return self.currentPaymentMethodSearch.count
            default :
                return 1
        }
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 16 : 0.01
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
            case 0:
                return displayPreferenceDescription ? 120 : 0
            case 1:
                let currentPaymentMethodSearchItem = self.currentPaymentMethodSearch[indexPath.row]
                if currentPaymentMethodSearchItem.showIcon.boolValue {
                    if currentPaymentMethodSearchItem.isPaymentMethod() && !currentPaymentMethodSearchItem.isBitcoin() {
                        if currentPaymentMethodSearchItem.comment != nil && currentPaymentMethodSearchItem.comment!.characters.count > 0 {
                            return OfflinePaymentMethodCell.ROW_HEIGHT
                        } else {
                            return OfflinePaymentMethodWithDescriptionCell.ROW_HEIGHT
                        }
                    }
                    return PaymentSearchCell.ROW_HEIGHT
                }
                return PaymentTitleViewCell.ROW_HEIGHT
            case 2:
                return 100
            default : return 0
        }
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0 :
                let preferenceDescriptionCell = self.paymentsTable.dequeueReusableCellWithIdentifier("preferenceDescriptionCell") as! PreferenceDescriptionTableViewCell
                preferenceDescriptionCell.fillRowWithSettings(self.amount, currency: CurrenciesUtil.getCurrencyFor(self.currencyId)!)
                return preferenceDescriptionCell
            default :
                let currentPaymentMethod = self.currentPaymentMethodSearch[indexPath.row]
                
                let paymentMethodCell = getCellFor(currentPaymentMethod)
                // Add shadow effect to last cell in table
                if (indexPath.row == self.currentPaymentMethodSearch.count - 1) {
                    paymentMethodCell.clipsToBounds = false
                    paymentMethodCell.layer.masksToBounds = false
                    paymentMethodCell.layer.shadowOffset = CGSizeMake(0, 1)
                    paymentMethodCell.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).CGColor
                    paymentMethodCell.layer.shadowRadius = 1
                    paymentMethodCell.layer.shadowOpacity = 0.6
                }
                return paymentMethodCell
        }
        
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let paymentSearchItemSelected = self.currentPaymentMethodSearch[indexPath.row]
        if indexPath.section == 1 {
            self.paymentsTable.deselectRowAtIndexPath(indexPath, animated: true)
            if (paymentSearchItemSelected.children.count > 0) {
                let paymentVault = PaymentVaultViewController(amount: self.amount, currencyId : self.currencyId, paymentSettings: paymentSettings, paymentMethodSearchItem: paymentSearchItemSelected.children, paymentMethods : self.paymentMethods, title:paymentSearchItemSelected.childrenHeader, callback: { (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost: PayerCost?) -> Void in
                    self.callback(paymentMethod: paymentMethod, token: token, issuer: issuer, payerCost: payerCost)
                })
                paymentVault.isRoot = false
                self.navigationController!.pushViewController(paymentVault, animated: true)
            } else {
                self.optionSelected(paymentSearchItemSelected)
            }

        }
    }
    
    internal func optionSelected(paymentSearchItemSelected : PaymentMethodSearchItem, animated: Bool = true) {
    
        switch paymentSearchItemSelected.type.rawValue {
            case PaymentMethodSearchItemType.PAYMENT_TYPE.rawValue:
                let paymentTypeId = PaymentTypeId(rawValue: paymentSearchItemSelected.idPaymentMethodSearchItem)
            
                if paymentTypeId!.isCard() {
                    let cardFlow = MPFlowBuilder.startCardFlow(self.paymentSettings, amount: self.amount, paymentMethods : self.paymentMethods, callback: { (paymentMethod, token, issuer, payerCost) in
                        self.callback(paymentMethod: paymentMethod, token: token, issuer: issuer, payerCost: payerCost)
                        }, callbackCancel: {
                            if self.currentPaymentMethodSearch.count > 1 {
                                self.navigationController?.popToViewController(self, animated: true)
                            } else {
                                 self.navigationController?.popToViewController(self, animated: true)
                                self.callbackCancel!()
                            }
                            
                    })
                    
                    self.navigationController?.pushViewController(cardFlow.viewControllers[0], animated: animated)
                } else {
                    self.navigationController?.pushViewController(MPStepBuilder.startPaymentMethodsStep([PaymentTypeId(rawValue: paymentSearchItemSelected.idPaymentMethodSearchItem)!], callback: {    (paymentMethod : PaymentMethod) -> Void in
                        self.callback(paymentMethod: paymentMethod, token: nil, issuer: nil, payerCost: nil)
                    }), animated: true)
                }
                break
            case PaymentMethodSearchItemType.PAYMENT_METHOD.rawValue:
                if paymentSearchItemSelected.idPaymentMethodSearchItem == PaymentTypeId.ACCOUNT_MONEY.rawValue {
                    //MP wallet
                } else if paymentSearchItemSelected.idPaymentMethodSearchItem == PaymentTypeId.BITCOIN.rawValue {
                
                } else {
                    // Offline Payment Method
                    let offlinePaymentMethodSelected = Utils.findPaymentMethod(self.paymentMethods, paymentMethodId: paymentSearchItemSelected.idPaymentMethodSearchItem)
                    self.callback(paymentMethod: offlinePaymentMethodSelected, token:nil, issuer: nil, payerCost: nil)
                }
                break
            default:
                //TODO : HANDLE ERROR
                break
        }
    }
    
    private func loadPaymentMethodSearch(){
        
        if self.currentPaymentMethodSearch == nil {
            MPServicesBuilder.searchPaymentMethods(self.amount, excludedPaymentTypeIds: self.paymentSettings.excludedPaymentTypeIds, excludedPaymentMethodIds: self.paymentSettings.excludedPaymentMethodIds, success: { (paymentMethodSearchResponse: PaymentMethodSearch) -> Void in
                self.paymentMethods = paymentMethodSearchResponse.paymentMethods
                self.currentPaymentMethodSearch = paymentMethodSearchResponse.groups
                if self.currentPaymentMethodSearch.count == 1 {
                    self.optionSelected(self.currentPaymentMethodSearch[0], animated: false)
                }
                self.paymentsTable.delegate = self
                self.paymentsTable.dataSource = self
                self.paymentsTable.reloadData()
                self.hideLoading()
                }, failure: { (error) -> Void in
                    self.requestFailure(error)
            })
        } else {
            if self.currentPaymentMethodSearch.count == 1 {
                self.optionSelected(self.currentPaymentMethodSearch[0], animated: false)
            } else {
                self.paymentsTable.delegate = self
                self.paymentsTable.dataSource = self
                self.paymentsTable.reloadData()
                self.hideLoading()
                
            }
        }
    
    }
    
    
    private func getCellFor(currentPaymentMethodItem : PaymentMethodSearchItem) -> UITableViewCell {
        if currentPaymentMethodItem.showIcon.boolValue {
            let iconImage = MercadoPago.getImage(currentPaymentMethodItem.idPaymentMethodSearchItem)
            let tintColor = self.tintColor && (!currentPaymentMethodItem.isPaymentMethod() || currentPaymentMethodItem.isBitcoin())
            
            if iconImage != nil {
                if currentPaymentMethodItem.isPaymentMethod() && !currentPaymentMethodItem.isBitcoin() {
                    if currentPaymentMethodItem.comment != nil && currentPaymentMethodItem.comment!.characters.count > 0 {
                        let offlinePaymentCell = self.paymentsTable.dequeueReusableCellWithIdentifier("offlinePaymentMethodCell") as! OfflinePaymentMethodCell
                        let description = currentPaymentMethodItem.description ?? ""
                        offlinePaymentCell.fillRowWithPaymentMethod(currentPaymentMethodItem, image: iconImage!, paymentItemDescription: description)
                        return offlinePaymentCell
                    } else {
                        let offlinePaymentCellWithDescription = self.paymentsTable.dequeueReusableCellWithIdentifier("offlinePaymentWithDescription") as! OfflinePaymentMethodWithDescriptionCell
                        return offlinePaymentCellWithDescription.fillRowWith(currentPaymentMethodItem)
                    }
                }
                let paymentSearchCell = self.paymentsTable.dequeueReusableCellWithIdentifier("paymentSearchCell") as! PaymentSearchCell
                paymentSearchCell.fillRowWithPayment(currentPaymentMethodItem, iconImage : iconImage!, tintColor: tintColor)
                return paymentSearchCell
            }
        }
        
        if currentPaymentMethodItem.comment != nil && currentPaymentMethodItem.comment?.characters.count > 0 {
            let paymentSearchTitleAndCommentCell = self.paymentsTable.dequeueReusableCellWithIdentifier("paymentTitleAndCommentCell") as! PaymentTitleAndCommentViewCell
            paymentSearchTitleAndCommentCell.fillRowWith(currentPaymentMethodItem.description, paymentComment: currentPaymentMethodItem.comment!)
            return paymentSearchTitleAndCommentCell
        }
        
        let paymentSearchCell = self.paymentsTable.dequeueReusableCellWithIdentifier("paymentSearchTitleCell") as! PaymentTitleViewCell
        paymentSearchCell.paymentTitle.text = currentPaymentMethodItem.description
        return paymentSearchCell

    }

    private func registerAllCells(){
        let paymentMethodSearchNib = UINib(nibName: "PaymentSearchCell", bundle: self.bundle)
        let paymentSearchTitleCell = UINib(nibName: "PaymentTitleViewCell", bundle: self.bundle)
        let offlinePaymentMethodCell = UINib(nibName: "OfflinePaymentMethodCell", bundle: self.bundle)
        let preferenceDescriptionCell = UINib(nibName: "PreferenceDescriptionTableViewCell", bundle: self.bundle)
        let paymentTitleAndCommentCell = UINib(nibName: "PaymentTitleAndCommentViewCell", bundle: self.bundle)
        let offlinePaymentWithDescription = UINib(nibName: "OfflinePaymentMethodWithDescriptionCell", bundle: self.bundle)
        let exitButtonCell = UINib(nibName: "ExitButtonTableViewCell", bundle: self.bundle)
        
        self.paymentsTable.registerNib(paymentTitleAndCommentCell, forCellReuseIdentifier: "paymentTitleAndCommentCell")
        self.paymentsTable.registerNib(paymentMethodSearchNib, forCellReuseIdentifier: "paymentSearchCell")
        self.paymentsTable.registerNib(paymentSearchTitleCell, forCellReuseIdentifier: "paymentSearchTitleCell")
        self.paymentsTable.registerNib(offlinePaymentMethodCell, forCellReuseIdentifier: "offlinePaymentMethodCell")
        self.paymentsTable.registerNib(preferenceDescriptionCell, forCellReuseIdentifier: "preferenceDescriptionCell")
        self.paymentsTable.registerNib(offlinePaymentWithDescription, forCellReuseIdentifier: "offlinePaymentWithDescription")
        self.paymentsTable.registerNib(exitButtonCell, forCellReuseIdentifier: "exitButtonCell")
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        //En caso de que el vc no sea root
        if (navigationController != nil && navigationController!.viewControllers.count > 1 && navigationController!.viewControllers[0] != self) || (navigationController != nil && navigationController!.viewControllers.count == 1) {
            if self.isRoot {
                self.callbackCancel!()
            }
            return true
        }
        return false
    }

}
