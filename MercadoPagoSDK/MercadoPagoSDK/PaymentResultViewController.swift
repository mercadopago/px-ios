//
//  CongratsRevampViewController.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/25/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class PaymentResultViewController: MercadoPagoUIViewController, UITableViewDelegate, UITableViewDataSource, MPCustomRowDelegate {

    @IBOutlet weak var tableView: UITableView!
    var bundle = MercadoPago.getBundle()
    var viewModel: PaymentResultViewModel!

    override open var screenName: String { get {
        return "RESULT"
    } }

     override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 60
        self.tableView.separatorStyle = .none

        addUpperScrollingFrame()
        registerCells()
    }

    func addUpperScrollingFrame() {
        var frame = self.tableView.bounds
        frame.origin.y = -frame.size.height
        let view = UIView(frame: frame)
        view.backgroundColor = self.viewModel.getColor()
        tableView.addSubview(view)
    }

    func registerCells() {

        let headerNib = UINib(nibName: "HeaderCongratsTableViewCell", bundle: self.bundle)
        self.tableView.register(headerNib, forCellReuseIdentifier: "headerNib")

        let emailNib = UINib(nibName: "ConfirmEmailTableViewCell", bundle: self.bundle)
        self.tableView.register(emailNib, forCellReuseIdentifier: "emailNib")

        let approvedNib = UINib(nibName: "ApprovedTableViewCell", bundle: self.bundle)
        self.tableView.register(approvedNib, forCellReuseIdentifier: "approvedNib")

        let rejectedNib = UINib(nibName: "ContentTableViewCell", bundle: self.bundle)
        self.tableView.register(rejectedNib, forCellReuseIdentifier: "contentCell")

        let callFAuthNib = UINib(nibName: "CallForAuthTableViewCell", bundle: self.bundle)
        self.tableView.register(callFAuthNib, forCellReuseIdentifier: "callFAuthNib")

        let secondaryButtonNib = UINib(nibName: "SecondaryExitButtonTableViewCell", bundle: self.bundle)
        self.tableView.register(secondaryButtonNib, forCellReuseIdentifier: "secondaryButtonNib")

        let footerNib = UINib(nibName: "FooterTableViewCell", bundle: self.bundle)
        self.tableView.register(footerNib, forCellReuseIdentifier: "footerNib")

    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController != nil && self.navigationController?.navigationBar != nil {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            ViewUtils.addStatusBar(self.view, color: self.viewModel.getColor())
        }
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    public init(paymentResult: PaymentResult, checkoutPreference: CheckoutPreference, paymentResultScreenPreference: PaymentResultScreenPreference = PaymentResultScreenPreference(), callback : @escaping (_ status: PaymentResult.CongratsState) -> Void) {
        super.init(nibName: "PaymentResultViewController", bundle : bundle)

        self.viewModel = PaymentResultViewModel(paymentResult: paymentResult, checkoutPreference: checkoutPreference, callback: callback, paymentResultScreenPreference: paymentResultScreenPreference)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.heightForRowAt(indexPath: indexPath)
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRowsInSection(section: section)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.isHeaderCellFor(indexPath: indexPath) {
            return self.getHeaderCell(indexPath: indexPath)

        } else if viewModel.isApprovedBodyCellFor(indexPath: indexPath) {
            return getApprovedBodyCell()

        } else if viewModel.isEmailCellFor(indexPath: indexPath) {
            return getConfirmEmailCell()

        } else if viewModel.isCallForAuthFor(indexPath: indexPath) {
            return getCallForAuthCell()

        } else if viewModel.isContentCellFor(indexPath: indexPath) {
            if viewModel.paymentResult.isCallForAuth() {
                return getContentCell(drawLine: true)
            }
            return getContentCell(drawLine: false)

        } else if viewModel.isApprovedAdditionalCustomCellFor(indexPath: indexPath) {
            return getApprovedAddtionalCustomCell(indexPath: indexPath)

        } else if viewModel.isPendingAdditionalCustomCellFor(indexPath: indexPath) {
            return getPendingAddtionalCustomCell(indexPath: indexPath)

        } else if viewModel.isApprovedCustomSubHeaderCellFor(indexPath: indexPath) {
            return getApprovedCustomSubHeaderCell(indexPath: indexPath)

        } else if viewModel.isSecondaryExitButtonCellFor(indexPath: indexPath) {
            return getSecondaryExitButtonCell()

        } else if viewModel.isFooterCellFor(indexPath: indexPath) {
            return getFooterCell()
        }

        return UITableViewCell()
    }

    private func getHeaderCell(indexPath: IndexPath) -> UITableViewCell {
        let headerCell = self.tableView.dequeueReusableCell(withIdentifier: "headerNib") as! HeaderCongratsTableViewCell
        headerCell.fillCell(paymentResult: self.viewModel.paymentResult!, paymentMethod: self.viewModel.paymentResult.paymentData?.paymentMethod, color: self.viewModel.getColor(), paymentResultScreenPreference: self.viewModel.paymentResultScreenPreference)
        return headerCell
    }

    private func getFooterCell() -> UITableViewCell {
        let footerNib = self.tableView.dequeueReusableCell(withIdentifier: "footerNib") as! FooterTableViewCell
        footerNib.setCallbackStatus(callback: self.viewModel.callback, status: PaymentResult.CongratsState.ok)
        footerNib.fillCell(paymentResult: self.viewModel.paymentResult, paymentResultScreenPreference: self.viewModel.paymentResultScreenPreference)
		let isSecondaryButtonDisplayed = viewModel.paymentResultScreenPreference.approvedSecondaryExitButtonCallback != nil
        if self.viewModel.paymentResult.isApproved() && !isSecondaryButtonDisplayed {
            ViewUtils.drawBottomLine(y: footerNib.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: footerNib.contentView)
        }
        return footerNib
    }

    private func getApprovedBodyCell() -> UITableViewCell {
        let approvedCell = self.tableView.dequeueReusableCell(withIdentifier: "approvedNib") as! ApprovedTableViewCell
        approvedCell.fillCell(paymentResult: self.viewModel.paymentResult!, checkoutPreference: self.viewModel.checkoutPreference, paymentResultScreenPreference: self.viewModel.paymentResultScreenPreference)
        return approvedCell
    }

    private func getConfirmEmailCell() -> UITableViewCell {
        let confirmEmailCell = self.tableView.dequeueReusableCell(withIdentifier: "emailNib") as! ConfirmEmailTableViewCell
        confirmEmailCell.fillCell(paymentResult: self.viewModel.paymentResult)
        ViewUtils.drawBottomLine(y: confirmEmailCell.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: confirmEmailCell.contentView)
        return confirmEmailCell
    }

    private func getContentCell(drawLine: Bool) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "ContentCell")
        cell.contentView.viewWithTag(2)?.removeFromSuperview()
        self.viewModel.getContentCell().tag = 2
        cell.contentView.addSubview(self.viewModel.getContentCell())
        cell.selectionStyle = .none
        if drawLine {
            ViewUtils.drawBottomLine(y: self.viewModel.getContentCell().frame.minY, width: UIScreen.main.bounds.width, inView: self.viewModel.getContentCell())
        }
        return cell
    }

    private func getCallForAuthCell() -> UITableViewCell {
        let callFAuthCell = self.tableView.dequeueReusableCell(withIdentifier: "callFAuthNib") as! CallForAuthTableViewCell
        callFAuthCell.setCallbackStatusTracking(callback: self.viewModel.setCallbackWithTracker(), paymentResult: self.viewModel.paymentResult, status: PaymentResult.CongratsState.call_FOR_AUTH)
        callFAuthCell.fillCell(paymentMehtod: self.viewModel.paymentResult.paymentData?.paymentMethod)
        return callFAuthCell
    }

    private func getApprovedAddtionalCustomCell(indexPath: IndexPath) -> UITableViewCell {
        return makeCellWith(customCell: self.viewModel.paymentResultScreenPreference.approvedAdditionalInfoCells[indexPath.row], indentifier: "ApprovedAdditionalCell")
    }

    private func getPendingAddtionalCustomCell(indexPath: IndexPath) -> UITableViewCell {
        return makeCellWith(customCell: self.viewModel.paymentResultScreenPreference.pendingAdditionalInfoCells[indexPath.row], indentifier: "PendingAdditionalCell")
    }

    private func getApprovedCustomSubHeaderCell(indexPath: IndexPath) -> UITableViewCell {
        return makeCellWith(customCell: self.viewModel.paymentResultScreenPreference.approvedSubHeaderCells[indexPath.row], indentifier: "ApprovedSubHeaderCell")
    }

    private func makeCellWith(customCell: MPCustomCell, indentifier: String) -> UITableViewCell {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let customView = customCell.getTableViewCell().contentView
        customCell.setDelegate(delegate: self)
        let frame = customView.frame
        customView.frame = CGRect(x: (screenWidth - frame.size.width) / 2, y: 0, width: frame.size.width, height: customCell.getHeight())
        let cell = UITableViewCell(style: .default, reuseIdentifier: indentifier)
        cell.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        cell.contentView.addSubview(customView)
        cell.selectionStyle = .none
        let separatorLine = ViewUtils.getTableCellSeparatorLineView(0, y: customCell.getHeight()-1, width: screenWidth, height: 1)
        cell.addSubview(separatorLine)
        cell.contentView.backgroundColor = customView.backgroundColor
        cell.clipsToBounds = true
        return cell
    }

    private func getSecondaryExitButtonCell() -> UITableViewCell {
        let secondaryButtonCell = self.tableView.dequeueReusableCell(withIdentifier: "secondaryButtonNib") as! SecondaryExitButtonTableViewCell
        secondaryButtonCell.fillCell(paymentResult: self.viewModel.paymentResult, paymentResultScreenPreference: self.viewModel.paymentResultScreenPreference)
        secondaryButtonCell.setCallbackStatusTracking(callback: self.viewModel.setCallbackWithTracker(), paymentResult: self.viewModel.paymentResult, status: PaymentResult.CongratsState.cancel_RETRY)
        return secondaryButtonCell
    }

    public func invokeCallbackWithPaymentResult(rowCallback: ((PaymentResult) -> Void)) {
        rowCallback(self.viewModel.paymentResult)
    }

}
