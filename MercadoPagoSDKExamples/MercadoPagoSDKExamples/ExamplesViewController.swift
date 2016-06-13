//
//  ExamplesViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/1/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import UIKit
import MercadoPagoSDK


class ExamplesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak private var tableview : UITableView!
	
    let examples : [String] = ["step1_title".localized, "step2_title".localized, "step3_title".localized, "step4_title".localized,
    "step5_title".localized, "step6_title".localized, "step7_title".localized, "step8_title".localized, "step9_title".localized, "step10_title".localized, "step11_title".localized, "step11_title".localized, "step13_title".localized,"Medios de pago".localized,"Banco".localized,"Cuotas".localized,"Promociones".localized]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: "ExamplesViewController", bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableview.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.translucent = false
        self.title = "MercadoPago SDK"
        self.tableview.delegate = self
        self.tableview.dataSource = self

      

    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: examples[indexPath.row])
        cell.textLabel!.text = examples[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType(rawValue: UITableViewCellAccessoryType.DetailDisclosureButton.rawValue)!
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var settings = PaymentPreference(defaultPaymentTypeId : PaymentTypeId.CREDIT_CARD)
        
        switch indexPath.row {
        case 0:

            let pm = PaymentMethod()
            pm._id = "master"
            pm.name = "Mastercard"
            pm.paymentTypeId = PaymentTypeId.CREDIT_CARD
            
            
            
            let bin = BinMask()
            bin.pattern = "^5"
            bin.exclusionPattern = "^(589562)"
            bin.installmentsPattern = "^5"
            
            let cardNumber = CardNumber()
            cardNumber.length = 16
            cardNumber.validation = "standard"
                            
            let securityCode = SecurityCode()
            securityCode.mode = "mandatory"
            securityCode.length = 3
            securityCode.cardLocation = "back"
            let setting = Setting()
            setting.securityCode = securityCode
            setting.cardNumber =  cardNumber
            setting.binMask = bin

            pm.settings = [setting]

            
            self.presentViewController(MPStepBuilder.startCreditCardForm(amount: 1, callback: { (paymentMethod, token, issuer) -> Void in
                    //Ejectutar el pago con el Token, el Issuer y el PaymentMethod
                }, callbackCancel: { () -> Void in
                    // Hacer algo cuando el usuario cancela el flujo de pago
            }), animated: true, completion: { () -> Void in
                
            })
            return
            self.presentViewController(MPFlowBuilder.startCardFlow(settings , amount: 1, paymentMethods: [pm], callback: { (paymentMethod, cardToken, issuer, payerCost) -> Void in
                //Ejectutar el pago con el CardToken, el Issuer y el PaymentMethod
            }), animated: true, completion: { () -> Void in })

        case 1:
            self.showViewController(ExamplesUtils.startSimpleVaultActivity(ExamplesUtils.MERCHANT_PUBLIC_KEY, merchantBaseUrl: ExamplesUtils.MERCHANT_MOCK_BASE_URL, merchantGetCustomerUri: ExamplesUtils.MERCHANT_MOCK_GET_CUSTOMER_URI, merchantAccessToken: ExamplesUtils.MERCHANT_ACCESS_TOKEN, supportedPaymentTypes: PaymentType.allPaymentIDs, callback: {(paymentMethod: PaymentMethod, token: Token?) -> Void in
                    self.createPayment(token!._id, paymentMethod: paymentMethod, installments: 1, cardIssuer: nil, discount: nil)
            } ))
            
            
        case 2:
            self.showViewController(ExamplesUtils.startAdvancedVaultActivity(ExamplesUtils.MERCHANT_PUBLIC_KEY, merchantBaseUrl: ExamplesUtils.MERCHANT_MOCK_BASE_URL, merchantGetCustomerUri: ExamplesUtils.MERCHANT_MOCK_GET_CUSTOMER_URI, merchantAccessToken: ExamplesUtils.MERCHANT_ACCESS_TOKEN, amount: ExamplesUtils.AMOUNT, supportedPaymentTypes: PaymentType.allPaymentIDs, callback: {(paymentMethod: PaymentMethod, token: String?, issuer: Issuer?, installments: Int) -> Void in
                self.createPayment(token, paymentMethod: paymentMethod, installments: installments, cardIssuer: issuer, discount: nil)
            }))
        case 3:
            self.showViewController(ExamplesUtils.startFinalVaultActivity(ExamplesUtils.MERCHANT_PUBLIC_KEY, merchantBaseUrl: ExamplesUtils.MERCHANT_MOCK_BASE_URL, merchantGetCustomerUri: ExamplesUtils.MERCHANT_MOCK_GET_CUSTOMER_URI, merchantAccessToken: ExamplesUtils.MERCHANT_ACCESS_TOKEN, amount: ExamplesUtils.AMOUNT, supportedPaymentTypes: PaymentType.allPaymentIDs, callback: {(paymentMethod: PaymentMethod, token: String?, issuer: Issuer?, installments: Int) -> Void in
                self.createPayment(token, paymentMethod: paymentMethod, installments: installments, cardIssuer: issuer, discount: nil)
            }))
        case 4:
            self.showViewController(MPFlowBuilder.startVaultViewController(ExamplesUtils.AMOUNT, supportedPaymentTypes: PaymentType.allPaymentIDs, callback: {(paymentMethod: PaymentMethod, token: String?, issuer: Issuer?, installments: Int) -> Void in
                    self.createPayment(token, paymentMethod: paymentMethod, installments: installments, cardIssuer: issuer, discount: nil)
            }))
        case 5:
            MercadoPagoContext.setPublicKey(ExamplesUtils.MERCHANT_PUBLIC_KEY)
            self.presentNavigation(MPFlowBuilder.startCheckoutViewController(ExamplesUtils.PREF_ID_NO_EXCLUSIONS, callback: { (payment:Payment) -> Void in
                
            }))
        case 6:

            self.presentViewController(MPFlowBuilder.startPaymentVaultViewController(1.00, currencyId : "ARS", paymentPreference: settings , callback: { (paymentMethod, tokenId, issuer, installments) -> Void in
                // Ejecutar el pago con el PaymentMethod, el Issuer, , el Token ID y el objeto Installments
                }), animated: true, completion: { () -> Void in})
            
        case 7:
            MercadoPagoContext.setPublicKey(ExamplesUtils.MERCHANT_PUBLIC_KEY_TEST)
            self.presentNavigation(MPFlowBuilder.startCheckoutViewController(ExamplesUtils.PREF_ID_NO_EXCLUSIONS, callback: { (payment:Payment) -> Void in
                
            }))
        case 8:
            
            self.presentNavigation(MPFlowBuilder.startCheckoutViewController(ExamplesUtils.PREF_ID_MLA_ONLY_CC, callback: { (payment) -> Void in

            }))
        case 9:
            self.presentNavigation(MPFlowBuilder.startCheckoutViewController(ExamplesUtils.PREF_ID_MLA_RAPIPAGO_CARGAVIRTUAL_EXCLUDED, callback: { (payment) -> Void in
                
            }))
        case 10:
            self.presentNavigation(MPFlowBuilder.startCheckoutViewController(ExamplesUtils.PREF_ID_MLA_ONLY_PAGOFACIL, callback: { (payment) -> Void in
                
            }))
            
        case 11:
            let payment = Payment()
            payment._id = 123
            payment.transactionAmount = 200
            payment.status = "rejected"
            payment.statusDetail = "cc_rejected_insufficient_amount"
            
            let pm = PaymentMethod()
            pm.paymentTypeId = PaymentTypeId.DEBIT_CARD
            pm.name = "Visa"
            
            
            let congratsVC = MPStepBuilder.startPaymentCongratsStep(payment, paymentMethod: pm, callback: { (Void) -> Void in
                self.navigationController!.popViewControllerAnimated(true)
            })
            self.navigationController!.pushViewController(congratsVC, animated: true)
        case 12:
            
            let error = MPError(message : "Esto deberia ser titulo", messageDetail : "messageDetail", retry : false)
            
            self.showViewController(MPStepBuilder.startErrorViewController(error, callback: {

            }))
        case 13:
            self.showViewController(MPStepBuilder.startPaymentMethodsStep(PaymentType.allPaymentIDs, callback: { (paymentMethod) -> Void in
                // Seguir recolectando datos para pagar a partir del Payment Method
            }))
        case 14:
            let pm = PaymentMethod()
            pm._id = "master"
            pm.name = "Mastercard"
            pm.paymentTypeId = PaymentTypeId.CREDIT_CARD

            self.showViewController(MPStepBuilder.startIssuersStep( pm, callback: { (issuer) -> Void in
              // Seguir el proceso de pago con el Issuer seleccionado
            }))
        case 15:
            print("Cuotas")
            /*
            

            self.showViewController(MPStepBuilder.startPayerCostForm(paymentMethod, issuer: issuer, token: token, amount: 10000, maxInstallments: 3, callback: { (payerCost) -> Void in
                // Hacer algo con la cuota elegida
            }))
            */
        case 16:
            print("Promociones")

        default:
            print("Otra opcion")
        }
    }
	
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let message : String = "step\(indexPath.row+1)_description".localized

        let alert = UIAlertView()
        alert.title = "Información".localized
        alert.message = message
        alert.addButtonWithTitle("OK")
        alert.show()

    }

    func createPayment(token: String?, paymentMethod: PaymentMethod, installments: Int, cardIssuer: Issuer?, discount: Discount?) {
        if token != nil {
            ExamplesUtils.createPayment(token!, installments: installments, cardIssuer: cardIssuer, paymentMethod: paymentMethod, callback: { (payment: Payment) -> Void in
                self.showViewController(MPStepBuilder.startCongratsStep(payment, paymentMethod: paymentMethod))
            })
        } else {
            
        }
    }
	
	func showViewController(vc: UIViewController) {
		if #available(iOS 8.0, *) {
			self.showViewController(vc, sender: self)
		} else {
            vc.navigationController!.pushViewController(vc, animated: false)
		}
        
	}
    
    func presentNavigation(vc: UINavigationController) {
        self.presentViewController(vc, animated: true) { () -> Void in
        
        }
    }
	
    func getDiscount() {
        
    }

}
