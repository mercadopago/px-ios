//
//  ConfirmInstallmentsTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 2/6/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class ConfirmInstallmentsTableViewCell: UITableViewCell {

    @IBOutlet weak var CFT: UILabel!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var interest: UILabel!
    @IBOutlet weak var installments: UILabel!
    @IBOutlet weak var total: UILabel!

    var buttonCallback: ((NSObject) -> Void)?
    var payerCost: PayerCost?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func fillCell(payerCost: PayerCost, buttonCallback: @escaping ((NSObject) -> Void)) {
        let currency = MercadoPagoContext.getCurrency()
        self.buttonCallback = buttonCallback
        self.payerCost = payerCost

        let attributedAmount = Utils.getAttributedAmount(payerCost.totalAmount, currency: currency, color : UIColor.px_grayBaseText(), fontSize : 16, baselineOffset : 4)
        let attributedAmountFinal = NSMutableAttributedString(string : "(")
        attributedAmountFinal.append(attributedAmount)
        attributedAmountFinal.append(NSAttributedString(string : ")"))
        self.total.attributedText = attributedAmountFinal

        self.installments.attributedText = Utils.getTransactionInstallmentsDescription(String(payerCost.installments), currency: currency, installmentAmount: payerCost.installmentAmount, additionalString: NSAttributedString(string : ""), color: UIColor.black, fontSize : 24, centsFontSize: 12, baselineOffset: 9)

        self.interest.text = ""
        self.interest.font = Utils.getFont(size: self.interest.font.pointSize)
        if !payerCost.hasInstallmentsRate() && payerCost.installments != 1 {
            self.interest.attributedText = NSAttributedString(string : "Sin interés".localized)
        }

        CFT.font = Utils.getLightFont(size: CFT.font.pointSize)
        CFT.textColor = UIColor.px_grayDark()

        CFT.text = !String.isNullOrEmpty(payerCost.getCFTValue()) ? "CFT " + payerCost.getCFTValue()! : ""

        self.confirm.backgroundColor = UIColor.primaryColor()
        self.confirm.layer.cornerRadius = 4
        self.confirm.titleLabel?.font = Utils.getFont(size: 16)
        self.confirm.setTitle("Continuar".localized, for: .normal)
        self.confirm.addTarget(self, action: #selector(confirmCallback), for: .touchUpInside)
    }

    func confirmCallback() {
        self.buttonCallback?(payerCost!)
    }

}
