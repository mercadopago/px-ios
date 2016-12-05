//
//  CheckoutViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 13/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit


open class CheckoutViewController: MercadoPagoUIScrollViewController, UITableViewDataSource, UITableViewDelegate, TermsAndConditionsDelegate {

    var preferenceId : String!
    var publicKey : String!
    var accessToken : String!
    var bundle : Bundle? = MercadoPago.getBundle()
    var callback : ((Payment) -> Void)!
    var viewModel : CheckoutViewModel!
    
    var issuer : Issuer?
    var token : Token?
    
    override open var screenName : String { get{ return "REVIEW_AND_CONFIRM" } }
    fileprivate var reviewAndConfirmContent = Set<String>()
    
    fileprivate var recover = false
    fileprivate var auth = false
    
    @IBOutlet weak var checkoutTable: UITableView!
    
    init(preferenceId : String, callback : @escaping ((Payment) -> Void),  callbackCancel : ((Void) -> Void)? = nil){
        MercadoPagoContext.clearPaymentKey()
        super.init(nibName: "CheckoutViewController", bundle: MercadoPago.getBundle())
        self.publicKey = MercadoPagoContext.publicKey()
        self.accessToken = MercadoPagoContext.merchantAccessToken()
        self.preferenceId = preferenceId
        self.viewModel = CheckoutViewModel()
        self.callback = callback
        self.callbackCancel = {
                self.dismiss(animated: true, completion: {
                    if(callbackCancel != nil){
                            callbackCancel!()
                  }
                })
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MercadoPagoContext.clearPaymentKey()
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {

        super.viewDidLoad()
        
        self.checkoutTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0.01))
        
        // Avoid account_money in F3
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: false)
        
    }
    
    var paymentEnabled = true

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.rightBarButtonItem = nil
        self.navBarBackgroundColor = UIColor.white()
        self.navBarTextColor = UIColor.blueMercadoPago()
        
    }

    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkoutTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.checkoutTable.bounds.size.width, height: 0.01))
        
        self.displayBackButton()
        self.navigationItem.leftBarButtonItem!.tintColor = UIColor.blueMercadoPago()
        self.navigationItem.leftBarButtonItem?.action = #selector(invokeCallbackCancel)
        self.showLoading()
        
        if !self.viewModel.isPreferenceLoaded() {
            self.loadPreference()
        } else {
            if self.viewModel.paymentMethod != nil {
                self.checkoutTable.reloadData()
                self.hideLoading()
                if (recover){
                    recover = false
                    self.startRecoverCard()
                }
                if (auth){
                    auth = false
                    self.startAuthCard(self.token!)
                }
                
            } else {
                self.displayBackButton()
                self.navigationItem.leftBarButtonItem!.action = #selector(invokeCallbackCancel)
                self.loadGroupsAndStartPaymentVault(true)
            }
        }

        self.extendedLayoutIncludesOpaqueBars = true
        self.showNavBar()
        self.navBarHeight -= 10
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.checkoutTableHeaderHeight(section)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.heightForRow(indexPath)
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                // numberOfRowsInMainSection() + confirmPaymentButton
                return self.viewModel.numberOfRowsInMainSection() + 1
            case 2:
                return self.viewModel.preference!.items!.count
            case 3:
                return 4
            default:
                return 0
        }
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return getMainTitleCell(indexPath : indexPath)
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                return self.getPurchaseSimpleDetailCell(indexPath: indexPath, title : "Productos".localized, amount : self.viewModel.preference!.getAmount())
            case 1:
                var title = "Total".localized
                var addSeparatorLine = false
                if self.viewModel.payerCost != nil {
                    title = "Pagas".localized
                    addSeparatorLine = true
                }
                return self.getPurchaseDetailCell(indexPath: indexPath, title : title, amount : self.viewModel.preference!.getAmount(), payerCost : self.viewModel.payerCost, addSeparatorLine: addSeparatorLine)
            case 2:
                if self.viewModel.isPaymentMethodSelectedCard() {
                    return self.getPurchaseSimpleDetailCell(indexPath: indexPath, title : "Total".localized, amount : self.viewModel.payerCost!.totalAmount, addSeparatorLine: false)
                }
                return self.getConfirmPaymentButtonCell(indexPath: indexPath)
            default:
                return self.getConfirmPaymentButtonCell(indexPath: indexPath)
            }
        } else if indexPath.section == 2 {
                return self.getPurchaseItemDetailCell(indexPath: indexPath)
        } else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                if self.viewModel.isPaymentMethodSelectedCard() {
                    return self.getOnlinePaymentMethodSelectedCell(indexPath: indexPath)
                }
                return self.getOfflinePaymentMethodSelectedCell(indexPath: indexPath)
            case 1 :
                return self.getTermsAndConditionsCell(indexPath: indexPath)
            case 2 :
                return self.getConfirmPaymentButtonCell(indexPath: indexPath)
            default :
                return self.getCancelPaymentButtonCell(indexPath: indexPath)
            }
        }
        return UITableViewCell()
        
    }
    
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
    }

    internal func loadGroupsAndStartPaymentVault(_ animated : Bool = true){
        
        if self.viewModel.paymentMethodSearch == nil {
            MPServicesBuilder.searchPaymentMethods(self.viewModel.preference!.getAmount(), excludedPaymentTypeIds: self.viewModel.preference?.getExcludedPaymentTypesIds(), excludedPaymentMethodIds: self.viewModel.preference?.getExcludedPaymentMethodsIds(), success: { (paymentMethodSearch) in
                self.viewModel.paymentMethodSearch = paymentMethodSearch
                
                self.startPaymentVault()
                }, failure: { (error) in
                    self.requestFailure(error, callback: {}, callbackCancel:
                        {
                            self.navigationController!.dismiss(animated: true, completion: {
                            })})
            })
        } else {
            self.startPaymentVault(animated)
        }
        
    }
    
    internal func startPaymentVault(_ animated : Bool = false){
        self.registerAllCells()
        
        let paymentVaultVC = MPFlowBuilder.startPaymentVaultInCheckout(self.viewModel.preference!.getAmount(), paymentPreference: self.viewModel.preference!.getPaymentPreference(), paymentMethodSearch: self.viewModel.paymentMethodSearch!, callback: { (paymentMethod, token, issuer, payerCost) in
            self.paymentVaultCallback(paymentMethod, token : token, issuer : issuer, payerCost : payerCost, animated : animated)
        })
        
        var callbackCancel : ((Void) -> Void)
        
        // Set action for cancel callback
        if self.viewModel.paymentMethod == nil {
            callbackCancel = { Void -> Void in
                self.callbackCancel!()
            }
        } else {
            callbackCancel = { Void -> Void in
               self.navigationController!.popViewController(animated: true)
            }
        }
        self.hideLoading()
        (paymentVaultVC.viewControllers[0] as! PaymentVaultViewController).callbackCancel = callbackCancel
        self.navigationController?.pushViewController(paymentVaultVC.viewControllers[0], animated: animated)
        
    }
    
    internal func startRecoverCard(){
         MPServicesBuilder.getPaymentMethods({ (paymentMethods) in
        let cardFlow = MPFlowBuilder.startCardFlow(amount: (self.viewModel.preference?.getAmount())!, cardInformation : nil, callback: { (paymentMethod, token, issuer, payerCost) in
             self.paymentVaultCallback(paymentMethod, token : token, issuer : issuer, payerCost : payerCost, animated : true)
            }, callbackCancel: {
                self.navigationController!.popToViewController(self, animated: true)
        })
        self.navigationController?.pushViewController(cardFlow.viewControllers[0], animated: true)
         }) { (error) in
            
        }
        
        
    }
    internal func startAuthCard(_ token:Token ){
        
        let vc = MPStepBuilder.startSecurityCodeForm(paymentMethod: self.viewModel.paymentMethod!, cardInfo: token) { (token) in
            self.token = token
            self.navigationController!.popToViewController(self, animated: true)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
            
    }
    
    
    @objc fileprivate func confirmPayment(){
        
        self.showLoading()
        if self.viewModel.isPaymentMethodSelectedCard(){
            self.confirmPaymentOn()
        } else {
            self.confirmPaymentOff()
        }
    }
    
    internal func paymentVaultCallback(_ paymentMethod : PaymentMethod, token : Token?, issuer : Issuer?, payerCost : PayerCost?, animated : Bool = true){

        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.navigationController!.view.layer.add(transition, forKey: nil)
        self.navigationController!.popToRootViewController(animated: animated)
        self.showLoading()
        
        self.viewModel.paymentMethod = paymentMethod
        self.token = token
        if (issuer != nil){
            self.issuer = issuer
        }

        self.viewModel.payerCost = payerCost
        self.hideLoading()
    }
    
    
    internal func confirmPaymentOff(){
        MercadoPago.createMPPayment(self.viewModel.preference!.payer.email, preferenceId: self.viewModel.preference!._id, paymentMethod: self.viewModel.paymentMethod!,success: { (payment) -> Void in

            MPTracker.trackPaymentOffEvent(String(payment._id), mpDelegate: MercadoPagoContext.sharedInstance)
            
           self.displayPaymentResult(payment)
           }, failure : { (error) -> Void in
                self.requestFailure(error, callback: {
                    self.navigationController?.dismiss(animated: true, completion: {})
                    self.confirmPayment()
                })
        })
        
    }

    internal func confirmPaymentOn(){
        MercadoPago.createMPPayment(self.viewModel.preference!.payer.email, preferenceId: self.viewModel.preference!._id, paymentMethod: self.viewModel.paymentMethod!,token : self.token, installments: self.viewModel.payerCost!.installments , issuer: self.issuer,success: { (payment) -> Void in
            
            
                self.clearMercadoPagoStyle()
                self.navigationController!.popViewController(animated: true)

                self.displayPaymentResult(payment)
          
            }, failure : { (error) -> Void in
                self.requestFailure(error, callback: {
                    self.navigationController?.dismiss(animated: true, completion: {})
                    self.confirmPayment()
                })
        })
    }
    
    internal func displayPaymentResult(_ payment: Payment){
        
        let congrats = MPStepBuilder.startPaymentResultStep(payment, paymentMethod: self.viewModel.paymentMethod!, callback: { (payment, status) in
            if status == MPStepBuilder.CongratsState.cancel_SELECT_OTHER || status == MPStepBuilder.CongratsState.cancel_RETRY {
                self.navigationController!.setNavigationBarHidden(false, animated: false)
                self.viewModel.paymentMethod = nil
                self.navigationController!.viewControllers[0].title = ""
                self.navigationController!.popToRootViewController(animated: false)
            } else  if status == MPStepBuilder.CongratsState.cancel_RECOVER {
                self.navigationController!.setNavigationBarHidden(false, animated: false) 
                self.navigationController!.viewControllers[0].title = ""
                self.navigationController!.popToRootViewController(animated: false)
                self.recover = true
            }else  if status == MPStepBuilder.CongratsState.call_FOR_AUTH {
                self.navigationController!.setNavigationBarHidden(false, animated: false)
                self.navigationController!.viewControllers[0].title = ""
                self.navigationController!.popToRootViewController(animated: false)
                self.auth = true
            }else {
                self.dismiss(animated: true, completion: {})
                self.callback(payment)
            }
        })
        self.navigationController!.pushViewController(congrats, animated: true)
    }
 
    fileprivate func loadPreference(){
        MPServicesBuilder.getPreference(self.preferenceId, success: { (preference) in
                if let error = preference.validate() {
                    // Invalid preference - cannot continue
                    let mpError =  MPError(message: "Hubo un error".localized, messageDetail: error, retry: false)
                    self.displayFailure(mpError)
                } else {
                    self.viewModel.preference = preference
                    self.checkoutTable.reloadData()
                    self.loadGroupsAndStartPaymentVault(false)
                }
            }, failure: { (error) in
                // Error in service - retry
                self.requestFailure(error, callback: {
                    self.loadPreference()
                    }, callbackCancel: {
                    self.navigationController!.dismiss(animated: true, completion: {})
                })
        })
    }
    
    fileprivate func startPayerCostStep(){
        let pcf = MPStepBuilder.startPayerCostForm([self.viewModel.paymentMethod!], issuer: self.issuer, token: self.token!, amount: self.viewModel.preference!.getAmount(), paymentPreference: self.viewModel.preference!.paymentPreference, callback: { (payerCost) -> Void in
            self.viewModel.payerCost = payerCost as? PayerCost
            self.navigationController?.popViewController(animated: true)
            self.checkoutTable.reloadData()
        })
        pcf.callbackCancel = { self.navigationController?.popViewController(animated: true)}
        self.navigationController?.pushViewController(pcf, animated: true)
    }
    
    fileprivate func registerAllCells(){
        
        //Register rows
        let payerCostTitleTableViewCell = UINib(nibName: "PayerCostTitleTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(payerCostTitleTableViewCell, forCellReuseIdentifier: "payerCostTitleTableViewCell")
        
        let purchaseDetailTableViewCell = UINib(nibName: "PurchaseDetailTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseDetailTableViewCell, forCellReuseIdentifier: "purchaseDetailTableViewCell")
        
        let confirmPaymentTableViewCell = UINib(nibName: "ConfirmPaymentTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(confirmPaymentTableViewCell, forCellReuseIdentifier: "confirmPaymentTableViewCell")
        
        let purchaseItemDetailTableViewCell = UINib(nibName: "PurchaseItemDetailTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseItemDetailTableViewCell, forCellReuseIdentifier: "purchaseItemDetailTableViewCell")
        
        let purchaseItemDescriptionTableViewCell = UINib(nibName: "PurchaseItemDescriptionTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseItemDescriptionTableViewCell, forCellReuseIdentifier: "purchaseItemDescriptionTableViewCell")
        
        let purchaseSimpleDetailTableViewCell = UINib(nibName: "PurchaseSimpleDetailTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseSimpleDetailTableViewCell, forCellReuseIdentifier: "purchaseSimpleDetailTableViewCell")
        
        let purchaseItemAmountTableViewCell = UINib(nibName: "PurchaseItemAmountTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseItemAmountTableViewCell, forCellReuseIdentifier: "purchaseItemAmountTableViewCell")
        
        let paymentMethodSelectedTableViewCell = UINib(nibName: "PaymentMethodSelectedTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(paymentMethodSelectedTableViewCell, forCellReuseIdentifier: "paymentMethodSelectedTableViewCell")
        
        let exitButtonCell = UINib(nibName: "ExitButtonTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(exitButtonCell, forCellReuseIdentifier: "exitButtonCell")
        
        let offlinePaymentMethodCell = UINib(nibName: "OfflinePaymentMethodCell", bundle: self.bundle)
        self.checkoutTable.register(offlinePaymentMethodCell, forCellReuseIdentifier: "offlinePaymentMethodCell")
        
        let purchaseTermsAndConditions = UINib(nibName: "TermsAndConditionsViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseTermsAndConditions, forCellReuseIdentifier: "termsAndConditionsViewCell")
        
        self.checkoutTable.delegate = self
        self.checkoutTable.dataSource = self
        self.checkoutTable.separatorStyle = .none
    }
    
    private func getMainTitleCell(indexPath : IndexPath) -> UITableViewCell{
        let payerCostTitleTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "payerCostTitleTableViewCell", for: indexPath) as! PayerCostTitleTableViewCell
        payerCostTitleTableViewCell.setTitle(string: "Confirma tu compra".localized)
        payerCostTitleTableViewCell.title.textColor = UIColor.blueMercadoPago()
        payerCostTitleTableViewCell.cell.backgroundColor = UIColor.white()
        
        return payerCostTitleTableViewCell
    }
    
    private func getPurchaseDetailCell(indexPath : IndexPath, title : String, amount : Double, payerCost : PayerCost? = nil, addSeparatorLine : Bool = true) -> UITableViewCell{
        let currency = MercadoPagoContext.getCurrency()
        if self.viewModel.shouldDisplayNoRate() {
            let purchaseDetailCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "purchaseDetailTableViewCell", for: indexPath) as! PurchaseDetailTableViewCell
            purchaseDetailCell.fillCell(title, amount: amount, currency: currency, payerCost: payerCost)
            return purchaseDetailCell
        }
        
        return getPurchaseSimpleDetailCell(indexPath: indexPath, title: title, amount: amount, payerCost : payerCost, addSeparatorLine: addSeparatorLine)
    }
    
    private func getPurchaseSimpleDetailCell(indexPath : IndexPath, title : String, amount : Double, payerCost : PayerCost? = nil, addSeparatorLine : Bool = true) -> UITableViewCell{
        let currency = MercadoPagoContext.getCurrency()
        let purchaseSimpleDetailTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "purchaseSimpleDetailTableViewCell", for: indexPath) as! PurchaseSimpleDetailTableViewCell
        purchaseSimpleDetailTableViewCell.fillCell(title, amount: amount, currency: currency, payerCost: payerCost, addSeparatorLine : addSeparatorLine)
        return purchaseSimpleDetailTableViewCell
    }
    
    
    private func getConfirmPaymentButtonCell(indexPath : IndexPath) -> UITableViewCell{
        let confirmPaymentTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "confirmPaymentTableViewCell", for: indexPath) as! ConfirmPaymentTableViewCell
        confirmPaymentTableViewCell.confirmPaymentButton.addTarget(self, action: #selector(confirmPayment), for: .touchUpInside)
        return confirmPaymentTableViewCell
    }
    
    private func getPurchaseItemDetailCell(indexPath : IndexPath) -> UITableViewCell{
        let currency = MercadoPagoContext.getCurrency()
        let purchaseItemDetailCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "purchaseItemDetailTableViewCell", for: indexPath) as! PurchaseItemDetailTableViewCell
        purchaseItemDetailCell.fillCell(item: (self.viewModel.preference!.items![indexPath.row]), currency: currency)
        return purchaseItemDetailCell
    }
    
    
    private func getOnlinePaymentMethodSelectedCell(indexPath : IndexPath) ->UITableViewCell {
        let paymentMethodSelectedTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "paymentMethodSelectedTableViewCell", for: indexPath) as! PaymentMethodSelectedTableViewCell
        
        paymentMethodSelectedTableViewCell.fillCell(self.viewModel.paymentMethod!, amount : self.viewModel.payerCost!.totalAmount, payerCost : self.viewModel.payerCost, lastFourDigits: self.token!.lastFourDigits)
        
        paymentMethodSelectedTableViewCell.selectOtherPaymentMethodButton.addTarget(self, action: #selector(loadGroupsAndStartPaymentVault), for: .touchUpInside)
        return paymentMethodSelectedTableViewCell
    }
    
    private func getOfflinePaymentMethodSelectedCell(indexPath : IndexPath) ->UITableViewCell {
        let offlinePaymentMethodCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "offlinePaymentMethodCell", for: indexPath) as! OfflinePaymentMethodCell
        let paymentMethodSearchItem = self.viewModel.paymentMethodSearchItemSelected()
        offlinePaymentMethodCell.fillCell(paymentMethodSearchItem, amount: self.viewModel.preference!.getAmount(), paymentMethod : self.viewModel.paymentMethod!, currency: MercadoPagoContext.getCurrency())
        offlinePaymentMethodCell.changePaymentButton.addTarget(self, action: #selector(loadGroupsAndStartPaymentVault), for: .touchUpInside)
        return offlinePaymentMethodCell
    }
    
    
    
    private func getCancelPaymentButtonCell(indexPath : IndexPath) -> UITableViewCell {
        let exitButtonCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "exitButtonCell", for: indexPath) as! ExitButtonTableViewCell
        exitButtonCell.exitButton.addTarget(self, action: #selector(CheckoutViewController.exitCheckoutFlow), for: .touchUpInside)
        return exitButtonCell
    }
    
    private func getTermsAndConditionsCell(indexPath : IndexPath) -> UITableViewCell {
        let tycCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "termsAndConditionsViewCell", for: indexPath) as! TermsAndConditionsViewCell
        tycCell.delegate = self
        return tycCell
    }
    
    internal func openTermsAndConditions(_ title: String, url : URL){
        let webVC = WebViewController(url: url)
        webVC.title = title
        self.navigationController!.pushViewController(webVC, animated: true)
        
    }
 
    internal func exitCheckoutFlow(){
        self.callbackCancel!()
    }
    
    override func getNavigationBarTitle() -> String {
        if (self.checkoutTable.contentOffset.y == -64) {
            return ""
        }
        return "Confirma tu compra".localized
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView){
        self.didScrollInTable(scrollView)
    }
}

open class CheckoutViewModel {
    
    var paymentMethod : PaymentMethod?
    var payerCost : PayerCost?
    
    var paymentMethodSearch : PaymentMethodSearch?
    var shippingIncluded = false
    var freeShippingIncluded = false
    var discountIncluded = false
    
    var preference : CheckoutPreference?
    
    func isPaymentMethodSelectedCard() -> Bool {
        return self.paymentMethod != nil && self.paymentMethod!.isCard()
    }
    
    func numberOfSections() -> Int {
        return self.preference != nil ? 4 : 0
    }
    
    func isPaymentMethodSelected() -> Bool {
        return paymentMethod != nil
    }
    
    func isUniquePaymentMethodAvailable() -> Bool {
        return self.paymentMethodSearch != nil && self.paymentMethodSearch!.paymentMethods.count == 1
    }
    
    func paymentMethodSearchItemSelected() -> PaymentMethodSearchItem {
        let paymentTypeIdEnum = PaymentTypeId(rawValue : self.paymentMethod!.paymentTypeId)
        let paymentMethodSearchItemSelected : PaymentMethodSearchItem
        if paymentTypeIdEnum != nil && paymentTypeIdEnum == PaymentTypeId.ACCOUNT_MONEY {
            paymentMethodSearchItemSelected = PaymentMethodSearchItem()
            paymentMethodSearchItemSelected.description = "Dinero en cuenta"
        } else {
            paymentMethodSearchItemSelected = Utils.findPaymentMethodSearchItemInGroups(self.paymentMethodSearch!, paymentMethodId: self.paymentMethod!._id, paymentTypeId: paymentTypeIdEnum)!
        }
        return paymentMethodSearchItemSelected
    }
    
    func checkoutTableHeaderHeight(_ section : Int) -> CGFloat {
        return 0
    }
    
    func numberOfRowsInMainSection() -> Int {
        // Productos
        var numberOfRows = 1
        if self.isPaymentMethodSelectedCard() {
            numberOfRows = numberOfRows +  1
        }
        
        if self.discountIncluded {
            numberOfRows = numberOfRows + 1
        }
        
        if self.shippingIncluded {
            numberOfRows = numberOfRows + 1
        }
        
        // Total
        numberOfRows = numberOfRows + 1
        return numberOfRows
        
    }
    
    func heightForRow(_ indexPath : IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                // Productos
                return PurchaseSimpleDetailTableViewCell.ROW_HEIGHT
            case 1:
                if  shouldDisplayNoRate() {
                    return PurchaseDetailTableViewCell.getCellHeight(payerCost : self.payerCost)
                }
                return PurchaseSimpleDetailTableViewCell.ROW_HEIGHT
            case 2:
                return (self.isPaymentMethodSelectedCard()) ? PurchaseSimpleDetailTableViewCell.ROW_HEIGHT : ConfirmPaymentTableViewCell.ROW_HEIGHT
            default:
                return ConfirmPaymentTableViewCell.ROW_HEIGHT
            }
        } else if indexPath.section == 2 {
                return PurchaseItemDetailTableViewCell.getCellHeight(item: self.preference!.items![indexPath.row])
        } else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                return PaymentMethodSelectedTableViewCell.getCellHeight(payerCost : self.payerCost)
            case 1 :
                return TermsAndConditionsViewCell.getCellHeight()
            case 2 :
                return ConfirmPaymentTableViewCell.ROW_HEIGHT
            default:
                return ExitButtonTableViewCell.ROW_HEIGHT
            }
        }
        return 0
    }
    
    func isPreferenceLoaded() -> Bool {
        return self.preference != nil
    }
    
    func shouldDisplayNoRate() -> Bool {
        return self.payerCost != nil && !self.payerCost!.hasInstallmentsRate() && self.payerCost!.installments != 1
    }
}
