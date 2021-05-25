//
//  UIStackView+Extensions.swift
//  AndesUI
//
//  Created by Matheus Leandro Martins on 23/04/21.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(views: [UIView]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview(view)
        }
    }
}
