//
//  ServicesExamplesViewController.swift
//  MercadoPagoSDKExamples
//
//  Created by Maria cristina rodriguez on 29/6/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoSDK

class ServicesExamplesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let servicesExamples = [
        "Formulario Simple".localized,
        "Tarjetas Guardadas".localized,
        "Pagos con cuotas".localized,
        "Pagos con medios offline".localized
         ]

    @IBOutlet weak var servicesExamplesTable: UITableView!

    var paymentMethod: PaymentMethod!

    init() {
        super.init(nibName: "ServicesExamplesViewController", bundle: nil)
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
        self.servicesExamplesTable.delegate = self
        self.servicesExamplesTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.servicesExamples.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.servicesExamples[(indexPath as NSIndexPath).row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.servicesExamplesTable.deselectRow(at: indexPath, animated: true)
        switch (indexPath as NSIndexPath).row {
        case 0:
            startPaymentMethodsVault()
        case 1:
            startSimpleVault()
        case 2:
            startAdvancedVault()
            return
        case 3:
            startFinalVault()
        default:
            break
        }
    }

    fileprivate func startPaymentMethodsVault() {
        let vaultVC = MPFlowBuilder.startVaultViewController(ExamplesUtils.AMOUNT) { (_, _, _, _) in
            self.navigationController!.popViewController(animated: true)
        }
        self.navigationController!.pushViewController(vaultVC, animated: true)
    }

    fileprivate func startSimpleVault() {
        let simpleVault = ExamplesUtils.startSimpleVaultActivity(MercadoPagoContext.publicKey(), merchantBaseUrl: ExamplesUtils.MERCHANT_MOCK_BASE_URL, merchantGetCustomerUri: MercadoPagoContext.customerURI(), merchantAccessToken: MercadoPagoContext.merchantAccessToken(), paymentPreference: nil) { (_, _) in
            self.navigationController!.popViewController(animated: true)
        }

        self.navigationController?.pushViewController(simpleVault, animated: true)
    }

    fileprivate func startAdvancedVault() {
        let advancedVault = ExamplesUtils.startAdvancedVaultActivity(MercadoPagoContext.publicKey(), merchantBaseUrl: ExamplesUtils.MERCHANT_MOCK_BASE_URL, merchantGetCustomerUri: MercadoPagoContext.customerURI(), merchantAccessToken: MercadoPagoContext.merchantAccessToken(), amount: 1000, paymentPreference: nil, callback: { (_, _, _, _) in
            self.navigationController!.popViewController(animated: true)
        })

        self.navigationController?.pushViewController(advancedVault, animated: true)
    }

    fileprivate func startFinalVault() {
        let settings = PaymentPreference()
        settings.excludedPaymentTypeIds = ["credit_card"]
        let finalVault = MPFlowBuilder.startPaymentVaultViewController(1000, paymentPreference: settings, callback: { (_, _, _, _) in

        })

        self.present(finalVault, animated: true, completion: {})
    }
}
