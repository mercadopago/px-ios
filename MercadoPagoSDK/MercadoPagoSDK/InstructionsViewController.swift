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
    var paymentResult: PaymentResult!
    var bundle = MercadoPago.getBundle()
    var color: UIColor?
    var paymentResultScreenPreference: PaymentResultScreenPreference!

    override open var screenName: String { get { return TrackingUtil.SCREEN_NAME_PAYMENT_RESULT_INSTRUCTIONS} }
    override open var screenId: String { get { return TrackingUtil.SCREEN_ID_PAYMENT_RESULT_INSTRUCTIONS } }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 60
        self.tableView.separatorStyle = .none
        self.color = self.viewModel.getHeaderColor()

        var frame = self.tableView.bounds
        frame.origin.y = -frame.size.height
        frame.size.width = UIScreen.main.bounds.width
        let view = UIView(frame: frame)
        view.backgroundColor = self.color
        tableView.addSubview(view)
    }

    override  func trackInfo() {
        var metadata = [TrackingUtil.METADATA_PAYMENT_IS_EXPRESS: TrackingUtil.IS_EXPRESS_DEFAULT_VALUE,
                              TrackingUtil.METADATA_PAYMENT_STATUS: self.paymentResult.status,
                              TrackingUtil.METADATA_PAYMENT_STATUS_DETAIL: self.paymentResult.statusDetail,
                              TrackingUtil.METADATA_PAYMENT_ID: self.paymentResult._id]
        if let pm = self.paymentResult.paymentData?.getPaymentMethod() {
            metadata[TrackingUtil.METADATA_PAYMENT_METHOD_ID] = pm._id
        }
        if let issuer = self.paymentResult.paymentData?.getIssuer() {
            metadata["issuer"] = issuer._id
        }
        MPXTracker.trackScreen(screenId: screenId, screenName: screenName, metadata: metadata)
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
        self.tableView.reloadData()
    }
    
    public init(paymentResult: PaymentResult, instructionsInfo: InstructionsInfo, callback : @escaping ( _ status: PaymentResult.CongratsState) -> Void, paymentResultScreenPreference: PaymentResultScreenPreference = PaymentResultScreenPreference()) {
        self.viewModel = InstructionsViewModel(paymentResult: paymentResult, paymentResultScreenPreference: paymentResultScreenPreference, instructionsInfo: instructionsInfo, callback: callback)
        super.init(nibName: "InstructionsViewController", bundle: bundle)
        self.paymentResult = paymentResult
        self.paymentResultScreenPreference = paymentResultScreenPreference
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

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.viewModel.getCellForRowAt(indexPath)
    }

}
