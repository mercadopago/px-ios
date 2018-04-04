//
//  PXResultViewModelProvider.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

protocol PXResultViewModelInterface {

    func getPaymentData() -> PaymentData
    func primaryResultColor() -> UIColor
    func setCallback(callback: @escaping ( _ status: PaymentResult.CongratsState) -> Void)
    func getPaymentStatus() -> String
    func getPaymentStatusDetail() -> String
    func getPaymentId() -> String?
    func isCallForAuth() -> Bool
    func buildHeaderComponent() -> PXHeaderComponent
    func buildFooterComponent() -> PXFooterComponent
    func buildReceiptComponent() -> PXReceiptComponent?
    func buildBodyComponent() -> PXComponentizable?
    func buildTopCustomComponent() -> PXCustomComponentizable?
    func buildBottomCustomComponent() -> PXCustomComponentizable?
}
