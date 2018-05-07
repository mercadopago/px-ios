//
//  PXBankDealComponent.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers
open class PXBankDealComponent: PXComponentizable {

    public func render() -> UIView {
        return PXBankDealComponentRenderer().render(self)
    }

    var props: PXPromotionCellProps

    init(props: PXPromotionCellProps) {
        self.props = props
    }
}

@objcMembers
open class PXPromotionCellProps: NSObject {
    var image: UIImage?
    var placeholder: String?
    var title: String?
    var subtitle: String?
    
    init(image: UIImage?, placeholder: String?, title: String?, subtitle: String?) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.placeholder = placeholder
    }
}

