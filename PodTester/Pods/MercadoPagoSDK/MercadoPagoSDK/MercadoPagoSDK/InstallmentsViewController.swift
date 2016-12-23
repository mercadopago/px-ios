//
//  InstallmentsViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 9/1/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class InstallmentsViewController : MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var publicKey : String?
    
    @IBOutlet weak fileprivate var tableView : UITableView!
    var loadingView : UILoadingView!
    
    var payerCosts : [PayerCost]?
    var issuer : Issuer?
    
    var paymentMethodId : String?
    var amount : Double = 0
    var callback : ((_ payerCost: PayerCost?) -> Void)?
    var paymentPreference : PaymentPreference?
    override open var screenName : String { get { return "CARD_INSTALLMENTS" } }
    var bundle : Bundle? = MercadoPago.getBundle()
    var maxInstallments : Int?
    var installment : Installment?
    
    init(payerCosts: [PayerCost]? = nil, paymentPreference: PaymentPreference? = nil, amount: Double, issuer: Issuer?, paymentMethodId: String?, callback: @escaping (_ payerCost: PayerCost?) -> Void) {
        super.init(nibName: "InstallmentsViewController", bundle: bundle)
        if((payerCosts) != nil){
             self.payerCosts = payerCosts
        }
        if (paymentPreference != nil){
            self.maxInstallments = paymentPreference?.maxAcceptedInstallments
        }
        self.paymentPreference = paymentPreference
        self.paymentMethodId = paymentMethodId
        self.issuer = issuer
        self.amount = amount
        self.callback = callback
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    } 
    
    public init() {
        super.init(nibName: "InstallmentsViewController", bundle: self.bundle)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.payerCosts == nil {
            self.showLoading()
            self.getInstallments()
        }
        self.tableView.reloadData()
    }
    fileprivate func getInstallments(){
        MPServicesBuilder.getInstallments(amount: self.amount, issuer: self.issuer, paymentMethodId: self.paymentMethodId!, success: { (installments) -> Void in
            self.payerCosts = installments![0].payerCosts
            self.installment = installments![0]
            self.tableView.reloadData()
            self.hideLoading()
        }) { (error) -> Void in
            self.requestFailure(error)
        }
        
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Cuotas".localized

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
       let installmentNib = UINib(nibName: "InstallmentTableViewCell", bundle: self.bundle)
        self.tableView.register(installmentNib, forCellReuseIdentifier: "installmentCell")
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.payerCosts == nil){
            return 0
        }else{
            if (installment != nil){
                return installment!.numberOfPayerCostToShow(maxInstallments)
            }else{
                return (self.payerCosts?.count)!
            }
            
        }
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pccell : InstallmentTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "installmentCell") as! InstallmentTableViewCell
        
        let payerCost : PayerCost = self.payerCosts![(indexPath as NSIndexPath).row]
        pccell.fillWithPayerCost(payerCost, amount: amount)
        
        return pccell
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callback!(self.payerCosts![(indexPath as NSIndexPath).row])
    }
    
    internal override func executeBack(){
        if self.callbackCancel != nil {
            self.callbackCancel!()
        }else{
            super.executeBack()
        }
        
    }

   
}
