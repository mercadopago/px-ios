//
//  PXPaymentMethodView.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 16/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

final class PXPaymentMethodView: PXBodyView {
    var paymentMethodIcon: UIView?
    var titleLabel: UILabel?
    var subtitleLabel: UILabel?
    var descriptionTitleLabel: UILabel?
    var descriptionDetailLabel: UILabel?
    var disclaimerLabel: UILabel?
    var actionButton: PXSecondaryButton?
}
