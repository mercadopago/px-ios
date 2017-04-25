//
//  RejectedTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/28/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class RejectedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleSubtitleCoinstraint: NSLayoutConstraint!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitile: UILabel!
    
    var paymentTypeId: String?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.title.text = "¿Qué puedo hacer?".localized
        self.title.font = Utils.getFont(size: self.title.font.pointSize)
        self.title.numberOfLines = 0
        self.subtitile.font = Utils.getFont(size: self.subtitile.font.pointSize)
        self.subtitile.text = ""
        self.selectionStyle = .none
    }
    
    func fillCell (paymentResult: PaymentResult){
        
        if paymentResult.status == "rejected" {
            
            if paymentResult.statusDetail == "cc_rejected_call_for_authorize"{
                let title = (paymentResult.statusDetail + "_title")
                self.title.text = title.localized
                self.subtitile.text = ""
            } else {
                if paymentResult.statusDetail.contains("cc_rejected_bad_filled"){
                    paymentResult.statusDetail = "cc_rejected_bad_filled_other"
                }
                
                if let paymentTypeId = paymentResult.paymentData?.paymentMethod.paymentTypeId{
                    self.paymentTypeId = paymentTypeId
                } else {
                    paymentTypeId = "credit_card"
                }
                
                let title = (paymentResult.statusDetail + "_subtitle_" + paymentTypeId!)
                
                if !title.existsLocalized() {
                    if MercadoPagoCheckoutViewModel.paymentResultScreenPreference.isRejectedContentTitleDisable() {
                        self.title.text = ""
                        self .titleSubtitleCoinstraint.constant = 0
                    } else if !String.isNullOrEmpty(MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getRejectedContetTitle()) {
                        self.title.text = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getRejectedContetTitle()
                    }
                    
                    if MercadoPagoCheckoutViewModel.paymentResultScreenPreference.isRejectedContentTextDisable() {
                        self.subtitile.text = ""
                        self .titleSubtitleCoinstraint.constant = 0
                    } else if !String.isNullOrEmpty(MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getRejectedContentText()) {
                        self.subtitile.text = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getRejectedContentText()
                    }

                } else {
                    let paymentMethodName = paymentResult.paymentData!.paymentMethod.name.localized
                    self.subtitile.text = (title.localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentMethodName)")
                }
            }
        } else if paymentResult.status == "in_process" {
            self.title.text = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getPendingContetTitle()
            
            if MercadoPagoCheckoutViewModel.paymentResultScreenPreference.isPendingContentTextDisable() {
                self.subtitile.text = ""
                self .titleSubtitleCoinstraint.constant = 0
                
            } else {
                if !String.isNullOrEmpty(MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getPendingContentText()) {
                    self.subtitile.text = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getPendingContentText()
                    
                } else if paymentResult.statusDetail == "pending_contingency"{
                    self.subtitile.text = "En menos de 1 hora te enviaremos por e-mail el resultado.".localized
                    
                } else {
                    self.subtitile.text = "En menos de 2 días hábiles te diremos por e-mail si se acreditó o si necesitamos más información.".localized
                }
            }
        }
    }
}
