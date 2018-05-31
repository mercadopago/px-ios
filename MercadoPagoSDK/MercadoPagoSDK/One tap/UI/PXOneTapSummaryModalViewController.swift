//
//  PXOneTapSummaryModalViewController.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 18/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

final class PXOneTapSummaryModalViewController: UIViewController {

    private var props: [PXSummaryRowProps]?
    private var customView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setProps(summaryProps: [PXSummaryRowProps]?, bottomCustomView: UIView?) {
        props = summaryProps
        customView = bottomCustomView
    }

    private func setupView() {
        if let summaryProps = props, let smallSummaryView = PXSmallSummaryView(withProps: summaryProps, backgroundColor: .white).oneTapRender() as? PXSmallSummaryView {

            if let cView = customView {
                view.addSubview(smallSummaryView)
                PXLayout.pinTop(view: smallSummaryView).isActive = true
                PXLayout.matchWidth(ofView: smallSummaryView).isActive = true
                PXLayout.centerHorizontally(view: smallSummaryView).isActive = true

                view.addSubview(cView)
                PXLayout.matchWidth(ofView: cView).isActive = true
                PXLayout.centerHorizontally(view: cView).isActive = true
                PXLayout.put(view: cView, onBottomOf: smallSummaryView).isActive = true
                PXLayout.pinBottom(view: cView).isActive = true
            } else {
                view.addSubview(smallSummaryView)
                PXLayout.matchHeight(ofView: smallSummaryView).isActive = true
                PXLayout.centerVertically(view: smallSummaryView).isActive = true
                PXLayout.matchWidth(ofView: smallSummaryView).isActive = true
                PXLayout.centerHorizontally(view: smallSummaryView).isActive = true
            }
        } else {
            if let cView = customView {
                view.addSubview(cView)
                PXLayout.matchHeight(ofView: cView).isActive = true
                PXLayout.centerVertically(view: cView).isActive = true
                PXLayout.matchWidth(ofView: cView).isActive = true
                PXLayout.centerHorizontally(view: cView).isActive = true
            }
        }
    }
}
