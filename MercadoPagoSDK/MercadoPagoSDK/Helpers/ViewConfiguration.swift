//
//  ViewConfiguration.swift
//  AndesUI
//
//  Created by Matheus Leandro Martins on 23/04/21.
//

import UIKit

protocol ViewConfiguration {
    func buildHierarchy()
    func setupConstraints()
    func viewConfigure()
    func setupViewConfiguration()
}

extension ViewConfiguration {
    func setupViewConfiguration() {
        buildHierarchy()
        setupConstraints()
        viewConfigure()
    }
    
    func viewConfigure() { }
}
