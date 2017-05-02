//
//  MainTableViewController.swift
//  PodTester
//
//  Created by AUGUSTO COLLERONE ALFONSO on 12/22/16.
//  Copyright © 2016 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import UIKit
import MercadoPagoSDK

enum OptionAction {
    case startCheckout
    case startWalletCheckout
    case startPaymentVault
    case startCreditCardFlow
    case startCreditCardForm
    case startPaymentMethod
    case startIssuer
    case startPayerCost
    case startCreatePayment
    case none
}

class Option: NSObject{
    var name: String
    var suboptions: [Option]?
    var action: OptionAction? = OptionAction.none
    
    init(name:String,suboptions:[Option]? = nil, action:OptionAction = OptionAction.none) {
        self.name = name
        self.suboptions = suboptions
        self.action = action
    }
    
    
    func customDescription() -> String {
        return name
    }
    
    override var description: String {
        return customDescription()
    }
}

class MainTableViewController: UITableViewController {
    
    open var prefID : String = ""
    open var color : UIColor!
    
    let prefIdNoExlusions = "150216849-a0d75d14-af2e-4f03-bba4-d2f0ec75e301"
    
    let prefIdTicketExcluded = "150216849-551cddcc-e221-4289-bb9c-54bfab992e3d"
    
    let paymentPreference = PaymentPreference()
    
    let paymentMethod = PaymentMethod()
    
    let amount : Double = 1000.0
    
    let itemID : String = "id1"
    
    let itemTitle : String = "Bicicleta"
    
    let itemQuantity : Int = 1
    
    let itemUnitPrice: Double = 1000.0
    
    let issuer = Issuer()
    
    let merchantBaseURL: String = "http://private-4d9654-mercadopagoexamples.apiary-mock.com"
    
    let merchantCreatePaymentUri: String = "/get_customer"
    
    
    
    var selectedIssuer : Issuer?
    
    var createdToken : Token?
    
    var installmentsSelected : PayerCost?
    
    var opcionesPpal : [Option] = [Option(name: "Nuestro Checkout", action:OptionAction.startCheckout), Option(name: "Wallet Checkout", action: OptionAction.startWalletCheckout), Option(name: "Componentes UI", suboptions: [Option(name: "Selección de medio de pago completa", action: OptionAction.startPaymentVault), Option(name: "Cobra con tarjeta en cuotas",action: OptionAction.startCreditCardFlow), Option(name: "Cobra con tarjeta sin cuotas",action: OptionAction.startCreditCardForm), Option(name: "Selección de medio de pago simple",action: OptionAction.startPaymentMethod), Option(name: "Selección de Banco",action: OptionAction.startIssuer), Option(name: "Selección de Cuotas",action: OptionAction.startPayerCost), Option(name: "Crear Pago",action: OptionAction.startCreatePayment)]), Option(name: "Servicios", suboptions: [Option(name: "Formulario Simple"), Option(name: "Tarjetas Guardadas"), Option(name: "Pago en Cuotas"), Option(name: "Pago con medios Offline")])]
   
    var dataSource : [Option]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        issuer._id = 303
        paymentMethod._id = "visa"
        installmentsSelected?.installments = 2
        
