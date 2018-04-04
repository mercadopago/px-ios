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
        "Crear Pago".localized,
        "Ver Promociones".localized
    ]

    @IBOutlet weak var stepsExamplesTable: UITableView!

    var paymentMethod: PaymentMethod?
    var selectedIssuer: Issuer?
    var createdToken: Token?
    var installmentsSelected: PayerCost?

    init() {
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stepsExamples.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.stepsExamplesTable.deselectRow(at: indexPath, animated: true)
        let cell = UITableViewCell()
        cell.textLabel?.text = self.stepsExamples[(indexPath as NSIndexPath).row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.stepsExamplesTable.deselectRow(at: indexPath, animated: true)
        switch (indexPath as NSIndexPath).row {
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
            showBankDeals()
        }
    }

    internal func startPaymentVault() {
        /*MercadoPagoContext.setMerchantAccessToken(ExamplesUtils.MERCHANT_ACCESS_TOKEN)
        MercadoPagoContext.setBaseURL(ExamplesUtils.MERCHANT_MOCK_BASE_URL)
        MercadoPagoContext.setCustomerURI(ExamplesUtils.MERCHANT_MOCK_GET_CUSTOMER_URI)
         
*/
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)
        let pp = PaymentPreference()
        pp.excludedPaymentTypeIds = ["ticket", "atm", "bank_transfer"]
        pp.excludedPaymentMethodIds = ["master"]
        pp.maxAcceptedInstallments = 3

        let pv = MPFlowBuilder.startPaymentVaultViewController(5, paymentPreference: pp, callback: { (paymentMethod, token, issuer, payerCost) in
            print(paymentMethod._id)
            self.paymentMethod = paymentMethod
            self.createdToken = token
            self.selectedIssuer = issuer
            self.installmentsSelected = payerCost
        }, callbackCancel: {
            print("Callback Cancel Normal")
        })

        let myNav = UINavigationController(rootViewController: pv.viewControllers[0])
        self.present(myNav, animated: true, completion: {})
    }

    func startCardFlow() {
        var cf: UINavigationController!

        let timeoutCallback: () -> Void = {
            let alert = UIAlertView(title: "Ups!",
                                    message: "Se ha acabado el tiempo. Reinicie la compra",
                                    delegate: nil,
                                    cancelButtonTitle: "OK")
            alert.show()
        }

        CountdownTimer.getInstance().setup(seconds: 180, timeoutCallback: timeoutCallback)
        cf = MPFlowBuilder.startCardFlow(amount: 1000, callback: { (paymentMethod, token, issuer, payerCost) in
            self.paymentMethod = paymentMethod
            self.createdToken = token
            self.selectedIssuer = issuer
            self.installmentsSelected = payerCost
           cf!.dismiss(animated: true, completion: {})
            }, callbackCancel: {
                cf!.dismiss(animated: true, completion: {})
        })

        self.present(cf, animated: true, completion: {})
    }

    func startCardForm() {
       var cf: UINavigationController!

        let timeoutCallback: () -> Void = {
            let alert = UIAlertView(title: "Ups!",
                                    message: "Se ha acabado el tiempo. Reinicie la compra",
                                    delegate: nil,
                                    cancelButtonTitle: "OK")
            alert.show()
        }

        CountdownTimer.getInstance().setup(seconds: 30, timeoutCallback: timeoutCallback)

        cf = MPStepBuilder.startCreditCardForm(amount: 1000, callback: { (paymentMethod, token, issuer) in
            self.paymentMethod = paymentMethod
            self.createdToken = token
            self.selectedIssuer = issuer
            cf!.dismiss(animated: true, completion: {})
            }, callbackCancel: {
                cf!.dismiss(animated: true, completion: {})
        })

        self.present(cf, animated: true, completion: {})
    }

    func startPaymentMethods() {
        let pms = MPStepBuilder.startPaymentMethodsStep(withPreference: nil) { (paymentMethod) in
            self.paymentMethod = paymentMethod
            self.navigationController!.popViewController(animated: true)
        }
        self.navigationController?.pushViewController(pms, animated: true)
    }

     func statIssuersStep() {
        let issuersVC = MPStepBuilder.startIssuersStep(self.paymentMethod!) { (issuer) in
            self.selectedIssuer = issuer
            self.navigationController!.popViewController(animated: true)
        }
        self.navigationController?.pushViewController(issuersVC, animated: true)

    }

     func startInstallmentsStep() {

        let installmentsVC = MPStepBuilder.startInstallmentsStep(amount: 10000, issuer: nil, paymentMethodId: "visa") { (payerCost) in
            self.installmentsSelected = payerCost
            self.navigationController!.popViewController(animated: true)
        }

        self.navigationController?.pushViewController(installmentsVC, animated: true)

    }

     func createPayment() {

        /*MercadoPagoContext.setBaseURL(ExamplesUtils.MERCHANT_MOCK_BASE_URL)
        MercadoPagoContext.setPaymentURI(ExamplesUtils.MERCHANT_MOCK_CREATE_PAYMENT_URI)
        
        let item : Item = Item(_id: ExamplesUtils.ITEM_ID, title: ExamplesUtils.ITEM_TITLE, quantity: ExamplesUtils.ITEM_QUANTITY,
                               unitPrice: ExamplesUtils.ITEM_UNIT_PRICE)

        //CardIssuer is optional
        let installments = (self.installmentsSelected == nil) ? 1 : self.installmentsSelected!.installments
        let cardTokenId = (self.createdToken == nil) ? "" : self.createdToken!._id
        let merchantPayment : MerchantPayment = MerchantPayment(items: [item], installments: installments, cardIssuer: self.selectedIssuer, tokenId: cardTokenId!, paymentMethod: self.paymentMethod!, campaignId: 0)
        

        MerchantServer.createPayment(merchantPayment, success: { (payment) in
            
            }) { (error) in
            
        }*/

    }

    func showBankDeals() {
        let promosVC = MPStepBuilder.startPromosStep()
        self.navigationController!.present(promosVC, animated: true, completion: {})
    }
}
