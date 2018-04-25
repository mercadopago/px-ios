//
//  PXCollectionRowRenderer.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXCollectionRowRenderer: NSObject {

    func render(_ component: PXCollectionRow) -> PXCollectionRowView {
        let collectionRowView = PXCollectionRowView()
        collectionRowView.translatesAutoresizingMaskIntoConstraints = false
        collectionRowView.backgroundColor = .white
        collectionRowView.layer.borderWidth = 2

        //View 1
        let view1 = component.props.view1
        let view1Container = UIView()
        view1Container.addSubview(view1)
        PXLayout.pinTop(view: view1).isActive = true
        PXLayout.pinBottom(view: view1).isActive = true
        PXLayout.centerHorizontally(view: view1).isActive = true
        collectionRowView.view1 = view1Container
        collectionRowView.addSubview(view1Container)
        PXLayout.pinLeft(view: view1Container).isActive = true
        PXLayout.matchWidth(ofView: view1Container, withPercentage: 50).isActive = true
        PXLayout.pinTop(view: view1Container).isActive = true
        PXLayout.pinBottom(view: view1Container).isActive = true

        //View 2
        if let view2 = component.props.view2 {
            let view2Container = UIView()
            view2Container.addSubview(view2)
            PXLayout.pinTop(view: view2).isActive = true
            PXLayout.pinBottom(view: view2).isActive = true
            PXLayout.centerHorizontally(view: view2).isActive = true
            collectionRowView.view2 = view2Container
            collectionRowView.addSubview(view2Container)
            PXLayout.pinRight(view: view2Container).isActive = true
            PXLayout.matchWidth(ofView: view2Container, withPercentage: 50).isActive = true
            PXLayout.pinTop(view: view2Container).isActive = true
            PXLayout.pinBottom(view: view2Container).isActive = true
        }

        return collectionRowView
    }

}

class PXCollectionRowView: PXComponentView {
    public var view1: UIView!
    public var view2: UIView?
}
