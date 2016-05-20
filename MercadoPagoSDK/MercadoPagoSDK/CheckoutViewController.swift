//
//  CheckoutViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 13/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class CheckoutViewController: MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var preferenceId : String!
    var preference : CheckoutPreference?
    var publicKey : String!
    var accessToken : String!
    var bundle : NSBundle? = MercadoPago.getBundle()
    var callback : (Payment -> Void)!
    var paymentMethod : PaymentMethod?
    var issuer : Issuer?
    var token : Token?
    var paymentButton : MPButton?
    var paymentMethodSearch : PaymentMethodSearch?
    var payerCost : PayerCost?
    
    private var reviewAndConfirmContent = Set<String>()
    
    @IBOutlet weak var checkoutTable: UITableView!
    
    init(preferenceId : String, callback : (Payment -> Void)){
        super.init(nibName: "CheckoutViewController", bundle: MercadoPago.getBundle())
        self.publicKey = MercadoPagoContext.publicKey()
        self.accessToken = MercadoPagoContext.merchantAccessToken()
        self.preferenceId = preferenceId
        self.callback = callback
        self.callbackCancel = {
            self.dismissViewControllerAnimated(true, completion: { 
                
            })
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {

        super.viewDidLoad()
        
        self.checkoutTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0.01))
        
        //Display preference description by default
        self.displayPreferenceDescription = true
        
        self.title = "¿Cómo quieres pagar?".localized

    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Remove navigation items
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showLoading()
        if preference == nil {
            self.loadPreference()
        } else {
            if self.paymentMethod != nil {
                self.checkoutTable.reloadData()
                self.hideLoading()
            } else {
                self.loadGroupsAndStartPaymentVault()
            }
        }

    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && displayPreferenceDescription {
            return 0.1
        }
        return 8
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if self.displayPreferenceDescription {
                return 120
            }
            return 0
        }
        
        if indexPath.row == 0 {
            if self.paymentMethod == nil || (self.paymentMethod != nil && self.paymentMethod!.isOfflinePaymentMethod()){
                return 80
            }
            return 48
        } else if indexPath.row == 1 {
            if self.paymentMethod == nil || (self.paymentMethod != nil && self.paymentMethod!.isOfflinePaymentMethod()){
                return 60
            }
            return 48
        } else if indexPath.row == 2 {
            if self.paymentMethod == nil || (self.paymentMethod != nil && self.paymentMethod!.isOfflinePaymentMethod()){
                return 180
            }
            return 60
        }
        return 180
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.displayPreferenceDescription ? 1 : 0
        }
        if (self.paymentMethod == nil) {
            return 2
        } else if self.paymentMethod!.isOfflinePaymentMethod(){
            return 3
        }
        return 4
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        if indexPath.section == 0 {
            let preferenceDescriptionCell = tableView.dequeueReusableCellWithIdentifier("preferenceDescriptionCell", forIndexPath: indexPath) as! PreferenceDescriptionTableViewCell
            
            preferenceDescriptionCell.fillRowWithPreference(self.preference!)
            
            return preferenceDescriptionCell
        }
    
        if indexPath.row == 0 {
            if self.paymentMethod != nil {
                if self.paymentMethod!.isOfflinePaymentMethod() {
                    self.title = "Revisa si está todo bien...".localized
                    let cell = tableView.dequeueReusableCellWithIdentifier("offlinePaymentCell", forIndexPath: indexPath) as! OfflinePaymentMethodCell
                    let paymentMethodSearchItemSelected = Utils.findPaymentMethodSearchItemInGroups(self.paymentMethodSearch!, paymentMethodId: self.paymentMethod!._id, paymentTypeId: self.paymentMethod!.paymentTypeId)
                    let displayEditSelection = (paymentMethodSearch!.groups.count > 1)
                    cell.fillRowWithPaymentMethod(self.paymentMethod!, paymentMethodSearchItemSelected: paymentMethodSearchItemSelected!, displayCustomIndicator: displayEditSelection)
                    return cell
                } else {
                    self.title = "Tantito más y terminas…".localized
                    let paymentSearchCell = tableView.dequeueReusableCellWithIdentifier("paymentSelectedCell", forIndexPath: indexPath) as! PaymentMethodSelectedTableViewCell
                    paymentSearchCell.paymentIcon.image = MercadoPago.getImageFor(self.paymentMethod!, forCell: true)
                    paymentSearchCell.paymentDescription.text = "terminada en ".localized + self.token!.lastFourDigits
                    ViewUtils.drawBottomLine(47, width: paymentSearchCell.bounds.width, inView: paymentSearchCell)
                    return paymentSearchCell
                }
                
            }
            
            return tableView.dequeueReusableCellWithIdentifier("selectPaymentMethodCell", forIndexPath: indexPath) as! SelectPaymentMethodCell
        } else if indexPath.row == 1 {
            
            if !paymentMethod!.isOfflinePaymentMethod() {
                let installmentsCell = self.checkoutTable.dequeueReusableCellWithIdentifier("installmentSelectionCell") as! InstallmentSelectionTableViewCell
                let installments = self.payerCost!.installments
                
                let additionalTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 67, green: 176,blue: 0), NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 13)!]
                
                let additionalText = payerCost?.installmentRate > 0 || payerCost?.installments == 1 ? "" : " Sin interes".localized
                let installmentsDescription = Utils.getTransactionInstallmentsDescription(String(installments), installmentAmount: self.payerCost!.installmentAmount, additionalString: NSAttributedString(string: additionalText, attributes: additionalTextAttributes))
                installmentsCell.installmentsDescription.attributedText = installmentsDescription
                return installmentsCell
            }
            
            let footer = self.checkoutTable.dequeueReusableCellWithIdentifier("paymentDescriptionFooter") as! PaymentDescriptionFooterTableViewCell
            
            footer.layer.shadowOffset = CGSizeMake(0, 1)
            footer.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).CGColor
            footer.layer.shadowRadius = 1
            footer.layer.shadowOpacity = 0.6
            footer.setAmount(self.preference!.getAmount())
            return footer

        } else if indexPath.row == 2 {
            if paymentMethod!.isOfflinePaymentMethod() {
                let termsAndConditionsButton = self.checkoutTable.dequeueReusableCellWithIdentifier("purchaseTermsAndConditions") as! TermsAndConditionsViewCell
                termsAndConditionsButton.paymentButton.addTarget(self, action: "confirmPayment", forControlEvents: .TouchUpInside)
                self.paymentButton = termsAndConditionsButton.paymentButton
                return termsAndConditionsButton
            } else {
                let totalAmount = self.payerCost == nil ? self.preference!.getAmount() : self.payerCost!.totalAmount
                if payerCost?.installmentRate > 0 {
                
                }
                let footer = self.checkoutTable.dequeueReusableCellWithIdentifier("paymentDescriptionFooter") as! PaymentDescriptionFooterTableViewCell
                
                footer.layer.shadowOffset = CGSizeMake(0, 1)
                footer.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).CGColor
                footer.layer.shadowRadius = 1
                footer.layer.shadowOpacity = 0.6
                footer.setAmount(totalAmount)
                return footer

            }
        } else if indexPath.row == 3 {
            let termsAndConditionsButton = self.checkoutTable.dequeueReusableCellWithIdentifier("purchaseTermsAndConditions") as! TermsAndConditionsViewCell
            termsAndConditionsButton.paymentButton.addTarget(self, action: "confirmPayment", forControlEvents: .TouchUpInside)
            self.paymentButton = termsAndConditionsButton.paymentButton
            return termsAndConditionsButton
        }
        
        return UITableViewCell()
        
    }
    
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.checkoutTable.deselectRowAtIndexPath(indexPath, animated: true)
        } else if indexPath.section == 1 && indexPath.row == 0 && self.paymentMethodSearch?.groups.count > 1 {
            self.checkoutTable.deselectRowAtIndexPath(indexPath, animated: true)
            self.loadGroupsAndStartPaymentVault(true)
        } else if indexPath.section == 1 && indexPath.row == 1 && paymentMethod != nil && !self.paymentMethod!.isOfflinePaymentMethod(){
            startPayerCostStep()
        }
    }
    
    
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == 1) ? 140 : 0
    }

    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let copyrightCell =  self.checkoutTable.dequeueReusableCellWithIdentifier("copyrightCell") as! CopyrightTableViewCell
            copyrightCell.cancelButton.addTarget(self, action: "invokeCallbackCancel", forControlEvents: .TouchUpInside)
            copyrightCell.drawBottomLine(self.view.bounds.width)
            return copyrightCell
        }
        return nil
    }
    
    internal func loadGroupsAndStartPaymentVault(animated : Bool = false){
        
        if self.paymentMethodSearch == nil {
            MPServicesBuilder.searchPaymentMethods(self.preference?.getExcludedPaymentTypesIds(), excludedPaymentMethodIds: self.preference?.getExcludedPaymentMethodsIds(), success: { (paymentMethodSearch) in
                self.paymentMethodSearch = paymentMethodSearch
                
                self.startPaymentVault()
                }, failure: { (error) in
                    self.requestFailure(error)
            })
        } else {
            self.startPaymentVault(animated)
        }
        
    }
    
    internal func startPaymentVault(animated : Bool = false){
        self.registerAllCells()
        
        let paymentVaultVC = MPFlowBuilder.startPaymentVaultInCheckout(self.preference!.getAmount(), purchaseTitle: self.preference!.getTitle(), currencyId: self.preference!.getCurrencyId(), pictureUrl : self.preference!.getPictureUrl(), paymentSettings: self.preference!.getPaymentSettings(), paymentMethodSearch: self.paymentMethodSearch!, callback: { (paymentMethod, token, issuer, payerCost) in
                let transition = CATransition()
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                self.navigationController!.view.layer.addAnimation(transition, forKey: nil)
                self.navigationController!.popToRootViewControllerAnimated(animated)
            
                self.paymentMethod = paymentMethod
                self.token = token
                self.issuer = issuer
                self.payerCost = payerCost
                self.checkoutTable.reloadData()
            
            
            
            
        })
        
        var callbackCancel : (Void -> Void)
        // Set action for cancel callback
        if self.paymentMethod == nil {
            callbackCancel = { Void -> Void in
                self.dismissViewControllerAnimated(true, completion: {
                })
            }
        } else {
            callbackCancel = { Void -> Void in
               self.navigationController!.popViewControllerAnimated(true)
            }
        }
        self.hideLoading()
        (paymentVaultVC.viewControllers[0] as! PaymentVaultViewController).callbackCancel = callbackCancel
        self.navigationController?.pushViewController(paymentVaultVC.viewControllers[0], animated: animated)
        
    }
    
    internal func confirmPayment(){
        
        self.showLoading()

        if (self.paymentMethod!.isOfflinePaymentMethod()){
            self.confirmPaymentOff()
        } else {
            self.confirmPaymentOn()
        }
    }
    
    internal func confirmPaymentOff(){
        MercadoPago.createMPPayment(self.preference!.payer.email, preferenceId: self.preference!._id, paymentMethod: self.paymentMethod!,success: { (payment) -> Void in
            if payment.isRejected() {
                let congratsRejected = MPStepBuilder.startPaymentCongratsStep(payment)
                self.navigationController!.pushViewController(congratsRejected, animated: true)
            } else {
                self.navigationController!.pushViewController(MPStepBuilder.startInstructionsStep(payment, callback: {(payment : Payment) -> Void  in
                    self.modalTransitionStyle = .CrossDissolve
                    self.dismissViewControllerAnimated(true, completion: {})
                        self.callback(payment)
                    }), animated: true)
            }
           }, failure : { (error) -> Void in
                self.requestFailure(error, callback: {
                    self.navigationController?.dismissViewControllerAnimated(true, completion: {})
                    self.confirmPayment()
                })
        })
        
    }
    
    internal func confirmPaymentOn(){
        MercadoPago.createMPPayment(self.preference!.payer.email, preferenceId: self.preference!._id, paymentMethod: self.paymentMethod!,token : self.token, installments: self.payerCost!.installments , issuer: self.issuer,success: { (payment) -> Void in
            
                self.clearMercadoPagoStyleAndGoBack()
                let congratsVC = MPStepBuilder.startPaymentCongratsStep(payment, callbackCancel: {
                    self.dismissViewControllerAnimated(true, completion: {
                        
                    })
                })
                self.navigationController?.pushViewController(congratsVC, animated: true)
            
            }, failure : { (error) -> Void in
                self.requestFailure(error, callback: {
                    self.navigationController?.dismissViewControllerAnimated(true, completion: {})
                    self.confirmPayment()
                })
        })
    }

    
    internal func togglePreferenceDescription(){
        self.togglePreferenceDescription(self.checkoutTable)
    }
    
    private func loadPreference(){
        MPServicesBuilder.getPreference(self.preferenceId, success: { (preference) in
                if let error = preference.validate() {
                    // Invalid preference - cannot continue
                    let mpError =  MPError(message: "Hubo un error".localized, messageDetail: error, retry: false)
                    self.displayFailure(mpError)
                } else {
                    self.preference = preference
                    self.loadGroupsAndStartPaymentVault(false)
                }
            }, failure: { (error) in
                // Error in service - retry
                self.requestFailure(error)
        })
    }
    
    private func startPayerCostStep(){
        let pcf = MPStepBuilder.startPayerCostForm(self.paymentMethod, issuer: self.issuer, token: self.token!, amount: self.preference!.getAmount(), minInstallments: nil, callback: { (payerCost) -> Void in
            self.payerCost = payerCost
            self.navigationController?.popViewControllerAnimated(true)
            self.checkoutTable.reloadData()
        })
        self.navigationController?.pushViewController(pcf, animated: true)
    }
    
    private func registerAllCells(){
        
        //Register rows
        let offlinePaymentMethodNib = UINib(nibName: "OfflinePaymentMethodCell", bundle: self.bundle)
        self.checkoutTable.registerNib(offlinePaymentMethodNib, forCellReuseIdentifier: "offlinePaymentCell")
        let preferenceDescriptionCell = UINib(nibName: "PreferenceDescriptionTableViewCell", bundle: self.bundle)
        self.checkoutTable.registerNib(preferenceDescriptionCell, forCellReuseIdentifier: "preferenceDescriptionCell")
        let selectPaymentMethodCell = UINib(nibName: "SelectPaymentMethodCell", bundle: self.bundle)
        self.checkoutTable.registerNib(selectPaymentMethodCell, forCellReuseIdentifier: "selectPaymentMethodCell")
        let paymentDescriptionFooter = UINib(nibName: "PaymentDescriptionFooterTableViewCell", bundle: self.bundle)
        self.checkoutTable.registerNib(paymentDescriptionFooter, forCellReuseIdentifier: "paymentDescriptionFooter")
        let purchaseTermsAndConditions = UINib(nibName: "TermsAndConditionsViewCell", bundle: self.bundle)
        self.checkoutTable.registerNib(purchaseTermsAndConditions, forCellReuseIdentifier: "purchaseTermsAndConditions")
        let copyrightCell = UINib(nibName: "CopyrightTableViewCell", bundle: self.bundle)
        self.checkoutTable.registerNib(copyrightCell, forCellReuseIdentifier: "copyrightCell")
        
        // Payment ON rows
        let paymentSelectedCell = UINib(nibName: "PaymentMethodSelectedTableViewCell", bundle: self.bundle)
        self.checkoutTable.registerNib(paymentSelectedCell, forCellReuseIdentifier: "paymentSelectedCell")
        let installmentSelectionCell = UINib(nibName: "InstallmentSelectionTableViewCell", bundle: self.bundle)
        self.checkoutTable.registerNib(installmentSelectionCell, forCellReuseIdentifier: "installmentSelectionCell")
        
        self.checkoutTable.delegate = self
        self.checkoutTable.dataSource = self
        self.checkoutTable.separatorStyle = .None
    }
    
    
}
