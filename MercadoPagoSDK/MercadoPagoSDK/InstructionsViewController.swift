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
    var paymentResult: PaymentResult!
    var callback : ( _ status: PaymentResult.CongratsState) -> Void
    var bundle = MercadoPago.getBundle()
    var color: UIColor?
    var instructionsInfo: InstructionsInfo?
    var paymentResultScreenPreference: PaymentResultScreenPreference!

    override open var screenName: String { get { return "INSTRUCTIONS" } }
    override open var screenId: String { get { return "/checkout_off/congrats/instructions" } }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 60
        self.tableView.separatorStyle = .none

        self.color = self.getColor()

        var frame = self.tableView.bounds
        frame.origin.y = -frame.size.height
        let view = UIView(frame: frame)
        view.backgroundColor = self.color
        tableView.addSubview(view)

        let headerNib = UINib(nibName: "HeaderCongratsTableViewCell", bundle: self.bundle)
        self.tableView.register(headerNib, forCellReuseIdentifier: "headerNib")
        let subtitleNib = UINib(nibName: "InstructionsSubtitleTableViewCell", bundle: self.bundle)
        self.tableView.register(subtitleNib, forCellReuseIdentifier: "subtitleNib")
        let bodyNib = UINib(nibName: "InstructionBodyTableViewCell", bundle: self.bundle)
        self.tableView.register(bodyNib, forCellReuseIdentifier: "bodyNib")
        let emailNib = UINib(nibName: "ConfirmEmailTableViewCell", bundle: self.bundle)
        self.tableView.register(emailNib, forCellReuseIdentifier: "emailNib")
        let footerNib = UINib(nibName: "FooterTableViewCell", bundle: self.bundle)
        self.tableView.register(footerNib, forCellReuseIdentifier: "footerNib")
    }

    override  func trackInfo() {
        var metadata = [TrackingUtil.METADATA_PAYMENT_IS_EXPRESS: TrackingUtil.IS_EXPRESS_DEFAULT_VALUE,
                              TrackingUtil.METADATA_PAYMENT_STATUS: self.paymentResult.status,
                              TrackingUtil.METADATA_PAYMENT_STATUS_DETAIL: self.paymentResult.statusDetail,
                              TrackingUtil.METADATA_PAYMENT_ID: self.paymentResult._id]
        if let pm = self.paymentResult.paymentData?.paymentMethod {
            metadata[TrackingUtil.METADATA_PAYMENT_ID] = pm._id
        }
        if let issuer = self.paymentResult.paymentData?.issuer {
            metadata["issuer"] = issuer._id
        }
        MPXTracker.trackLastScreen(screenId: screenId, screenName: screenName, metadata: metadata)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController != nil && self.navigationController?.navigationBar != nil {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            ViewUtils.addStatusBar(self.view, color: self.color!)
        }

    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if instructionsInfo == nil {
            self.showLoading()
            getInstructions()
        } else {
            self.tableView.reloadData()
        }
    }
    public init(paymentResult: PaymentResult, callback : @escaping ( _ status: PaymentResult.CongratsState) -> Void, paymentResultScreenPreference: PaymentResultScreenPreference = PaymentResultScreenPreference()) {

        self.callback = callback
        super.init(nibName: "InstructionsViewController", bundle: bundle)
        self.paymentResult = paymentResult
        self.paymentResultScreenPreference = paymentResultScreenPreference
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func getColor() -> UIColor {
        return UIColor(red: 255, green: 161, blue: 90)
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return UITableViewAutomaticDimension
        }
        return UITableViewAutomaticDimension
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return (instructionsInfo != nil) ? 3 : 0
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        } else {
            return 2
        }
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let headerCell = self.tableView.dequeueReusableCell(withIdentifier: "headerNib") as! HeaderCongratsTableViewCell
                headerCell.fillCell(instructionsInfo: instructionsInfo!, color: color!)
                headerCell.selectionStyle = .none
                return headerCell
            } else {
                let subtitleCell = self.tableView.dequeueReusableCell(withIdentifier: "subtitleNib") as! InstructionsSubtitleTableViewCell
                subtitleCell.selectionStyle = .none
                return subtitleCell
            }
        case 1:
            let bodyCell = self.tableView.dequeueReusableCell(withIdentifier: "bodyNib") as! InstructionBodyTableViewCell
            bodyCell.selectionStyle = .none
            ViewUtils.drawBottomLine(y: bodyCell.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: bodyCell.contentView)
            bodyCell.fillCell(instruction: self.instructionsInfo!.instructions[0], paymentResult: paymentResult)
            return bodyCell
        default:
            if indexPath.row == 0 {
                let confirmEmailCell = self.tableView.dequeueReusableCell(withIdentifier: "emailNib") as! ConfirmEmailTableViewCell
                confirmEmailCell.fillCell(instruction: instructionsInfo?.instructions[0])
                confirmEmailCell.selectionStyle = .none
                ViewUtils.drawBottomLine(y: confirmEmailCell.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: confirmEmailCell.contentView)
                return confirmEmailCell
            } else {
                let footerNib = self.tableView.dequeueReusableCell(withIdentifier: "footerNib") as! FooterTableViewCell
                footerNib.selectionStyle = .none
                footerNib.setCallbackStatus(callback: callback, status: PaymentResult.CongratsState.ok)
                footerNib.fillCell(paymentResult: paymentResult, paymentResultScreenPreference: paymentResultScreenPreference)
                ViewUtils.drawBottomLine(y: footerNib.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: footerNib.contentView)
                return footerNib
            }
        }
    }

    fileprivate func getInstructions() {
        if let paymentId = paymentResult._id,
            let paymentTypeId = self.paymentResult.paymentData?.paymentMethod.paymentTypeId {
            MPServicesBuilder.getInstructions(for: paymentId, paymentTypeId : paymentTypeId, baseURL:MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: { (instructionsInfo : InstructionsInfo) -> Void in
                self.instructionsInfo = instructionsInfo
                self.tableView.reloadData()
                self.hideLoading()
            }, failure: { (error) -> Void in
                self.requestFailure(error, requestOrigin: ApiUtil.RequestOrigin.GET_INSTRUCTIONS.rawValue, callback: {
                    self.getInstructions()
                }, callbackCancel: {
                    self.dismiss(animated: true, completion: {})
                })
                self.hideLoading()
            })
        }
    }
}
