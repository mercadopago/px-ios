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

class Option: NSObject {
    var name: String
    var suboptions: [Option]?
    var action: OptionAction? = OptionAction.none

    init(name: String, suboptions: [Option]? = nil, action: OptionAction = OptionAction.none) {
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

    open var publicKey: String!
    open var accessToken: String!
    open var prefID: String!
    open var customCheckoutPref: CheckoutPreference!
    open var showMaxCards: Int!
    open var color: UIColor!
    open var configJSON: String!
    open var flowPreference = FlowPreference()
    open var decorationPreference = DecorationPreference()
    open var servicePreference = ServicePreference()

    let prefIdNoExlusions = "150216849-a0d75d14-af2e-4f03-bba4-d2f0ec75e301"

    let prefIdTicketExcluded = "150216849-551cddcc-e221-4289-bb9c-54bfab992e3d"

    let paymentPreference = PaymentPreference()

    let paymentMethod = PaymentMethod()

    let amount: Double = 1000.0

    let itemID: String = "id1"

    let itemTitle: String = "Bicicleta"

    let itemQuantity: Int = 1

    let itemUnitPrice: Double = 1000.0

    let issuer = Issuer()

    let merchantBaseURL: String = "http://private-4d9654-mercadopagoexamples.apiary-mock.com"

    let merchantCreatePaymentUri: String = "/get_customer"

    var selectedIssuer: Issuer?

    var createdToken: Token?

    var installmentsSelected: PayerCost?

    var opcionesPpal: [Option] = [Option(name: "Nuestro Checkout", action:OptionAction.startCheckout), Option(name: "Wallet Checkout", action: OptionAction.startWalletCheckout), Option(name: "Componentes UI", suboptions: [Option(name: "Selección de medio de pago completa", action: OptionAction.startPaymentVault), Option(name: "Cobra con tarjeta en cuotas", action: OptionAction.startCreditCardFlow), Option(name: "Cobra con tarjeta sin cuotas", action: OptionAction.startCreditCardForm), Option(name: "Selección de medio de pago simple", action: OptionAction.startPaymentMethod), Option(name: "Selección de Banco", action: OptionAction.startIssuer), Option(name: "Selección de Cuotas", action: OptionAction.startPayerCost), Option(name: "Crear Pago", action: OptionAction.startCreatePayment)]), Option(name: "Servicios", suboptions: [Option(name: "Formulario Simple"), Option(name: "Tarjetas Guardadas"), Option(name: "Pago en Cuotas"), Option(name: "Pago con medios Offline")])]

    var dataSource: [Option]!

    override func viewDidLoad() {
        super.viewDidLoad()

        issuer._id = "303"
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

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if dataSource[indexPath.row].suboptions != nil {

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let NewView = storyboard.instantiateViewController(withIdentifier: "MainTableViewController") as! MainTableViewController

            NewView.dataSource = dataSource[indexPath.row].suboptions
            self.navigationController?.pushViewController(NewView, animated: true)

        } else if dataSource[indexPath.row].action == OptionAction.startCheckout {
            startCheckout()
        } else if dataSource[indexPath.row].action == OptionAction.startWalletCheckout {
            startWalletCheckout()
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
        let pref = self.customCheckoutPref != nil ? self.customCheckoutPref :CheckoutPreference(_id: self.prefID)
        let checkout = MercadoPagoCheckout(publicKey: self.publicKey, accessToken: self.accessToken, checkoutPreference: pref!, paymentData: paymentData, paymentResult: paymentResult, navigationController: self.navigationController!)

        if let color = self.color {
            let decorationPref: DecorationPreference = DecorationPreference(baseColor: color)
            MercadoPagoCheckout.setDecorationPreference(decorationPref)
        } else {
            let decorationPref: DecorationPreference = DecorationPreference(baseColor: UIColor.mpDefaultColor())
            MercadoPagoCheckout.setDecorationPreference(decorationPref)
        }

        if String.isNullOrEmpty(self.configJSON) {

            let flowPref: FlowPreference = FlowPreference()

            showRyC ? flowPref.enableReviewAndConfirmScreen() : flowPref.disableReviewAndConfirmScreen()
            MercadoPagoCheckout.setFlowPreference(flowPref)
        } else {
            showRyC ? flowPreference.enableReviewAndConfirmScreen() : flowPreference.disableReviewAndConfirmScreen()
            MercadoPagoCheckout.setFlowPreference(flowPreference)
        }

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

        if !setPaymentDataCallback && !setPaymentDataConfirmCallback {
            MercadoPagoCheckout.setPaymentCallback(paymentCallback: { (payment) in
                print(payment._id)
                self.navigationController?.popToRootViewController(animated: false)
            })
        }

        checkout.setCallbackCancel {
            print("Se cerro al flujo")
            self.navigationController?.popToRootViewController(animated: true)
        }

        checkout.start()
    }

    /// Wallet Checkout
    func startWalletCheckout() {
        if !String.isNullOrEmpty(self.configJSON) {

            tryConvertStringtoDictionary(String: self.configJSON)
            loadCheckout(showRyC: false, setPaymentDataCallback: true)
        } else {
            loadCheckout(showRyC: false, setPaymentDataCallback: true)
        }
    }

    func startWalletReviewAndConfirm() {
        if !String.isNullOrEmpty(self.configJSON) {

            tryConvertStringtoDictionary(String: self.configJSON)
            loadCheckout(paymentData: self.paymentData, setPaymentDataConfirmCallback: true)
        } else {
            loadCheckout(paymentData: self.paymentData, setPaymentDataConfirmCallback: true)
        }
    }

    func startWalletCongrats() {
        self.payment = Payment()
        self.payment.status = "rejected"
        self.payment.statusDetail = "cc_rejected_call_for_authorize"
        self.payment.payer = Payer(_id: "1", email: "asd@asd.com", type: nil, identification: nil, entityType: nil)
        self.payment.statementDescriptor = "description"
        let PR = PaymentResult(payment: self.payment, paymentData: self.paymentData)
        loadCheckout( paymentData: self.paymentData, paymentResult: PR)
    }

    /// F3
    func startCheckout() {
        if !String.isNullOrEmpty(self.configJSON) {

            tryConvertStringtoDictionary(String: self.configJSON)
            loadCheckout()
        } else {
            loadCheckout()
        }
    }

    public enum startForOptions: String {
        case payment = "payment"
        case paymentData = "payment_data"
    }

    func useJSONConfig(json: [String:AnyObject]) {

        let checkoutConfig = CheckoutConfig.fromJson(json as NSDictionary)

        self.publicKey = checkoutConfig.publicKey
        self.accessToken = checkoutConfig.accessToken
        self.flowPreference = checkoutConfig.flowPreference
        self.customCheckoutPref = checkoutConfig.checkoutPreference
        self.decorationPreference = checkoutConfig.decorationPreference
        self.servicePreference = checkoutConfig.servicePreference

        switch checkoutConfig.startFor {
        case startForOptions.payment.rawValue:
            // Flujo normal
            break
        case startForOptions.paymentData.rawValue:
            // Prender Caso Wallet
            break
        default: break
        }
    }

    func tryConvertStringtoDictionary(String: String) {
        do {
            let JSON = try convertStringToDictionary(String)
            useJSONConfig(json: JSON!)
        } catch {
            print("Error")
        }
    }

    func createCheckoutPreference(payerEmail: String, site: String, itemsDictArray: [NSDictionary]) -> CheckoutPreference {
        let payer = Payer(email: payerEmail)
        var items: [Item] = []

        for itemDict in itemsDictArray {
            let item = Item.fromJSON(itemDict)
            items.append(item)
        }

        return CheckoutPreference(items: items, payer: payer)
    }

    func convertStringToDictionary(_ text: String) throws -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
            return json
        }
        return nil
    }
}
