//
//  PXXibRenderer.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 17/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

class PXXibRenderer: UIView {
    func loadXib(rendererComponentizableClass: PXXibComponentizable) {
        if let bundle = MercadoPago.getBundle() {
            bundle.loadNibNamed(rendererComponentizableClass.xibName(), owner: rendererComponentizableClass, options: nil)
            if let classView = rendererComponentizableClass as? UIView {
                let contentView = rendererComponentizableClass.containerView()
                classView.addSubview(contentView)
                contentView.frame = classView.bounds
                contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            }
        }
    }
}

extension PXXibRenderer: PXXibComponentizable {
    func xibName() -> String {
        fatalError("\(#function) must be overridden")
    }

    func containerView() -> UIView {
        fatalError("\(#function) must be overridden")
    }

    func render() -> UIView {
        fatalError("\(#function) must be overridden")
    }
}
