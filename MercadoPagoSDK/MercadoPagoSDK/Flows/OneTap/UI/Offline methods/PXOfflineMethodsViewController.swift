//
//  PXOfflineMethodsViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2019.
//

import Foundation

final class PXOfflineMethodsViewController: MercadoPagoUIViewController {

    let tableView = UITableView()
    let viewModel: PXOfflineMethodsViewModel

    var totalLabelConstraint: NSLayoutConstraint?

    let totalViewHeight: CGFloat = 54
    let totalViewMargin: CGFloat = PXLayout.S_MARGIN

    init(paymentTypes: [PXOfflinePaymentType], totalAmount: Double) {
        viewModel = PXOfflineMethodsViewModel(paymentTypes: paymentTypes, totalAmount: totalAmount)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        render()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateTotalLabel()
    }

    func animateTotalLabel() {
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) { [weak self] in
            self?.totalLabelConstraint?.constant = self?.totalViewMargin ?? PXLayout.S_MARGIN
            self?.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }

    func render() {
        let totalView = UIView()
        totalView.translatesAutoresizingMaskIntoConstraints = false
        totalView.backgroundColor = ThemeManager.shared.navigationBar().backgroundColor
        view.addSubview(totalView)

        NSLayoutConstraint.activate([
            totalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalView.topAnchor.constraint(equalTo: view.topAnchor),
            totalView.heightAnchor.constraint(equalToConstant: totalViewHeight)
        ])

        let totalLabel = UILabel()
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.attributedText = viewModel.getTotalTitle().getAttributedString(fontSize: PXLayout.M_FONT, textColor: .white)
        totalLabel.textAlignment = .right

        totalView.addSubview(totalLabel)

        NSLayoutConstraint.activate([
            totalLabel.leadingAnchor.constraint(equalTo: totalView.leadingAnchor, constant: totalViewMargin),
            totalLabel.trailingAnchor.constraint(equalTo: totalView.trailingAnchor, constant: -totalViewMargin),
            totalLabel.heightAnchor.constraint(equalToConstant: totalViewHeight - (totalViewMargin*2))
        ])

        totalLabelConstraint = totalLabel.topAnchor.constraint(equalTo: totalView.topAnchor, constant: totalViewMargin + totalViewHeight)
        totalLabelConstraint?.isActive = true

        tableView.sectionHeaderHeight = 40
        tableView.register(PXOfflineMethodsCell.self, forCellReuseIdentifier: PXOfflineMethodsCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .init(top: 0, left: PXLayout.S_MARGIN, bottom: 0, right: PXLayout.S_MARGIN)
        tableView.separatorColor = UIColor.black.withAlphaComponent(0.1)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: totalView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -112)
        ])
        tableView.reloadData()
    }
}

// MARK: UITableViewDelegate & DataSource
extension PXOfflineMethodsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: PXOfflineMethodsCell.identifier, for: indexPath) as? PXOfflineMethodsCell {
            let data = viewModel.dataForCellAt(indexPath)
            cell.render(data: data)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = viewModel.headerTitleForSection(section)
        let view = UIView()
        view.backgroundColor = .white
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = title?.getAttributedString(fontSize: PXLayout.XXS_FONT)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.S_MARGIN),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: PXLayout.S_MARGIN),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRowAt(indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedIndexPath = indexPath
        tableView.reloadData()
    }
}
