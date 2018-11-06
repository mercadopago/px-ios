//
//  PXOneTapInstallmentsSelectorView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 16/10/18.
//

import UIKit

protocol PXOneTapInstallmentsSelectorProtocol: NSObjectProtocol {
    func payerCostSelected(_ payerCost: PXPayerCost)
}

final class PXOneTapInstallmentsSelectorView: PXComponentView, UITableViewDelegate, UITableViewDataSource {

    private var model: PXOneTapInstallmentsSelectorViewModel
    let tableView = UITableView()

    weak var delegate: PXOneTapInstallmentsSelectorProtocol?

    init(viewModel: PXOneTapInstallmentsSelectorViewModel) {
        model = viewModel
        super.init()
        render()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(viewModel: PXOneTapInstallmentsSelectorViewModel) {
        model = viewModel
        render()
    }

    var tableViewHeightConstraint: NSLayoutConstraint?
    let tableViewTopSeparator = UIView()
    let shadowView = UIImageView(image: ResourceManager.shared.getImage("one-tap-installments-shadow"))

    func render() {
        removeAllSubviews()
        pinContentViewToTop()
        addSubviewToBottom(tableView)

        self.backgroundColor = .clear
        tableViewHeightConstraint = PXLayout.setHeight(owner: tableView, height: 0)
        tableViewHeightConstraint?.isActive = true
        PXLayout.pinLeft(view: tableView).isActive = true
        PXLayout.pinRight(view: tableView).isActive = true
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        tableViewTopSeparator.translatesAutoresizingMaskIntoConstraints = false
        tableViewTopSeparator.backgroundColor = tableView.separatorColor
        PXLayout.setHeight(owner: tableViewTopSeparator, height: 0.5).isActive = true
        PXLayout.setWidth(owner: tableViewTopSeparator, width: PXLayout.getScreenWidth()).isActive = true
        tableView.tableHeaderView = tableViewTopSeparator
        tableView.reloadData()
    }

    func expand(animator: PXAnimator, completion: @escaping () -> ()) {
        self.layoutIfNeeded()
        self.tableViewTopSeparator.alpha = 1
        self.tableView.alpha = 0
        animateTableViewHeight(tableViewHeight: self.frame.height, tableViewAlpha: 1, completion: completion)
        animator.animate()
    }

    func collapse(animator: PXAnimator, completion: @escaping () -> ()) {
        self.layoutIfNeeded()
        animateTableViewHeight(tableViewHeight: 0, tableViewAlpha: 0, hideTopSeparator: true, completion: completion)
        animator.animate()
    }

    func animateTableViewHeight(tableViewHeight: CGFloat, tableViewAlpha: CGFloat, hideTopSeparator: Bool = false, completion: @escaping () -> ()) {
        self.superview?.layoutIfNeeded()

        tableView.isUserInteractionEnabled = false
        var pxAnimator = PXAnimator(duration: 0.5, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if hideTopSeparator {
                strongSelf.tableViewTopSeparator.alpha = 0
            }
            strongSelf.tableViewHeightConstraint?.constant = tableViewHeight
            strongSelf.tableView.alpha = tableViewAlpha
            strongSelf.layoutIfNeeded()
        })

        pxAnimator.addCompletion(completion: completion)
        pxAnimator.addCompletion { [weak self] in
            self?.tableView.isUserInteractionEnabled = true
        }
        pxAnimator.animate()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return model.cellForRowAt(indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return model.heightForRowAt(indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedPayerCost = model.getPayerCostForRowAt(indexPath) {
            delegate?.payerCostSelected(selectedPayerCost)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.contentMode = .scaleToFill
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        if tableView.contentOffset.y > CGFloat(0.0) {
            self.addSubview(shadowView)
            PXLayout.pinRight(view: shadowView).isActive = true
            PXLayout.pinLeft(view: shadowView).isActive = true
            PXLayout.pinTop(view: shadowView).isActive = true
            PXLayout.setHeight(owner: shadowView, height: 22).isActive = true
        } else {
            shadowView.removeFromSuperview()
            shadowView.removeConstraints(shadowView.constraints)
        }
    }
}
