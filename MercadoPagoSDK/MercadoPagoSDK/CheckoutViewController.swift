//
//  CheckoutViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 13/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit


open class CheckoutViewController: MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate, TermsAndConditionsDelegate {

    var preferenceId : String!
    var preference : CheckoutPreference?
    var publicKey : String!
    var accessToken : String!
    var bundle : Bundle? = MercadoPago.getBundle()
    var callback : ((Payment) -> Void)!
    
    var viewModel : CheckoutViewModel?
    
    var issuer : Issuer?
    var token : Token?
    
    var payerCost : PayerCost?
    override open var screenName : String { get{ return "REVIEW_AND_CONFIRM" } }
    fileprivate var reviewAndConfirmContent = Set<String>()
    
    fileprivate var recover = false
    fileprivate var auth = false
    
    @IBOutlet weak var checkoutTable: UITableView!
    
    init(preferenceId : String, callback : @escaping ((Payment) -> Void),  callbackCancel : ((Void) -> Void)? = nil){
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
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {

        super.viewDidLoad()
        
        self.checkoutTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0.01))
        
        //Display preference description by default
        self.displayPreferenceDescription = true
        
        self.title = "¿Cómo quieres pagar?".localized

    }
    

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
    }

    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showLoading()
        if preference == nil {
            self.displayBackButton()
            self.navigationItem.leftBarButtonItem?.action = #selector(invokeCallbackCancel)
            self.loadPreference()
        } else {
            if self.viewModel!.paymentMethod != nil {
                self.title = "Revisa si está todo bien...".localized
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
                self.navigationItem.leftBarButtonItem?.action = #selector(invokeCallbackCancel)
                self.loadGroupsAndStartPaymentVault(true)
            }
        }

    }
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel!.checkoutTableHeaderHeight(section)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel!.heightForRow(indexPath)
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel!.numberOfSections()
    }
    

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.viewModel!.numberOfRowsInMainSection()
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if (indexPath as NSIndexPath).section == 0 {
            let preferenceDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "preferenceDescriptionCell", for: indexPath) as! PreferenceDescriptionTableViewCell
            
            preferenceDescriptionCell.fillRowWithPreference(self.preference!)
            
            return preferenceDescriptionCell
        }
        
        if self.viewModel!.isPaymentMethodSelectedCard() {
            return self.drawCreditCardTable(indexPath)
        } else {
            return self.drawOfflinePaymentMethodTable(indexPath)
        }
    }
    
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            self.checkoutTable.deselectRow(at: indexPath, animated: true)
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 &&  !self.viewModel!.isUniquePaymentMethodAvailable() {
            self.checkoutTable.deselectRow(at: indexPath, animated: true)
            self.showLoading()
            self.loadGroupsAndStartPaymentVault()
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 && self.viewModel!.isPaymentMethodSelectedCard() {
            startPayerCostStep()
        }
    }
    
    
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == 1) ? 44 : 0.1
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let exitButtonCell =  self.checkoutTable.dequeueReusableCell(withIdentifier: "exitButtonCell") as! ExitButtonTableViewCell
            exitButtonCell.callbackCancel = {
                self.dismiss(animated: true, completion: {})
            }
            exitButtonCell.exitButton.addTarget(self, action: #selector(CheckoutViewController.exitCheckoutFlow), for: .touchUpInside)
            return exitButtonCell
        }
        return nil
    }
    
    internal func loadGroupsAndStartPaymentVault(_ animated : Bool = true){
        
        if self.viewModel!.paymentMethodSearch == nil {
            MPServicesBuilder.searchPaymentMethods(self.preference!.getAmount(), excludedPaymentTypeIds: self.preference?.getExcludedPaymentTypesIds(), excludedPaymentMethodIds: self.preference?.getExcludedPaymentMethodsIds(), success: { (paymentMethodSearch) in
                self.viewModel!.paymentMethodSearch = paymentMethodSearch
                
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
        
        let paymentVaultVC = MPFlowBuilder.startPaymentVaultInCheckout(self.preference!.getAmount(), paymentPreference: self.preference!.getPaymentPreference(), paymentMethodSearch: self.viewModel!.paymentMethodSearch!, callback: { (paymentMethod, token, issuer, payerCost) in
            self.paymentVaultCallback(paymentMethod, token : token, issuer : issuer, payerCost : payerCost, animated : animated)
        })
        
        var callbackCancel : ((Void) -> Void)
        
        // Set action for cancel callback
        if self.viewModel!.paymentMethod == nil {
            callbackCancel = { Void -> Void in
                self.callbackCancel!()
            }
        } else {
            callbackCancel = { Void -> Void in
               self.navigationController!.popViewController(animated: true)
            }
        }
        self.hideLoading()
        self.navigationItem.leftBarButtonItem = nil
        (paymentVaultVC.viewControllers[0] as! PaymentVaultViewController).callbackCancel = callbackCancel
        self.navigationController?.pushViewController(paymentVaultVC.viewControllers[0], animated: animated)
        
    }
    
    internal func startRecoverCard(){
         MPServicesBuilder.getPaymentMethods({ (paymentMethods) in
        let cardFlow = MPFlowBuilder.startCardFlow(amount: (self.preference?.getAmount())!, cardInformation : nil, callback: { (paymentMethod, token, issuer, payerCost) in
             self.paymentVaultCallback(paymentMethod, token : token, issuer : issuer, payerCost : payerCost, animated : true)
            }, callbackCancel: {
                self.navigationController!.popToViewController(self, animated: true)
        })
        self.navigationController?.pushViewController(cardFlow.viewControllers[0], animated: true)
         }) { (error) in
            
        }
        
        
    }
    internal func startAuthCard(_ token:Token){
       
        MPServicesBuilder.getPaymentMethods({ (paymentMethods) in
            let cardFlow = MPFlowBuilder.startCardFlow(amount: (self.preference?.getAmount())!, cardInformation : nil, paymentMethods: paymentMethods, token: token, callback: { (paymentMethod, token, issuer, payerCost) in
                self.paymentVaultCallback(paymentMethod, token : token, issuer : issuer, payerCost : payerCost, animated : true)
                }, callbackCancel: {
                    self.navigationController!.popToViewController(self, animated: true)
            })
             self.navigationController?.pushViewController(cardFlow.viewControllers[0], animated: true)
            }) { (error) in
                
        }
       
        
    }
    
    
    internal func confirmPayment(){
        
        self.showLoading()
        if self.viewModel!.isPaymentMethodSelectedCard(){
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
        
        self.viewModel!.paymentMethod = paymentMethod
        self.token = token
        if (issuer != nil){
            self.issuer = issuer
        }

        self.payerCost = payerCost
    }
    
    
    internal func confirmPaymentOff(){
        MercadoPago.createMPPayment(self.preference!.payer.email, preferenceId: self.preference!._id, paymentMethod: self.viewModel!.paymentMethod!,success: { (payment) -> Void in

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
        MercadoPago.createMPPayment(self.preference!.payer.email, preferenceId: self.preference!._id, paymentMethod: self.viewModel!.paymentMethod!,token : self.token, installments: self.payerCost!.installments , issuer: self.issuer,success: { (payment) -> Void in
            
            
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
        
        let congrats = MPStepBuilder.startPaymentResultStep(payment, paymentMethod: self.viewModel!.paymentMethod!, callback: { (payment, status) in
            if status == MPStepBuilder.CongratsState.cancel_SELECT_OTHER || status == MPStepBuilder.CongratsState.cancel_RETRY {
                self.navigationController!.setNavigationBarHidden(false, animated: false)
                self.viewModel!.paymentMethod = nil
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
                    self.preference = preference
                    self.preference?.loadingImageWithCallback({ (void) in
                        self.checkoutTable.reloadData()
                    })
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
        let pcf = MPStepBuilder.startPayerCostForm(self.viewModel!.paymentMethod, issuer: self.issuer, token: self.token!, amount: self.preference!.getAmount(), paymentPreference: self.preference!.paymentPreference, callback: { (payerCost) -> Void in
            self.payerCost = payerCost
            self.navigationController?.popViewController(animated: true)
            self.checkoutTable.reloadData()
        })
        pcf.callbackCancel = { self.navigationController?.popViewController(animated: true)}
        self.navigationController?.pushViewController(pcf, animated: true)
    }
    
    fileprivate func registerAllCells(){
        
        //Register rows
        let offlinePaymentMethodNib = UINib(nibName: "OfflinePaymentMethodCell", bundle: self.bundle)
        self.checkoutTable.register(offlinePaymentMethodNib, forCellReuseIdentifier: "offlinePaymentCell")
        let preferenceDescriptionCell = UINib(nibName: "PreferenceDescriptionTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(preferenceDescriptionCell, forCellReuseIdentifier: "preferenceDescriptionCell")
        let selectPaymentMethodCell = UINib(nibName: "SelectPaymentMethodCell", bundle: self.bundle)
        self.checkoutTable.register(selectPaymentMethodCell, forCellReuseIdentifier: "selectPaymentMethodCell")
        let paymentDescriptionFooter = UINib(nibName: "PaymentDescriptionFooterTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(paymentDescriptionFooter, forCellReuseIdentifier: "paymentDescriptionFooter")
        let purchaseTermsAndConditions = UINib(nibName: "TermsAndConditionsViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseTermsAndConditions, forCellReuseIdentifier: "purchaseTermsAndConditions")
        let exitButtonCell = UINib(nibName: "ExitButtonTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(exitButtonCell, forCellReuseIdentifier: "exitButtonCell")
        
        // Payment ON rows
        let paymentSelectedCell = UINib(nibName: "PaymentMethodSelectedTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(paymentSelectedCell, forCellReuseIdentifier: "paymentSelectedCell")
        let installmentSelectionCell = UINib(nibName: "InstallmentSelectionTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(installmentSelectionCell, forCellReuseIdentifier: "installmentSelectionCell")
        
        self.checkoutTable.delegate = self
        self.checkoutTable.dataSource = self
        self.checkoutTable.separatorStyle = .none
    }
    
    internal func drawOfflinePaymentMethodTable(_ indexPath : IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).row {
        case 0:
            let cell = self.checkoutTable.dequeueReusableCell(withIdentifier: "offlinePaymentCell") as! OfflinePaymentMethodCell
            cell.fillRowWithPaymentMethod(self.viewModel!.paymentMethod!, paymentMethodSearchItemSelected: self.viewModel!.paymentMethodSearchItemSelected())
            if self.viewModel!.isUniquePaymentMethodAvailable() {
                cell.selectionStyle = .none
                cell.accessoryType = .none
            }
            return cell
        case 1 :
            let footer = self.checkoutTable.dequeueReusableCell(withIdentifier: "paymentDescriptionFooter") as! PaymentDescriptionFooterTableViewCell
            
            footer.layer.shadowOffset = CGSize(width: 0, height: 1)
            footer.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).cgColor
            footer.layer.shadowRadius = 1
            footer.layer.shadowOpacity = 0.6
            footer.setAmount(amount: self.preference!.getAmount(), currency: CurrenciesUtil.getCurrencyFor(self.preference!.getCurrencyId()))
            return footer
        case 2 :
            let termsAndConditionsButton = self.checkoutTable.dequeueReusableCell(withIdentifier: "purchaseTermsAndConditions") as! TermsAndConditionsViewCell
            termsAndConditionsButton.paymentButton.addTarget(self, action: #selector(CheckoutViewController.confirmPayment), for: .touchUpInside)
            termsAndConditionsButton.delegate = self
            return termsAndConditionsButton
        default:
            return UITableViewCell()
        }
    }
    
    internal func drawCreditCardTable(_ indexPath : IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).row {
        case 0:
            let paymentSearchCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "paymentSelectedCell") as! PaymentMethodSelectedTableViewCell
            paymentSearchCell.fillRowWithPaymentMethod(self.viewModel!.paymentMethod!, lastFourDigits: self.token!.lastFourDigits)
            ViewUtils.drawBottomLine(y : 47, width: self.view.bounds.width, inView: paymentSearchCell)
            return paymentSearchCell
        case 1:
            let installmentsCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "installmentSelectionCell") as! InstallmentSelectionTableViewCell
            installmentsCell.fillCell(self.payerCost!)
            return installmentsCell
        case 2 :
            let totalAmount = self.payerCost == nil ? self.preference!.getAmount() : self.payerCost!.totalAmount
            let footer = self.checkoutTable.dequeueReusableCell(withIdentifier: "paymentDescriptionFooter") as! PaymentDescriptionFooterTableViewCell
            
            footer.layer.shadowOffset = CGSize(width: 0, height: 1)
            footer.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).cgColor
            footer.layer.shadowRadius = 1
            footer.layer.shadowOpacity = 0.6
            footer.setAmount(amount: totalAmount, currency: CurrenciesUtil.getCurrencyFor(self.preference!.getCurrencyId()))
            return footer
        default:
            let termsAndConditionsButton = self.checkoutTable.dequeueReusableCell(withIdentifier: "purchaseTermsAndConditions") as! TermsAndConditionsViewCell
            termsAndConditionsButton.paymentButton.addTarget(self, action: #selector(CheckoutViewController.confirmPayment), for: .touchUpInside)
            return termsAndConditionsButton
        }
    }
    
    internal func openTermsAndConditions(_ title: String, url : URL){
        let webVC = WebViewController(url: url)
        webVC.title = title
        self.navigationController!.pushViewController(webVC, animated: true)
        
    }
 
    internal func exitCheckoutFlow(){
        self.callbackCancel!()
    }
}

open class CheckoutViewModel {
    
    var paymentMethod : PaymentMethod?
    var paymentMethodSearch : PaymentMethodSearch?
    
    func isPaymentMethodSelectedCard() -> Bool {
        return self.paymentMethod != nil && paymentMethod!.isCard()
    }
    
    func numberOfSections() -> Int {
        return (self.paymentMethod != nil) ? 2 : 0
    }
    
    func isPaymentMethodSelected() -> Bool {
        return paymentMethod != nil
    }
    
    func numberOfRowsInMainSection() -> Int {
        if (self.paymentMethod == nil) {
            return 2
        } else if !isPaymentMethodSelectedCard(){
            return 3
        }
        return 4
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
        if section == 0 {
            return 0.1
        }
        return 13
    }
    
    func heightForRow(_ indexPath : IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 120
        }
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            if self.isPaymentMethodSelectedCard() {
                return 48
            }
            return 80
        case 1:
            if self.isPaymentMethodSelectedCard() {
                return 48
            }
            return 60
        case 2:
            if self.isPaymentMethodSelectedCard() {
                return 50
            }
            return 160
        default:
            return 160
        }

    }
}
