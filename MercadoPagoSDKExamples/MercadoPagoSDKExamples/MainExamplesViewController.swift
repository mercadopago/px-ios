//
//  MainExamplesViewController.swift
//  MercadoPagoSDKExamples
//
//  Created by Maria cristina rodriguez on 29/6/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoSDK

open class MainExamplesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let examples = [["title": "Nuestro Checkout".localized, "image": "PlugNplay"],
                               ["title": "Components de UI".localized, "image": "Puzzle"],
                               ["title": "Servicios".localized, "image": "Ninja"]
                            ]

    @IBOutlet weak var tableExamples: UITableView!

    init() {
        super.init(nibName: "MainExamplesViewController", bundle: nil)

    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        let componentCell = UINib(nibName: "ComponentTableViewCell", bundle: nil)

        self.tableExamples.register(componentCell, forCellReuseIdentifier: "componentCell")

        self.tableExamples.delegate = self
        self.tableExamples.dataSource = self
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.examples.count
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableExamples.dequeueReusableCell(withIdentifier: "componentCell") as! ComponentTableViewCell
        cell.initializeWith(self.examples[(indexPath as NSIndexPath).row]["image"]!, title: self.examples[(indexPath as NSIndexPath).row]["title"]!)
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableExamples.deselectRow(at: indexPath, animated: true)
        switch (indexPath as NSIndexPath).row {
        case 0:
            //Checkout Example

            let decorationPreference = DecorationPreference()
            decorationPreference.setBaseColor(hexColor: "#CA254D")
            MercadoPagoCheckout.setDecorationPreference(decorationPreference)

            let flowPreference = FlowPreference()
            flowPreference.disableReviewAndConfirmScreen()
            flowPreference.disablePaymentPendingScreen()
            MercadoPagoCheckout.setFlowPreference(flowPreference)

            let servicePreference = ServicePreference()
            servicePreference.setGetCustomer(baseURL: "sarasa.com", URI: "customer")
            servicePreference.setCreatePayment(baseURL: "https://private-0d59c-mercadopagoexamples.apiary-mock.com", URI: "/create_payment", additionalInfo: ["binary_mode": "true"])
            MercadoPagoCheckout.setServicePreference(servicePreference)

            //let nav = UINavigationController()
            let pref = CheckoutPreference(_id: "223362579-96d6c137-02c3-48a2-bf9c-76e2d263c632")

            let customCell = CustomTableViewCell()
//            customCell.setHeigth(heigth: 100)
//            customCell.setNib(uiNib: UINib(nibName: "CustomTableViewCell", bundle: Bundle.main))

            let inflator = CustomInflator()
            inflator.setTitle(text: "Numero de telefono")

            let custom = MPCustomCells(cell: customCell, inflator: inflator)

            MercadoPagoCheckout.addReviewble(cell: [custom])

            MercadoPagoCheckout(checkoutPrefence: pref, navigationController: self.navigationController!).start()

           // self.present(nav , animated: true, completion: {
                //nothing
           // })

            /*
            let pp = PaymentPreference()
            pp.excludedPaymentTypeIds = ["ticket", "atm", ""]
            let choFlow = MPFlowBuilder.startCheckoutViewController( "241325285-6ac8e517-3030-48f7-b9de-91089d74255d", callback: { (payment: Payment) in
            })
            self.present(choFlow, animated: true, completion: {})
 */
        case 1:
            //UI Components
            let stepsExamples = StepsExamplesViewController()
            self.navigationController?.pushViewController(stepsExamples, animated: true)
        case 2:
            //Services
            let servicesExamples = ServicesExamplesViewController()
            self.navigationController?.pushViewController(servicesExamples, animated: true)
            return
        default:
            break
        }
    }

}
