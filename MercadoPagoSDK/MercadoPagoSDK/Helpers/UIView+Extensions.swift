//
//  UIView+Extensions.swift
//  AndesUI
//
//  Created by Matheus Leandro Martins on 23/04/21.
//

import UIKit

extension UIView {
    func addSubviews(views: [UIView]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
    }
}