        if dataSource == nil {
            dataSource = opcionesPpal
        }   
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = dataSource[indexPath.row].name
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if dataSource[indexPath.row].suboptions != nil{
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let NewView = storyboard.instantiateViewController(withIdentifier: "MainTableViewController") as! MainTableViewController
            

            NewView.dataSource = dataSource[indexPath.row].suboptions
            self.navigationController?.pushViewController(NewView, animated: true)
        
        }else if dataSource[indexPath.row].action == OptionAction.startCheckout{
            startCheckout()
        }else if dataSource[indexPath.row].action == OptionAction.startWalletCheckout{
            startWalletCheckout()
        }else if dataSource[indexPath.row].action == OptionAction.startPaymentVault{
            startPaymentVault()
        }else if dataSource[indexPath.row].action == OptionAction.startCreditCardFlow{
            startCreditCardFlow()
        }else if dataSource[indexPath.row].action == OptionAction.startCreditCardForm{
            startCreditCardForm()
        }else if dataSource[indexPath.row].action == OptionAction.startPaymentMethod{
            startPaymentMethod()
        }else if dataSource[indexPath.row].action == OptionAction.startIssuer{
            startIssuer()
        }else if dataSource[indexPath.row].action == OptionAction.startPayerCost{
            startPayerCost()
        }else if dataSource[indexPath.row].action == OptionAction.startCreatePayment{
            startCreatePayment()
        }
    }
    
    var paymentData = PaymentData()
    var payment = Payment()
    
    /// Wallet Steps
    public enum walletSteps: String {
        case ryc = "review_and_confirm"
        case congrats = "congrats"
    }
    
    func buttonViewControllerCreator(title: String, walletStep: walletSteps) {
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.white
        
        let button = UIButton(frame: CGRect(x: 10, y: 20, width: 250, height: 60))
        button.center = viewController.view.center
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = self.color
        button.layer.cornerRadius = 10
        
        switch walletStep {
        case walletSteps.ryc:
            button.addTarget(self, action: #selector(self.startWalletReviewAndConfirm), for: .touchUpInside)
        case walletSteps.congrats:
            button.addTarget(self, action: #selector(self.startWalletCongrats), for: .touchUpInside)
        }
        
        viewController.view.addSubview(button)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    /// Load Checkout
    func loadCheckout(showRyC: Bool = true, setPaymentDataCallback: Bool = false, paymentData: PaymentData? = nil, setPaymentDataConfirmCallback: Bool = false, paymentResult: PaymentResult? = nil) {
        let pref = CheckoutPreference(_id: self.prefID)
        let checkout = MercadoPagoCheckout.init(checkoutPreference: pref, paymentData: paymentData ,navigationController: self.navigationController!, paymentResult: paymentResult)
        
        if let color = self.color{
            let decorationPref : DecorationPreference = DecorationPreference(baseColor: color, fontName: "", fontLightName: "")
            MercadoPagoCheckout.setDecorationPreference(decorationPref)
        } else {
            let decorationPref : DecorationPreference = DecorationPreference(baseColor: UIColor.mpDefaultColor(), fontName: "", fontLightName: "")
            MercadoPagoCheckout.setDecorationPreference(decorationPref)
        }
        
        let flowPref : FlowPreference = FlowPreference()
        showRyC ? flowPref.enableReviewAndConfirmScreen() : flowPref.disableReviewAndConfirmScreen()
        MercadoPagoCheckout.setFlowPreference(flowPref)
        
        if setPaymentDataCallback {
            MercadoPagoCheckout.setPaymentDataCallback { (PaymentData) in
                self.paymentData = PaymentData
                self.buttonViewControllerCreator(title: "Ir a Revisa y Confirma", walletStep: walletSteps.ryc)
            }
        }
        
        if setPaymentDataConfirmCallback {
            MercadoPagoCheckout.setPaymentDataConfirmCallback { (PaymentData) in
                self.paymentData = PaymentData
                self.buttonViewControllerCreator(title: "Ir a Congrats", walletStep: walletSteps.congrats)
            }
        }
        
        checkout.start()
    }
    
    /// Wallet Checkout
    func startWalletCheckout(){
        loadCheckout(showRyC: false, setPaymentDataCallback: true)
    }
    
    func startWalletReviewAndConfirm(){
        loadCheckout(paymentData: self.paymentData, setPaymentDataConfirmCallback: true)
    }
    
    func startWalletCongrats(){
        let PR = PaymentResult(payment: self.payment, paymentData: self.paymentData)
        loadCheckout(paymentResult: PR)
    }
    
    /// F3
    func startCheckout(){
        loadCheckout()
    }
    
    /// F2
    func startPaymentVault(){
//        let paymentVault = MPFlowBuilder.startPaymentVaultViewController(amount, callback: { (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost: PayerCost?) in
//            
//            
//            self.dismiss(animated: true, completion: {})
//            
//            
//        }, callbackCancel: {})
//        
//        self.present(paymentVault, animated: true, completion: {})
    }
    
    func startCreditCardFlow(){
//        let cardFlow = MPFlowBuilder.startCardFlow(amount: amount, callback: { (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost: PayerCost?) in
//            
//            
//            self.dismiss(animated: true, completion: {})
//            
//            
//        })
//        
//        self.present(cardFlow, animated: true, completion: {})
//    
    }
    
    func startCreditCardForm(){
        
//        let cardForm = MPStepBuilder.startCreditCardForm(paymentPreference, amount: amount, callback: { (paymentMethod:PaymentMethod, token:Token?, issuer:Issuer?) in
//            
//            
//            self.dismiss(animated: true, completion: {})
//        
//        
//        }, callbackCancel: {
//            
//            self.dismiss(animated: true, completion: {})
//            
//        })
//        
//            self.present(cardForm, animated: true, completion: {})
    }
    
    func startPaymentMethod(){
//        let paymentMethod = MPStepBuilder.startPaymentMethodsStep { (paymentMethod:PaymentMethod) in
//            
//            
//            self.dismiss(animated: true, completion: {})
//            
//            
//        }
//        
//        self.present(paymentMethod, animated: true, completion: {})
    }
    
    func startIssuer(){
//        let issuer = MPStepBuilder.startIssuersStep(paymentMethod) { (issuer:Issuer) in
//            
//            
//            self.dismiss(animated: true, completion: {})
//
//            
//        }
//        
//        self.present(issuer, animated: true, completion: {})

        
    } // crash

    func startPayerCost(){
        
//        let payerCost = MPStepBuilder.startPayerCostForm(paymentMethod, issuer: issuer, token: nil, amount: amount, paymentPreference: nil, installment: nil, timer: nil, callback: { (payerCost:PayerCost?) in
//        
//            self.dismiss(animated: true, completion: {})
//            
//        }, callbackCancel: {})
//        
//        self.present(payerCost, animated: true, completion: {})
//        

    }

    func startCreatePayment(){
//
//        MercadoPagoContext.setBaseURL(merchantBaseURL)
//        MercadoPagoContext.setPaymentURI(merchantCreatePaymentUri)
//        
//        let item : Item = Item(_id: itemID, title: itemTitle, quantity: itemQuantity,
//                               unitPrice: itemUnitPrice)
//        
//        
//        //CardIssuer is optional
//        let installments = (self.installmentsSelected == nil) ? 1 : self.installmentsSelected!.installments
//        let cardTokenId = (self.createdToken == nil) ? "" : self.createdToken!._id
//        let merchantPayment : MerchantPayment = MerchantPayment(items: [item], installments: installments, cardIssuer: self.selectedIssuer, tokenId: cardTokenId!, paymentMethod: self.paymentMethod, campaignId: 0)
//        
//        MerchantServer.createPayment(merchantPayment, success: { (payment) in
//            
//            
//        }) { (error) in
//            
//            
//            
//        }
        
    }
}
