//
//  InstructionsTableViewController.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/6/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class InstructionsRevampViewController: MercadoPagoUIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var payment : Payment!
    var paymentTypeId : String!
    var callback : (_ payment : Payment, _ status : MPStepBuilder.CongratsState) -> Void
    var bundle = MercadoPago.getBundle()
    var color:UIColor?
    var instruction: Instruction?
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 60
        self.tableView.separatorStyle = .none
        
        self.color = self.getColor()
        
        var frame = self.tableView.bounds
        frame.origin.y = -frame.size.height;
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
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController != nil && self.navigationController?.navigationBar != nil {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            ViewUtils.addStatusBar(self.view, color: self.color!)
        }
        
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if instruction == nil {
            self.showLoading()
            getInstructions()
        } else {
            self.tableView.reloadData()
        }
    }
    public init(payment : Payment, paymentTypeId : String, callback : @escaping (_ payment : Payment, _ status : MPStepBuilder.CongratsState) -> Void) {
        self.callback = callback
        super.init(nibName: "InstructionsRevampViewController", bundle: bundle)
        self.payment = payment
        self.paymentTypeId = paymentTypeId
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func getColor()->UIColor{
        return UIColor(red: 255, green: 161, blue: 90)
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            return UITableViewAutomaticDimension
        }
        return UITableViewAutomaticDimension
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return (instruction != nil) ? 3 : 0
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
                headerCell.fillCell(payment: payment, paymentMethod: nil, color: color!, instruction: instruction)
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
            bodyCell.fillCell(instruction: self.instruction!, payment: self.payment)
            return bodyCell
        default:
            if indexPath.row == 0{
                let confirmEmailCell = self.tableView.dequeueReusableCell(withIdentifier: "emailNib") as! ConfirmEmailTableViewCell
                confirmEmailCell.fillCell(payment: payment, instruction: instruction)
                confirmEmailCell.selectionStyle = .none
                ViewUtils.drawBottomLine(y: confirmEmailCell.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: confirmEmailCell.contentView)
                return confirmEmailCell
            } else {
                let footerNib = self.tableView.dequeueReusableCell(withIdentifier: "footerNib") as! FooterTableViewCell
                footerNib.selectionStyle = .none
                footerNib.setCallbackStatus(callback: callback, payment: payment, status: MPStepBuilder.CongratsState.ok)
                footerNib.fillCell(payment: payment)
                ViewUtils.drawBottomLine(y: footerNib.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: footerNib.contentView)
                return footerNib
            }
        }
    }
    
    fileprivate func getInstructions(){
        MPServicesBuilder.getInstructions(payment._id, paymentTypeId : self.paymentTypeId, success: { (instructionsInfo : InstructionsInfo) -> Void in
            self.instruction = instructionsInfo.instructions[0]
            self.tableView.reloadData()
            self.hideLoading()
        }, failure: { (error) -> Void in
            self.requestFailure(error, callback: {
                self.getInstructions()
            }, callbackCancel: {
                self.dismiss(animated: true, completion: {})
            })
            self.hideLoading()
        })
    }
}
