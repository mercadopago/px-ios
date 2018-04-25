//
//  PXPromotionCell.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers
open class PXPromotionCell: PXComponentizable {

    public func render() -> UIView {
        return PXPromotionCellRenderer().render(self)
    }

    var props: PXPromotionCellProps

    init(props: PXPromotionCellProps) {
        self.props = props
    }
}

@objcMembers
open class PXPromotionCellProps: NSObject {
    var image: UIImage?
    var title: String?
    var subtitle: String?
    
    init(image: UIImage?, title: String?, subtitle: String?) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
    }
}

