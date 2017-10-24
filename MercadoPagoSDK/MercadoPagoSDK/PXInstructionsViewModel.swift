//
//  PXInstructionsViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 20/10/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PXInstructionsViewModel: NSObject {

    var paymentResult: PaymentResult?
    var instructionsInfo: InstructionsInfo?

    init(paymentResult: PaymentResult? = nil, instructionsInfo: InstructionsInfo? = nil)  {
        self.paymentResult = paymentResult
        self.instructionsInfo = instructionsInfo
    }
    
    func primaryResultColor() -> UIColor {
        guard let result = self.paymentResult else {
            return .pxWhite
        }
        if result.isApproved() || result.isWaitingForPayment()  || result.isPending(){
            return .pxGreenMp
        }
        if result.isRejected() {
            return .pxRedMp
        }
        return .white
    }
    
    func iconImageHeader() -> UIImage? {
        guard let result = self.paymentResult else {
            return nil
        }
        if result.isApproved() || result.isWaitingForPayment()  || result.isPending(){
            return MercadoPago.getImage("default_item_icon")
        }
        if result.isRejected() {
            return paymentMethodImage()
        }
        return paymentMethodImage()
    }
    
    func paymentMethodImage() -> UIImage? {
        guard let result = self.paymentResult else {
            return nil
        }
        if (result.paymentData?.paymentMethod?.isCard)! {
            return MercadoPago.getImage("card_icon")
        }
        return MercadoPago.getImage("boleto_icon")
        
    }
    
    func badgeImage() -> UIImage? {
        guard let result = self.paymentResult else {
            return nil
        }
        if result.isApproved() {
            return MercadoPago.getImage("ok_badge")
        }
        if  result.isWaitingForPayment(){
            return MercadoPago.getImage("pending_badge")
        }
        if result.isPending() {
            return MercadoPago.getImage("pending_badge")
        }
        if result.isCallForAuth() {
            return MercadoPago.getImage("pending_badge")
        }
        if result.isRejected() {
            return MercadoPago.getImage("error_badge")
        }
        return nil
    }
    
    func statusMessage() -> String {
        guard let result = self.paymentResult else {
            return ""
        }
        if result.isApproved() {
            return ""
        }
        if  result.isWaitingForPayment(){
            return "¡Apúrate a pagar!"
        }
        if result.isPending() {
            return ""
        }
        if result.isCallForAuth() {
            return ""
        }
        if result.isRejected() {
            return "Algo salió mal..."
        }
        return ""
    }
    func message() -> String {
        guard let result = self.paymentResult else {
            return ""
        }
        return result.statusDetail
    }
    
    func headerComponentData() -> HeaderData {
        let data = HeaderData(title: "!Listo! Recargaste el celular", subTitle: "En unos minutos tendrás el crédito disponible.", backgroundColor: primaryResultColor(), productImage: iconImageHeader(), statusImage: badgeImage())
        return data
    }
    
}
