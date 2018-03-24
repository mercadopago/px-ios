//
//  PXBusinessResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXBusinessResultViewModel: NSObject, PXResultViewModelInterface {
    
    let businessResult : PXBusinessResult
    let paymentData : PaymentData
    
    init(businessResult : PXBusinessResult, paymentData : PaymentData) {
        self.businessResult = businessResult
        self.paymentData = paymentData
        super.init()
    }
    
    func getPaymentData() -> PaymentData {
        return self.paymentData
    }
    
    func primaryResultColor() -> UIColor {
        
        switch self.businessResult.status {
        case .APPROVED:
            return ThemeManager.shared.getTheme().successColor()
        case .REJECTED:
            return ThemeManager.shared.getTheme().rejectedColor()
        case .PENDING:
            return ThemeManager.shared.getTheme().warningColor()
        case .IN_PROGRESS:
            return ThemeManager.shared.getTheme().warningColor()
        }
        
    }
    
    func setCallback(callback: @escaping (PaymentResult.CongratsState) -> Void) {
        // Nothing to do
    }
    
    func getPaymentStatus() -> String {
        return businessResult.status.getDescription()
    }
    
    func getPaymentStatusDetail() -> String {
        return businessResult.status.getDescription()
    }
    
    func getPaymentId() -> String? {
       return  businessResult.receiptId
    }
    
    func isCallForAuth() -> Bool {
        return false
    }
    
    func getBadgeImage() -> UIImage? {
        switch self.businessResult.status {
        case .APPROVED:
            return MercadoPago.getImage("ok_badge")
        case .REJECTED:
            return MercadoPago.getImage("error_badge")
        case .PENDING:
            return MercadoPago.getImage("orange_pending_badge")
        case .IN_PROGRESS:
            return MercadoPago.getImage("orange_pending_badge")
        }
    }
    func buildHeaderComponent() -> PXHeaderComponent {
        let headerProps = PXHeaderProps(labelText: businessResult.subtitle?.toAttributedString(), title: businessResult.title.toAttributedString(), backgroundColor: primaryResultColor(), productImage: businessResult.icon, statusImage: getBadgeImage())
        return PXHeaderComponent(props: headerProps)
    }
    
    func buildFooterComponent() -> PXFooterComponent {
        let footerProps = PXFooterProps(buttonAction: businessResult.mainAction, linkAction: businessResult.secondaryAction)
        return PXFooterComponent(props: footerProps)
    }
    
    func buildReceiptComponent() -> PXReceiptComponent? {
        guard let recieptId = businessResult.receiptId else {
            return nil
        }
        let date = Date()
        let recieptProps = PXReceiptProps(dateLabelString: Utils.getFormatedStringDate(date), receiptDescriptionString: "Número de operación ".localized + recieptId)
        return PXReceiptComponent(props: recieptProps)
    }
    
    func buildBodyComponent() -> PXComponentizable? {
        guard let labelInstruction = self.businessResult.helpMessage else {
            return nil
        }
        
        let title = PXResourceProvider.getTitleForErrorBody()
        let props = PXErrorProps(title: title.toAttributedString(), message: labelInstruction.toAttributedString())
        
        return PXErrorComponent(props: props)
    }
    
    func buildTopCustomComponent() -> PXCustomComponentizable? {
        return nil
    }
    
    func buildBottomCustomComponent() -> PXCustomComponentizable? {
        return nil
    }
    

}
