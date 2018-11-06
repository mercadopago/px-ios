//
//  PXCardSliderProtocol.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 5/11/18.
//

import Foundation

protocol PXCardSliderProtocol: NSObjectProtocol {
    func newCardDidSelected(targetModel: PXCardSliderViewModel)
    func addPaymentMethodCardDidTap()
    func didScroll(offset: CGPoint)
    func didEndDecelerating()
}
