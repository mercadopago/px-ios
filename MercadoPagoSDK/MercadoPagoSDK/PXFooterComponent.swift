//
//  PXFooterComponent.swift
//  TestAutolayout
//
//  Created by Demian Tejo on 10/19/17.
//  Copyright © 2017 Demian Tejo. All rights reserved.
//

import UIKit

class PXFooterComponent: NSObject, PXComponentizable {
  var props: PXFooterProps

    init(props: PXFooterProps) {
        self.props = props
    }

    func render() -> UIView {
        return PXFooterRenderer().render(self)
    }
}
class PXFooterProps: NSObject {
    var buttonAction: PXAction?
    var linkAction: PXAction?
    var primaryColor: UIColor?
    init(buttonAction: PXAction? = nil, linkAction: PXAction? = nil, primaryColor: UIColor? = .pxBlueMp) {
        self.buttonAction = buttonAction
        self.linkAction = linkAction
        self.primaryColor = primaryColor
    }
}
