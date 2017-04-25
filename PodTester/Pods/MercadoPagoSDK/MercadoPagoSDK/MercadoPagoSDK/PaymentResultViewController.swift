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
    
    override open var screenName : String { get {
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
        frame.origin.y = -frame.size.height;
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
        
        let rejectedNib = UINib(nibName: "RejectedTableViewCell", bundle: self.bundle)
        self.tableView.register(rejectedNib, forCellReuseIdentifier: "rejectedNib")
        
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
        MPTracker.trackPaymentEvent(self.viewModel.paymentResult.paymentData?.token?._id, mpDelegate: MercadoPagoContext.sharedInstance, paymentInformer: self.viewModel, flavor: Flavor(rawValue: "3"), action: "CREATE_PAYMENT", result:nil)
    }

    init(paymentResult: PaymentResult, checkoutPreference: CheckoutPreference, callback : @escaping (_ status : MPStepBuilder.CongratsState) -> Void){
        super.init(nibName: "PaymentResultViewController", bundle : bundle)
        self.viewModel = PaymentResultViewModel(paymentResult: paymentResult, checkoutPreference: checkoutPreference,  callback: callback)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.isAdditionalCustomCellFor(indexPath: indexPath){
            if viewModel.inProcess(){
                return PaymentResultScreenPreference.pendingAdditionalInfoCells[indexPath.row].getHeight()
            } else if viewModel.approved(){
                return PaymentResultScreenPreference.approvedAdditionalInfoCells[indexPath.row].getHeight()
            }
        } else if viewModel.isCustomSubHeaderCellFor(indexPath: indexPath){
            return PaymentResultScreenPreference.approvedSubHeaderCells[indexPath.row].getHeight()
        }
        return UITableViewAutomaticDimension
        
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRowsInSection(section: section)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.isHeaderCellFor(indexPath: indexPath) {
            return self.getHeaderCell(indexPath: indexPath)
            
        } else if viewModel.isApprovedBodyCellFor(indexPath: indexPath){
            return getApprovedBodyCell()
            
        } else if viewModel.isEmailCellFor(indexPath: indexPath) {
            return getConfirmEmailCell()
            
        } else if viewModel.isCallForAuthFor(indexPath: indexPath) {
            return getCallForAuthCell()
            
        } else if viewModel.isSelectOtherPaymentMethodCellFor(indexPath: indexPath) {
            if viewModel.callForAuth() {
                return getOtherPaymentMethodCell(drawLine: true)
            }
            return getOtherPaymentMethodCell(drawLine: false)
            
        } else if viewModel.isAdditionalCustomCellFor(indexPath: indexPath) {
            return getAdditionalCustomCell(indexPath: indexPath)
        
        } else if viewModel.isCustomSubHeaderCellFor(indexPath: indexPath) {
            return getCustomSubHeaderCell(indexPath: indexPath)
        
        } else if viewModel.isSecondaryExitButtonCellFor(indexPath: indexPath) {
            return getSecondaryExitButtonCell()
        
        } else if viewModel.isFooterCellFor(indexPath: indexPath){
            return getFooterCell()
        }
        
        return UITableViewCell()
    }
    
    private func getHeaderCell(indexPath: IndexPath) -> UITableViewCell {
        let headerCell = self.tableView.dequeueReusableCell(withIdentifier: "headerNib") as! HeaderCongratsTableViewCell
        headerCell.fillCell(paymentResult: self.viewModel.paymentResult!, paymentMethod: self.viewModel.paymentResult.paymentData?.paymentMethod, color: self.viewModel.getColor())
        return headerCell
    }
    
    private func getFooterCell() -> UITableViewCell {
        let footerNib = self.tableView.dequeueReusableCell(withIdentifier: "footerNib") as! FooterTableViewCell
        footerNib.setCallbackStatus(callback: self.viewModel.callback, status: MPStepBuilder.CongratsState.ok)
        footerNib.fillCell(paymentResult: self.viewModel.paymentResult)
		let isSecondaryButtonDisplayed = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.approvedSecondaryExitButtonCallback != nil;
        if self.viewModel.approved() && !isSecondaryButtonDisplayed {
            ViewUtils.drawBottomLine(y: footerNib.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: footerNib.contentView)
        }
        return footerNib
    }
    
    private func getApprovedBodyCell() -> UITableViewCell {
        let approvedCell = self.tableView.dequeueReusableCell(withIdentifier: "approvedNib") as! ApprovedTableViewCell
        approvedCell.fillCell(paymentResult: self.viewModel.paymentResult!, checkoutPreference: self.viewModel.checkoutPreference)
        return approvedCell
    }
    
    private func getConfirmEmailCell() -> UITableViewCell {
        let confirmEmailCell = self.tableView.dequeueReusableCell(withIdentifier: "emailNib") as! ConfirmEmailTableViewCell
        confirmEmailCell.fillCell(paymentResult: self.viewModel.paymentResult)
        ViewUtils.drawBottomLine(y: confirmEmailCell.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: confirmEmailCell.contentView)
        return confirmEmailCell
    }
    
    private func getOtherPaymentMethodCell(drawLine: Bool) -> UITableViewCell {
        let rejectedCell = self.tableView.dequeueReusableCell(withIdentifier: "rejectedNib") as! RejectedTableViewCell
        rejectedCell.fillCell(paymentResult: self.viewModel.paymentResult)
        if drawLine {
            ViewUtils.drawBottomLine(y: rejectedCell.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: rejectedCell.contentView)
        }
        return rejectedCell
    }
    
    private func getCallForAuthCell() -> UITableViewCell {
        let callFAuthCell = self.tableView.dequeueReusableCell(withIdentifier: "callFAuthNib") as! CallForAuthTableViewCell
        callFAuthCell.setCallbackStatusTracking(callback: self.viewModel.setCallbackWithTracker(cellName: "call"), paymentResult: self.viewModel.paymentResult, status: MPStepBuilder.CongratsState.call_FOR_AUTH)
        callFAuthCell.fillCell(paymentMehtod: self.viewModel.paymentResult.paymentData?.paymentMethod)
        return callFAuthCell
    }
    
    private func getAdditionalCustomCell(indexPath: IndexPath) -> UITableViewCell {
        
        if self.viewModel.inProcess(){
            let customCell = PaymentResultScreenPreference.pendingAdditionalInfoCells[indexPath.row]
            customCell.setDelegate(delegate: self)
            let cell = customCell.getTableViewCell()
            cell.selectionStyle = .none
            return cell
        } else {
            let customCell = PaymentResultScreenPreference.approvedAdditionalInfoCells[indexPath.row]
            customCell.setDelegate(delegate: self)
            let cell = customCell.getTableViewCell()
            cell.selectionStyle = .none
            return cell
        }
    }
    
    private func getCustomSubHeaderCell(indexPath: IndexPath) -> UITableViewCell {
        
        if self.viewModel.approved(){
            let customCell = PaymentResultScreenPreference.approvedSubHeaderCells[indexPath.row]
            customCell.setDelegate(delegate: self)
            let cell = customCell.getTableViewCell()
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    private func getSecondaryExitButtonCell() -> UITableViewCell {
        let secondaryButtonCell = self.tableView.dequeueReusableCell(withIdentifier: "secondaryButtonNib") as! SecondaryExitButtonTableViewCell
        secondaryButtonCell.fillCell(paymentResult: self.viewModel.paymentResult)
        secondaryButtonCell.setCallbackStatusTracking(callback: self.viewModel.setCallbackWithTracker(cellName: "rejected"), paymentResult: self.viewModel.paymentResult, status: MPStepBuilder.CongratsState.cancel_RETRY)
        return secondaryButtonCell
    }
    
    public func invokeCallbackWithPaymentResult(rowCallback : ((PaymentResult) -> Void)) {
        rowCallback(self.viewModel.paymentResult)
    }

}

