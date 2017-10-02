//
//  InstructionsTableViewController.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/6/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class InstructionsViewController: MercadoPagoUIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: InstructionsViewModel!
    var bundle = MercadoPago.getBundle()!

    override open var screenName: String { get { return TrackingUtil.SCREEN_NAME_PAYMENT_RESULT_INSTRUCTIONS} }
    override open var screenId: String { get { return TrackingUtil.SCREEN_ID_PAYMENT_RESULT_INSTRUCTIONS } }

    fileprivate func addUpperFrame() {
        var frame = self.tableView.bounds
        frame.origin.y = -frame.size.height
        frame.size.width = UIScreen.main.bounds.width
        let view = UIView(frame: frame)
        view.backgroundColor =  self.viewModel.getHeaderColor()
        tableView.addSubview(view)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 60
        self.tableView.separatorStyle = .none

        addUpperFrame()
    }

    override  func trackInfo() {
        MPXTracker.trackScreen(screenId: screenId, screenName: screenName, metadata: self.viewModel.getMetada())
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController != nil && self.navigationController?.navigationBar != nil {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            ViewUtils.addStatusBar(self.view, color: self.viewModel.getHeaderColor())
        }
    }

    public init(paymentResult: PaymentResult, instructionsInfo: InstructionsInfo, callback : @escaping ( _ status: PaymentResult.CongratsState) -> Void, paymentResultScreenPreference: PaymentResultScreenPreference = PaymentResultScreenPreference()) {
        self.viewModel = InstructionsViewModel(paymentResult: paymentResult, paymentResultScreenPreference: paymentResultScreenPreference, instructionsInfo: instructionsInfo, callback: callback)
        super.init(nibName: "InstructionsViewController", bundle: bundle)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.heightForRowAt(indexPath)
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRowsInSection(section)
    }

    fileprivate func getHeaderTitleCell() -> UITableViewCell {
        let cell: HeaderCongratsTableViewCell = bundle.loadNibNamed("HeaderCongratsTableViewCell", owner: nil, options: nil)?[0] as! HeaderCongratsTableViewCell
        cell.fillCell(instructionsInfo: self.viewModel.instructionsInfo, color: self.viewModel.getHeaderColor())
        cell.selectionStyle = .none
        return cell
    }

    fileprivate func getHeaderSubtitleCell() -> UITableViewCell {
        let cell: InstructionsSubtitleTableViewCell = bundle.loadNibNamed("InstructionsSubtitleTableViewCell", owner: nil, options: nil)?[0] as! InstructionsSubtitleTableViewCell
        cell.fillCell(instruction: self.viewModel.getInstruction())
        cell.selectionStyle = .none
        return cell
    }

    fileprivate func getBodyCell() -> UITableViewCell {
        let cell: InstructionBodyTableViewCell = bundle.loadNibNamed("InstructionBodyTableViewCell", owner: nil, options: nil)?[0] as! InstructionBodyTableViewCell
        cell.selectionStyle = .none
        ViewUtils.drawBottomLine(y: cell.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: cell.contentView)
        cell.fillCell(instruction: self.viewModel.getInstruction(), paymentResult: self.viewModel.paymentResult)
        return cell
    }

    fileprivate func getSecondaryInfoCell() -> UITableViewCell {
        let cell: SecondaryInfoTableViewCell = bundle.loadNibNamed("SecondaryInfoTableViewCell", owner: nil, options: nil)?[0] as! SecondaryInfoTableViewCell
        cell.fillCell(instruction: self.viewModel.getInstruction())
        cell.selectionStyle = .none
        ViewUtils.drawBottomLine(y: cell.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: cell.contentView)
        return cell
    }

    fileprivate func getFooterCell() -> UITableViewCell {
        let cell: FooterTableViewCell = bundle.loadNibNamed("FooterTableViewCell", owner: nil, options: nil)?[0] as! FooterTableViewCell
        cell.selectionStyle = .none
        ViewUtils.drawBottomLine(y: cell.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: cell.contentView)
        cell.setCallbackStatus(callback: self.viewModel.callback, status: PaymentResult.CongratsState.ok)
        cell.fillCell(paymentResult: self.viewModel.paymentResult, paymentResultScreenPreference: self.viewModel.paymentResultScreenPreference)
        return cell
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.viewModel.isHeaderTitleCellFor(indexPath: indexPath) {
            return getHeaderTitleCell()
        } else if self.viewModel.isHeaderSubtitleCellFor(indexPath: indexPath) {
            return getHeaderSubtitleCell()
        } else if self.viewModel.isBodyCellFor(indexPath: indexPath) {
            return getBodyCell()
        } else if self.viewModel.isSecondaryInfoCellFor(indexPath: indexPath) {
            return getSecondaryInfoCell()
        } else if self.viewModel.isFooterCellFor(indexPath: indexPath) {
            return getFooterCell()
        }
        return UITableViewCell()
    }

}
