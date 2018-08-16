//
//  HeaderComponent.swift
//  TestAutolayout
//
//  Created by Demian Tejo on 10/18/17.
//  Copyright © 2017 Demian Tejo. All rights reserved.
//

import UIKit

/** :nodoc: */
open class PXHeaderComponent: PXComponentizable {

    public func render() -> UIView {
        return PXHeaderRenderer().render(self)
    }

    var props: PXHeaderProps

    init(props: PXHeaderProps) {
        self.props = props
    }
}

/** :nodoc: */
open class PXHeaderProps: NSObject {
    var labelText: NSAttributedString?
    var title: NSAttributedString
    var backgroundColor: UIColor
    var productImage: UIImage?
    var statusImage: UIImage?
    var imageURL: String?
    init(labelText: NSAttributedString?, title: NSAttributedString, backgroundColor: UIColor, productImage: UIImage?, statusImage: UIImage?, imageURL: String? = nil) {
        self.labelText = labelText
        self.title = title
        self.backgroundColor = backgroundColor
        self.productImage = productImage
        self.statusImage = statusImage
        self.imageURL = imageURL
    }
}
