//
//  PXCollectionRow.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers
open class PXCollectionRow: PXComponentizable {

    public func render() -> UIView {
        return PXCollectionRowRenderer().render(self)
    }

    var props: PXCollectionRowProps

    init(props: PXCollectionRowProps) {
        self.props = props
    }
}

@objcMembers
open class PXCollectionRowProps: NSObject {
    var view1: UIView
    var view2: UIView?
    init(view1: UIView, view2: UIView? = nil) {
        self.view1 = view1
        self.view2 = view2
    }
}
