//
//  StepsExamplesViewController.swift
//  MercadoPagoSDKExamples
//
//  Created by Maria cristina rodriguez on 29/6/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoSDK

class StepsExamplesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let stepsExamples = [
        "Selección de medio de pago completa".localized,
        "Cobra con tarjeta con cuotas".localized,
        "Cobra con tarjeta sin cuotas".localized,
        "Selección de medio de pago simple".localized,
        "Selección de Banco".localized,
        "Selección de Cuotas".localized,
        "Crear Pago".localized
    ]
    
    @IBOutlet weak var stepsExamplesTable: UITableView!
    
    var paymentMethod : PaymentMethod?
    var selectedIssuer : Issuer?
    var createdToken : Token?
    var installmentsSelected : PayerCost?
    
    init(){
        super.init(nibName: "StepsExamplesViewController", bundle: nil)
        let pm = PaymentMethod()
        pm._id = "master"
        pm.name = "Mastercard"
        pm.paymentTypeId = PaymentTypeId.CREDIT_CARD.rawValue
        
        self.paymentMethod = pm
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stepsExamplesTable.delegate = self
        self.stepsExamplesTable.dataSource = self
        MercadoPagoContext.setPublicKey(ExamplesUtils.MERCHANT_PUBLIC_KEY)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stepsExamples.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        self.stepsExamplesTable.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = UITableViewCell()
        cell.textLabel?.text = self.stepsExamples[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.stepsExamplesTable.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.row {
        case 0:
           startPaymentVault()
        case 1:
            startCardFlow()
        case 2:
            startCardForm()
            return
        case 3:
            startPaymentMethods()
        case 4:
            statIssuersStep()
        case 5:
            startInstallmentsStep()
        case 6:
            createPayment()
        default:
            break
        }
    }
    
    public func startPaymentVault(){
         MercadoPagoContext.setSite(MercadoPagoContext.Site.MLA)
        MercadoPagoContext.setPublicKey("APP_USR-5a399d42-6015-4f6a-8ff8-dd7d368068f8")
        let pv = MPFlowBuilder.startPaymentVaultViewController(10, callback: { (paymentMethod, token, issuer, payerCost) in

            self.paymentMethod = paymentMethod
            self.createdToken = token
            self.selectedIssuer = issuer
            self.installmentsSelected = payerCost
        })
        self.presentViewController(pv, animated: true, completion: {})
    }
    
    private func startCardFlow(){
        var cf : UINavigationController!
        cf = MPFlowBuilder.startCardFlow(amount: 1000, callback: { (paymentMethod, token, issuer, payerCost) in
            self.paymentMethod = paymentMethod
            self.createdToken = token
            self.selectedIssuer = issuer
            self.installmentsSelected = payerCost
           cf!.dismissViewControllerAnimated(true, completion: {})
            }, callbackCancel : {
                cf!.dismissViewControllerAnimated(true, completion: {})
        })
        self.presentViewController(cf, animated: true, completion: {})
    }
    
    private func startCardForm(){
        var cf : UINavigationController!
        cf = MPStepBuilder.startCreditCardForm(amount: 1000, callback: { (paymentMethod, token, issuer) in
            self.paymentMethod = paymentMethod
            self.createdToken = token
            self.selectedIssuer = issuer
            cf!.dismissViewControllerAnimated(true, completion: {})
            }, callbackCancel : {
                cf!.dismissViewControllerAnimated(true, completion: {})
        })
        
        self.presentViewController(cf, animated: true, completion: {})
    }
    
    private func startPaymentMethods(){
        let pms = MPStepBuilder.startPaymentMethodsStep(withPreference: nil) { (paymentMethod) in
            self.paymentMethod = paymentMethod
            self.navigationController!.popViewControllerAnimated(true)
        }
        self.navigationController?.pushViewController(pms, animated: true)
    }
    
    private func statIssuersStep(){
        let issuersVC = MPStepBuilder.startIssuersStep(self.paymentMethod!) { (issuer) in
            self.selectedIssuer = issuer
            self.navigationController!.popViewControllerAnimated(true)
        }
        self.navigationController?.pushViewController(issuersVC, animated: true)
        
    }
    
    private func startInstallmentsStep(){
        
        let installmentsVC = MPStepBuilder.startInstallmentsStep(amount: 10000, issuer: nil, paymentMethodId: "visa") { (payerCost) in
            self.installmentsSelected = payerCost
            self.navigationController!.popViewControllerAnimated(true)
        }
        self.navigationController?.pushViewController(installmentsVC, animated: true)
        
    }
    
    private func createPayment(){
        
        MercadoPagoContext.setBaseURL(ExamplesUtils.MERCHANT_MOCK_BASE_URL)
        MercadoPagoContext.setPaymentURI(ExamplesUtils.MERCHANT_MOCK_CREATE_PAYMENT_URI)
        
        let item : Item = Item(_id: ExamplesUtils.ITEM_ID, title: ExamplesUtils.ITEM_TITLE, quantity: ExamplesUtils.ITEM_QUANTITY,
                               unitPrice: ExamplesUtils.ITEM_UNIT_PRICE)

        //CardIssuer is optional
        let installments = (self.installmentsSelected == nil) ? 1 : self.installmentsSelected!.installments
        let cardTokenId = (self.createdToken == nil) ? "" : self.createdToken!._id
        let merchantPayment : MerchantPayment = MerchantPayment(items: [item], installments: installments, cardIssuer: self.selectedIssuer, tokenId: cardTokenId, paymentMethod: self.paymentMethod!, campaignId: 0)
        

        MerchantServer.createPayment(merchantPayment, success: { (payment) in
            
            }) { (error) in
            
        }
        
    }
}

