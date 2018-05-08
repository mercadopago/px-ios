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

    var props: PXBankDealComponentProps

    init(props: PXBankDealComponentProps) {
        self.props = props
    }
}

@objcMembers
open class PXBankDealComponentProps: NSObject {
    var imageUrl: String?
    var placeholder: String?
    var title: String?
    var subtitle: String?
    
    init(imageUrl: String?, placeholder: String?, title: String?, subtitle: String?) {
        self.imageUrl = imageUrl
        self.title = title
        self.subtitle = subtitle
        self.placeholder = placeholder
    }
}

