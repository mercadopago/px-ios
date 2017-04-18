//
//  CongratsViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 11/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

@available(*, deprecated: 2.0.0, message: "Use PaymentCongratsViewController instead")
open class CongratsViewController : MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var payment: Payment!
    var paymentMethod: PaymentMethod!
    override open var screenName : String { get { return "CONGRATS" } }
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var lblTitle: MPLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblDescription: MPLabel!
    
    var paymentTotalCell : PaymentTotalTableViewCell!
    var congratsPaymentMethodCell : CongratsPaymentMethodTableViewCell!
    var paymentIDCell : PaymentIDTableViewCell!
    var paymentDateCell : PaymentDateTableViewCell!
    
    var bundle : Bundle? = MercadoPago.getBundle()
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    init(payment: Payment, paymentMethod: PaymentMethod) {
        super.init(nibName: "CongratsViewController", bundle: bundle)
        self.payment = payment
        self.paymentMethod = paymentMethod
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        declareAndInitCells()
        
        // Title
        _setTitle(payment!)
        
        // Icon
        _setIcon(payment!)
        
        // Description
        setDescription(payment!)
        
        // Amount
        setAmount(payment!)
        
        // payment id
        setPaymentId(payment!)
        
        // payment method description
        setPaymentMethodDescription(payment!)
        
        // payment creation date
        setDateCreated(payment!)
        
        // Button text
        setButtonText(payment!)
        
        self.tableView.reloadData()
    }
    
    open func declareAndInitCells() {
        self.tableView.register(UINib(nibName: "PaymentTotalTableViewCell", bundle: self.bundle), forCellReuseIdentifier: "paymentTotalCell")
        self.paymentTotalCell = self.tableView.dequeueReusableCell(withIdentifier: "paymentTotalCell") as! PaymentTotalTableViewCell
        
        self.tableView.register(UINib(nibName: "CongratsPaymentMethodTableViewCell", bundle: self.bundle), forCellReuseIdentifier: "congratsPaymentMethodCell")
        self.congratsPaymentMethodCell = self.tableView.dequeueReusableCell(withIdentifier: "congratsPaymentMethodCell") as! CongratsPaymentMethodTableViewCell
        
        self.tableView.register(UINib(nibName: "PaymentIDTableViewCell", bundle: self.bundle), forCellReuseIdentifier: "paymentIDCell")
        self.paymentIDCell = self.tableView.dequeueReusableCell(withIdentifier: "paymentIDCell") as! PaymentIDTableViewCell
        
        self.tableView.register(UINib(nibName: "PaymentDateTableViewCell", bundle: self.bundle), forCellReuseIdentifier: "paymentDateCell")
        self.paymentDateCell = self.tableView.dequeueReusableCell(withIdentifier: "paymentDateCell") as! PaymentDateTableViewCell
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            return self.paymentTotalCell
        } else if (indexPath as NSIndexPath).row == 1 {
            return self.congratsPaymentMethodCell
        } else if (indexPath as NSIndexPath).row == 2 {
            return self.paymentIDCell
        } else if (indexPath as NSIndexPath).row == 3 {
            return self.paymentDateCell
        }
        return UITableViewCell()
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    open func _setTitle(_ payment: Payment) {
        if payment.status == "approved" {
            self.lblTitle.text = "¡Felicitaciones!".localized
        } else if payment.status == "pending" {
            self.lblTitle.text = "Se aprobó tu pago.".localized
        } else if payment.status == "in_process" {
            self.lblTitle.text = "Estamos procesando el pago".localized
        } else if payment.status == "rejected" {
            self.lblTitle.text = "¡Ups! Ocurrió un problema".localized
        }
    }
    
    open func _setIcon(_ payment: Payment) {
        if payment.status == "approved" {
            self.icon.image = MercadoPago.getImage("ic_approved")
        } else if payment.status == "pending" {
            self.icon.image = MercadoPago.getImage("ic_pending")
        } else if payment.status == "in_process" {
            self.icon.image = MercadoPago.getImage("ic_pending")
        } else if payment.status == "rejected" {
            self.icon.image = MercadoPago.getImage("ic_rejected")
        }
    }
    
    open func setDescription(_ payment: Payment) {
        if payment.status == "approved" {
            self.lblDescription.text = "Se aprobó tu pago.".localized
        } else if payment.status == "pending" {
            self.lblDescription.text = "Imprime el cupón y paga. Se acreditará en 1 a 3 días hábiles.".localized
        } else if payment.status == "in_process" {
            self.lblDescription.text = "En unos minutos te enviaremos por e-mail el resultado.".localized
        } else if payment.status == "rejected" {
            self.lblDescription.text = "No se pudo realizar el pago.".localized
        }
    }
    
    open func setAmount(_ payment: Payment) {
        if payment.currencyId != nil {
            let formattedAmount : String? = CurrenciesUtil.formatNumber(payment.transactionDetails.totalPaidAmount, currencyId: payment.currencyId)
            if formattedAmount != nil {
                self.paymentTotalCell.lblTotal.text = formattedAmount
            }
        }
    }
    
    open func setPaymentId(_ payment: Payment) {
        self.paymentIDCell!.lblID.text = String(payment._id)
    }
    
    open func setPaymentMethodDescription(_ payment: Payment) {
        if payment.card != nil && payment.card.paymentMethod != nil {
        self.congratsPaymentMethodCell!.lblPaymentInfo.text = "terminada en".localized + " " + payment.card!.lastFourDigits!
            self.congratsPaymentMethodCell.imgPayment.image = MercadoPago.getImage("icoTc_" + payment.card!.paymentMethod!._id)
        } else if self.paymentMethod != nil {
            self.congratsPaymentMethodCell!.lblPaymentInfo.text = self.paymentMethod!.name
            self.congratsPaymentMethodCell.imgPayment.image = MercadoPago.getImage("icoTc_" + self.paymentMethod._id)
        }
    }
    
    open func setDateCreated(_ payment: Payment) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.paymentDateCell.lblDate.text = dateFormatter.string(from: payment.dateCreated! as Date)
        
    }
    
    open func setButtonText(_ payment: Payment) {
        var title = "Imprimir cupón".localized
        if payment.status == "pending" {
            // TODO couponUrl = payment.transactionDetails.externalResourceUrl
        } else {
            title = "Continuar".localized
            // TODO couponUrl = nil
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(CongratsViewController.submitForm))
    }
    
    open func submitForm() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
