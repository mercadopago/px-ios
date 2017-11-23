//
//  HookViewController.swift
//  PodTester
//
//  Created by Eden Torres on 11/22/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import Foundation
import MercadoPagoSDK
import UIKit
open class HookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var paymentData: PaymentData = PaymentData()
    var paymentOptionSelected: PaymentMethodOption?
    
    var mpAction : MPAction?
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! UITableViewCell
        cell.textLabel?.text = "Row \(indexPath.row) - \(paymentOptionSelected?.getDescription() ?? "")"
        return cell
    }

    @IBOutlet weak var table: UITableView!
    
    @IBAction func showNext(_ sender: Any) {
        self.mpAction?.back()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        table.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
    }
}

extension HookViewController: Hookeable {
    
    public func renderDidFinish() {
        self.table.reloadData()
    }

    public func getStep() -> HookStep {
        return HookStep.STEP1
    }

    public func render() -> UIView {
        return self.view
    }

    public func didRecive(hookStore: HookStore) {
        self.paymentData = hookStore.getPaymentData()
        self.paymentOptionSelected = hookStore.getPaymentOptionSelected()
    }

    public func didRecive(action: MPAction) {
        self.mpAction = action
    }
}
