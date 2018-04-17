//
//  PromoTyCViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 17/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PromoTyCViewController: MercadoPagoUIViewController {

    var legalText: String!
    var textView: UITextView!

    init(legalText: String) {
        self.legalText = legalText
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Términos y Condiciones".localized
        self.textView = UITextView()
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.text = legalText
        self.view.addSubview(self.textView)
        PXLayout.pinTop(view: self.textView).isActive = true
        PXLayout.pinBottom(view: self.textView).isActive = true
        PXLayout.centerHorizontally(view: self.textView).isActive = true
        PXLayout.matchWidth(ofView: self.textView).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
